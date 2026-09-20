import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/templates/template_editor_controller.dart';
import '../../application/templates/template_editor_state.dart';
import '../../core_engine/common/enums.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../../core_engine/templates/domain/field_group.dart';
import '../../core_engine/templates/domain/template_layer.dart';
import 'collapsible_panel.dart';
import 'layout_workspace.dart';
import '../routing/app_routes.dart';

/// The core editor: a background card image with zoom (InteractiveViewer) and
/// draggable text/image layers positioned in millimeters. Screen zoom is purely a
/// view transform - layer geometry (xMm/yMm/widthMm/heightMm/fontSizePt) never
/// changes with zoom, so the same numbers this screen saves are exactly what
/// PdfGenerationService prints from on the backend.
class TemplateEditorScreen extends ConsumerWidget {
  const TemplateEditorScreen({super.key, required this.templateId});

  final int templateId;

  /// Screen pixels per millimeter at 100%. Flutter rounds each text line's height to a whole
  /// pixel, so the card is laid out at a fine scale (the error is at most half a pixel = 0.04 mm
  /// per line) and then zoomed as a view transform, keeping the screen within a hair of the PDF.
  static const double pxPerMm = LayoutWorkspace.pxPerMm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = templateEditorControllerProvider(templateId);
    final stateAsync = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return stateAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Failed to load template: $e'))),
      data: (state) => _EditorBody(state: state, controller: controller),
    );
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody({required this.state, required this.controller});

  final TemplateEditorState state;
  final TemplateEditorController controller;

  TemplateLayer get _currentLayer =>
      state.layers.firstWhere((l) => l.side == state.side);

  Future<void> _save(BuildContext context) async {
    final ok = await controller.save();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Layout saved.' : 'Save failed.')),
    );
  }

  Future<void> _importPdf(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null ||
        result.files.isEmpty ||
        result.files.first.bytes == null)
      return;

    final picked = result.files.first;
    final count = await controller.importSamplePdf(
      UploadedFile(picked.bytes!, picked.name),
    );
    if (!context.mounted) return;
    final message = count == null
        ? 'Could not read the PDF.'
        : count == 0
        ? 'No text or images found in the PDF.'
        : 'Found $count fields in ${picked.name}. Add the ones you need from the Fields panel, then Save.';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final template = state.template.template;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to templates',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.templates),
        ),
        title: Text('Design: ${template.name}'),
        actions: [
          IconButton(
            tooltip: 'Add text layer',
            icon: const Icon(Icons.text_fields),
            onPressed: () => controller.addGroup(LayerFieldType.text),
          ),
          IconButton(
            tooltip:
                'Add combined group (several fields joined by , or - or space)',
            icon: const Icon(Icons.join_inner),
            onPressed: controller.addCombinedGroup,
          ),
          IconButton(
            tooltip: 'Add image layer',
            icon: const Icon(Icons.image_outlined),
            onPressed: () => controller.addGroup(LayerFieldType.image),
          ),
          IconButton(
            tooltip: 'Add empty QR code image (chosen in the card generator)',
            icon: const Icon(Icons.qr_code_2),
            onPressed: controller.addQrLayer,
          ),
          IconButton(
            tooltip: 'Import sample PDF (replaces the fields list)',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _importPdf(context),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: state.isSaving ? null : () => _save(context),
            icon: state.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: LayoutWorkspace(
              designer: true,
              layers: state.layers,
              cardWidthMm: template.cardWidthMm,
              cardHeightMm: template.cardHeightMm,
              frontImageBase64: template.frontImageBase64,
              backImageBase64: template.backImageBase64,
              side: state.side,
              combined: state.combined,
              selectedGroupId: state.selectedGroupId,
              sampleFields: state.sampleFields,
              onSelectView: (view) => switch (view) {
                EditorView.combined => controller.selectCombined(),
                EditorView.front => controller.selectSide(CardSide.front),
                EditorView.back => controller.selectSide(CardSide.back),
              },
              onSelectLayer: controller.selectLayer,
              onMoveGroup: controller.moveGroup,
              onChanged: controller.updateGroup,
              onMergeLayer: controller.mergeLayerInto,
              onDelete: controller.deleteSelected,
            ),
          ),
          CollapsiblePanel(
            title: 'Layers',
            width: 260,
            edge: CollapseEdge.left,
            child: _FieldsAndLayersPanel(
              fields: state.sampleFields,
              layers: _currentLayer.groups,
              selectedId: state.selectedGroupId,
              onImport: () => _importPdf(context),
              onAddField: controller.addLayerFromField,
              onSelectLayer: controller.selectGroup,
              onDeleteLayer: controller.deleteGroup,
            ),
          ),
        ],
      ),
    );
  }
}

/// Right-hand palette: the fields extracted from the template's one sample PDF
/// (add any of them as a layer, any time), and the current side's layers (select
/// or delete).
class _FieldsAndLayersPanel extends StatelessWidget {
  const _FieldsAndLayersPanel({
    required this.fields,
    required this.layers,
    required this.selectedId,
    required this.onImport,
    required this.onAddField,
    required this.onSelectLayer,
    required this.onDeleteLayer,
  });

  final List<ExtractedField> fields;
  final List<LayerGroup> layers;
  final String? selectedId;
  final VoidCallback onImport;
  final void Function(ExtractedField field) onAddField;
  final void Function(String groupId) onSelectLayer;
  final void Function(String groupId) onDeleteLayer;

  Widget _fieldTitle(ExtractedField f) {
    if (f.type == LayerFieldType.image) {
      Uint8List bytes;
      try {
        bytes = (f.value ?? '').isEmpty ? Uint8List(0) : base64Decode(f.value!);
      } catch (_) {
        bytes = Uint8List(0);
      }
      return Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: bytes.isEmpty
                ? const Icon(Icons.image)
                : Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(f.key ?? 'Image', overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }
    return Text(
      '${f.key ?? ''}: ${f.value ?? ''}',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // A Material (not a colored Container) so the list tiles' selection and ink show.
    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      child: Column(
        children: [
          _sectionHeader(
            context,
            'Fields from PDF (${fields.length})',
            TextButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.upload_file, size: 18),
              label: Text(fields.isEmpty ? 'Import' : 'Replace'),
            ),
          ),
          Expanded(
            child: fields.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Import the template's sample PDF to list its text and image fields.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: fields.length,
                    itemBuilder: (_, i) => ListTile(
                      dense: true,
                      leading: Icon(
                        fields[i].type == LayerFieldType.image
                            ? Icons.image_outlined
                            : Icons.text_fields,
                        size: 18,
                      ),
                      title: _fieldTitle(fields[i]),
                      trailing: IconButton(
                        tooltip: 'Add as layer',
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => onAddField(fields[i]),
                      ),
                    ),
                  ),
          ),
          _sectionHeader(context, 'Layers (${layers.length})', null),
          Expanded(
            child: layers.isEmpty
                ? const Center(child: Text('No layers on this side'))
                : ListView.builder(
                    itemCount: layers.length,
                    itemBuilder: (_, i) {
                      final g = layers[i];
                      return ListTile(
                        dense: true,
                        selected: g.id == selectedId,
                        leading: Icon(
                          g.fieldType == LayerFieldType.image
                              ? Icons.image_outlined
                              : Icons.text_fields,
                          size: 18,
                        ),
                        title: Text(
                          g.name.isEmpty ? '(unnamed)' : g.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => onSelectLayer(g.id),
                        trailing: IconButton(
                          tooltip: 'Delete layer',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => onDeleteLayer(g.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, Widget? action) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.only(left: 12, right: 4),
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
          if (action != null) action,
        ],
      ),
    );
  }
}

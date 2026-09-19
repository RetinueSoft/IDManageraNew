import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/templates/template_editor_controller.dart';
import '../../application/templates/template_editor_state.dart';
import '../../core_engine/common/enums.dart';
import '../../core_engine/templates/domain/template_layer.dart';

/// The core editor: a background card image with zoom (InteractiveViewer) and
/// draggable text/image layers positioned in millimeters. Screen zoom is purely a
/// view transform - layer geometry (xMm/yMm/widthMm/heightMm/fontSizePt) never
/// changes with zoom, so the same numbers this screen saves are exactly what
/// PdfGenerationService prints from on the backend.
class TemplateEditorScreen extends ConsumerWidget {
  const TemplateEditorScreen({super.key, required this.templateId});

  final int templateId;

  static const double pxPerMm = 4.0;
  static const double ptToMm = 25.4 / 72;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = templateEditorControllerProvider(templateId);
    final stateAsync = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return stateAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Failed to load template: $e'))),
      data: (state) => _EditorBody(state: state, controller: controller),
    );
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody({required this.state, required this.controller});

  final TemplateEditorState state;
  final TemplateEditorController controller;

  static const double pxPerMm = TemplateEditorScreen.pxPerMm;
  static const double ptToMm = TemplateEditorScreen.ptToMm;

  TemplateLayer get _currentLayer => state.layers.firstWhere((l) => l.side == state.side);

  LayerGroup? get _selectedGroup {
    final id = state.selectedGroupId;
    if (id == null) return null;
    for (final g in _currentLayer.groups) {
      if (g.id == id) return g;
    }
    return null;
  }

  Uint8List _decodeImage(String base64Str) => base64Str.isEmpty ? Uint8List(0) : base64Decode(base64Str);

  Future<void> _save(BuildContext context) async {
    final ok = await controller.save();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Layout saved.' : 'Save failed.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final template = state.template.template;
    final cardWidthPx = template.cardWidthMm * pxPerMm;
    final cardHeightPx = template.cardHeightMm * pxPerMm;
    final imageBytes = _decodeImage(
      state.side == CardSide.front ? template.frontImageBase64 : template.backImageBase64,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Design: ${template.name}'),
        actions: [
          IconButton(
            tooltip: 'Add text layer',
            icon: const Icon(Icons.text_fields),
            onPressed: () => controller.addGroup(LayerFieldType.text),
          ),
          IconButton(
            tooltip: 'Add image layer',
            icon: const Icon(Icons.image_outlined),
            onPressed: () => controller.addGroup(LayerFieldType.image),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: state.isSaving ? null : () => _save(context),
            icon: state.isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SegmentedButton<CardSide>(
                    segments: const [
                      ButtonSegment(value: CardSide.front, label: Text('Front')),
                      ButtonSegment(value: CardSide.back, label: Text('Back')),
                    ],
                    selected: {state.side},
                    onSelectionChanged: (s) => controller.selectSide(s.first),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey.shade300,
                    child: InteractiveViewer(
                      minScale: 0.3,
                      maxScale: 6,
                      constrained: false,
                      boundaryMargin: const EdgeInsets.all(200),
                      child: GestureDetector(
                        onTap: () => controller.selectGroup(null),
                        child: Container(
                          width: cardWidthPx,
                          height: cardHeightPx,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              if (imageBytes.isNotEmpty)
                                Positioned.fill(child: Image.memory(imageBytes, fit: BoxFit.fill)),
                              for (final group in _currentLayer.groups) _buildLayerWidget(group),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 300,
            child: _selectedGroup == null
                ? const Center(child: Text('Select a layer to edit its properties'))
                : _PropertiesPanel(
                    key: ValueKey(_selectedGroup!.id),
                    group: _selectedGroup!,
                    onChanged: (update) => controller.updateGroup(_selectedGroup!.id, update),
                    onDelete: controller.deleteSelected,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerWidget(LayerGroup group) {
    final isSelected = group.id == state.selectedGroupId;
    final left = group.xMm * pxPerMm;
    final top = group.yMm * pxPerMm;

    Widget content;
    if (group.fieldType == LayerFieldType.image) {
      final widthPx = (group.widthMm ?? 20) * pxPerMm;
      final heightPx = (group.heightMm ?? 20) * pxPerMm;
      content = Container(
        width: widthPx,
        height: heightPx,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey)),
        child: const Icon(Icons.image, color: Colors.blueGrey),
      );
    } else {
      final fontSizePx = group.fontSizePt * ptToMm * pxPerMm;
      final source = group.sources.isNotEmpty ? group.sources.first : null;
      final text = source?.key != null && source!.key!.isNotEmpty
          ? '${source.key}: ${source.value ?? ''}'
          : (source?.value ?? group.name);
      content = Text(
        text,
        style: TextStyle(fontSize: fontSizePx, fontWeight: group.bold ? FontWeight.bold : FontWeight.normal),
      );
    }

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => controller.selectGroup(group.id),
        onPanUpdate: (details) =>
            controller.moveGroup(group.id, details.delta.dx / pxPerMm, details.delta.dy / pxPerMm),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 1.5),
          ),
          child: content,
        ),
      ),
    );
  }
}

class _PropertiesPanel extends StatefulWidget {
  const _PropertiesPanel({super.key, required this.group, required this.onChanged, required this.onDelete});

  final LayerGroup group;
  final void Function(LayerGroup Function(LayerGroup current) update) onChanged;
  final VoidCallback onDelete;

  @override
  State<_PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<_PropertiesPanel> {
  late TextEditingController _keyCtrl;
  late TextEditingController _valueCtrl;

  @override
  void initState() {
    super.initState();
    final source = widget.group.sources.isNotEmpty ? widget.group.sources.first : null;
    _keyCtrl = TextEditingController(text: source?.key ?? '');
    _valueCtrl = TextEditingController(text: source?.value ?? '');
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  LayerSourceItem _firstSourceOrDefault(LayerGroup g) =>
      g.sources.isNotEmpty ? g.sources.first : LayerSourceItem(type: g.fieldType);

  void _updateFirstSource(LayerSourceItem Function(LayerSourceItem) update) {
    widget.onChanged((g) {
      final source = update(_firstSourceOrDefault(g));
      return g.copyWith(sources: [source, ...g.sources.skip(1)]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Layer properties', style: Theme.of(context).textTheme.titleMedium),
              IconButton(icon: const Icon(Icons.delete_outline), onPressed: widget.onDelete),
            ],
          ),
          const SizedBox(height: 8),
          if (group.fieldType == LayerFieldType.text) ...[
            TextField(
              controller: _keyCtrl,
              decoration: const InputDecoration(labelText: 'Field key (matches source PDF)'),
              onChanged: (v) => _updateFirstSource((s) => s.copyWith(key: v)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _valueCtrl,
              decoration: const InputDecoration(labelText: 'Sample value'),
              onChanged: (v) => _updateFirstSource((s) => s.copyWith(value: v)),
            ),
            const SizedBox(height: 8),
            _NumberField(
              label: 'Font size (pt)',
              value: group.fontSizePt,
              onChanged: (v) => widget.onChanged((g) => g.copyWith(fontSizePt: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bold'),
              value: group.bold,
              onChanged: (v) => widget.onChanged((g) => g.copyWith(bold: v)),
            ),
          ] else ...[
            _NumberField(
              label: 'Width (mm)',
              value: group.widthMm ?? 20,
              onChanged: (v) => widget.onChanged((g) => g.copyWith(widthMm: v)),
            ),
            const SizedBox(height: 8),
            _NumberField(
              label: 'Height (mm)',
              value: group.heightMm ?? 20,
              onChanged: (v) => widget.onChanged((g) => g.copyWith(heightMm: v)),
            ),
          ],
          const Divider(height: 32),
          _NumberField(
            label: 'X position (mm)',
            value: group.xMm,
            onChanged: (v) => widget.onChanged((g) => g.copyWith(xMm: v)),
          ),
          const SizedBox(height: 8),
          _NumberField(
            label: 'Y position (mm)',
            value: group.yMm,
            onChanged: (v) => widget.onChanged((g) => g.copyWith(yMm: v)),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.label, required this.value, required this.onChanged});

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('$label-${value.toStringAsFixed(1)}'),
      initialValue: value.toStringAsFixed(1),
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onFieldSubmitted: (v) {
        final parsed = double.tryParse(v);
        if (parsed != null) onChanged(parsed);
      },
    );
  }
}

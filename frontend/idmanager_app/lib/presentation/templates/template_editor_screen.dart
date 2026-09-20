import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/templates/template_editor_controller.dart';
import '../../application/templates/template_editor_state.dart';
import '../../core_engine/common/enums.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../../core_engine/templates/domain/field_group.dart';
import '../../core_engine/templates/domain/layer_text.dart';
import '../../core_engine/templates/domain/template_layer.dart';
import '../shared/widgets/card_text_layer.dart';
import 'collapsible_panel.dart';
import 'date_format_editor.dart';
import 'remove_words_editor.dart';
import '../shared/widgets/zoomable_canvas.dart';
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
  static const double pxPerMm = 12.0;

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

/// What the designer canvas shows.
enum _EditorView { combined, front, back }

class _EditorBody extends StatelessWidget {
  const _EditorBody({required this.state, required this.controller});

  final TemplateEditorState state;
  final TemplateEditorController controller;

  static const double pxPerMm = TemplateEditorScreen.pxPerMm;

  TemplateLayer get _currentLayer =>
      state.layers.firstWhere((l) => l.side == state.side);

  LayerGroup? get _selectedGroup {
    final id = state.selectedGroupId;
    if (id == null) return null;
    for (final g in _currentLayer.groups) {
      if (g.id == id) return g;
    }
    return null;
  }

  Uint8List _decodeImage(String base64Str) =>
      base64Str.isEmpty ? Uint8List(0) : base64Decode(base64Str);

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
    final cardWidthPx = template.cardWidthMm * pxPerMm;
    final cardHeightPx = template.cardHeightMm * pxPerMm;
    // The cards on show: front and back side by side (the default), or just one.
    final sides = state.combined ? CardSide.values : [state.side];
    final canvasWidthPx =
        cardWidthPx * sides.length + _cardGapPx * (sides.length - 1);

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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SegmentedButton<_EditorView>(
                    segments: const [
                      ButtonSegment(
                        value: _EditorView.combined,
                        label: Text('Front + Back'),
                      ),
                      ButtonSegment(
                        value: _EditorView.front,
                        label: Text('Front'),
                      ),
                      ButtonSegment(
                        value: _EditorView.back,
                        label: Text('Back'),
                      ),
                    ],
                    selected: {
                      state.combined
                          ? _EditorView.combined
                          : (state.side == CardSide.front
                                ? _EditorView.front
                                : _EditorView.back),
                    },
                    onSelectionChanged: (v) => switch (v.first) {
                      _EditorView.combined => controller.selectCombined(),
                      _EditorView.front => controller.selectSide(
                        CardSide.front,
                      ),
                      _EditorView.back => controller.selectSide(CardSide.back),
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey.shade300,
                    child: ZoomableCanvas(
                      contentSize: Size(canvasWidthPx, cardHeightPx),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < sides.length; i++) ...[
                            if (i > 0) const SizedBox(width: _cardGapPx),
                            _buildCard(sides[i], cardWidthPx, cardHeightPx),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                CollapsiblePanel(
                  title: 'Properties',
                  height: 320,
                  edge: CollapseEdge.bottom,
                  child: _selectedGroup == null
                      ? const Center(
                          child: Text('Select a layer to edit its properties'),
                        )
                      : _PropertiesPanel(
                          key: ValueKey(_selectedGroup!.id),
                          group: _selectedGroup!,
                          sampleFields: state.sampleFields,
                          otherLayers: [
                            for (final g in _currentLayer.groups)
                              if (g.id != _selectedGroup!.id &&
                                  g.fieldType == LayerFieldType.text &&
                                  !g.isList)
                                g,
                          ],
                          onMergeLayer: (otherId) => controller.mergeLayerInto(
                            _selectedGroup!.id,
                            otherId,
                          ),
                          onChanged: (update) => controller.updateGroup(
                            _selectedGroup!.id,
                            update,
                          ),
                          onDelete: controller.deleteSelected,
                        ),
                ),
              ],
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

  /// Space between the front and back cards in the combined view.
  static const double _cardGapPx = 2 * pxPerMm;

  /// One card of the canvas: its background image and that side's layers. Clicking a layer (or
  /// the empty card) makes this the side that edits go to.
  Widget _buildCard(CardSide side, double widthPx, double heightPx) {
    final template = state.template.template;
    final imageBytes = _decodeImage(
      side == CardSide.front
          ? template.frontImageBase64
          : template.backImageBase64,
    );
    final groups = state.layers.firstWhere((l) => l.side == side).groups;
    return GestureDetector(
      onTap: () => controller.selectLayer(side, null),
      child: Container(
        width: widthPx,
        height: heightPx,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (imageBytes.isNotEmpty)
              Positioned.fill(
                child: Image.memory(imageBytes, fit: BoxFit.fill),
              ),
            for (final group in groups) _buildLayerWidget(side, group),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerWidget(CardSide side, LayerGroup group) {
    final isSelected = group.id == state.selectedGroupId;
    final left = group.xMm * pxPerMm;
    final top = group.yMm * pxPerMm;

    Widget content;
    if (group.fieldType == LayerFieldType.image) {
      final widthPx = (group.widthMm ?? 20) * pxPerMm;
      final heightPx = (group.heightMm ?? 20) * pxPerMm;
      final sample = group.sources.isNotEmpty
          ? group.sources.first.value
          : null;
      final sampleBytes = _decodeImage(sample ?? '');
      content = Container(
        width: widthPx,
        height: heightPx,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey)),
        // Images are stretched to exactly the layer's width x height.
        child: sampleBytes.isEmpty
            ? LayoutBuilder(
                builder: (_, box) => Icon(
                  group.isQr ? Icons.qr_code_2 : Icons.image,
                  color: Colors.blueGrey,
                  size: box.biggest.shortestSide * 0.8,
                ),
              )
            : Image.memory(
                sampleBytes,
                fit: BoxFit.fill,
                width: widthPx,
                height: heightPx,
                errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
              ),
      );
    } else {
      // The same widget the card preview uses, following the backend's PDF layout, so the
      // canvas shows exactly what prints.
      content = CardTextLayer(
        group: group,
        pxPerMm: pxPerMm,
        emptyText: group.isList ? '(${group.name}: add fields)' : group.name,
      );
    }

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => controller.selectLayer(side, group.id),
        onPanStart: (_) => controller.selectLayer(side, group.id),
        onPanUpdate: (details) => controller.moveGroup(
          group.id,
          details.delta.dx / pxPerMm,
          details.delta.dy / pxPerMm,
        ),
        // No padding or border around the content: the layer's top-left is exactly (x, y), as
        // in the PDF. The selection outline is painted over the content instead of around it.
        child: Container(
          foregroundDecoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 1,
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}

class _PropertiesPanel extends StatefulWidget {
  const _PropertiesPanel({
    super.key,
    required this.group,
    required this.sampleFields,
    required this.otherLayers,
    required this.onMergeLayer,
    required this.onChanged,
    required this.onDelete,
  });

  final LayerGroup group;
  final List<ExtractedField> sampleFields;
  final List<LayerGroup> otherLayers;
  final void Function(String otherId) onMergeLayer;
  final void Function(LayerGroup Function(LayerGroup current) update) onChanged;
  final VoidCallback onDelete;

  @override
  State<_PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<_PropertiesPanel> {
  late TextEditingController _nameCtrl;
  late TextEditingController _keyCtrl;
  late TextEditingController _valueCtrl;

  @override
  void initState() {
    super.initState();
    final source = widget.group.sources.isNotEmpty
        ? widget.group.sources.first
        : null;
    _nameCtrl = TextEditingController(text: widget.group.name);
    _keyCtrl = TextEditingController(text: source?.key ?? '');
    _valueCtrl = TextEditingController(text: source?.value ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _keyCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  LayerSourceItem _firstSourceOrDefault(LayerGroup g) => g.sources.isNotEmpty
      ? g.sources.first
      : LayerSourceItem(type: g.fieldType);

  void _updateFirstSource(LayerSourceItem Function(LayerSourceItem) update) {
    widget.onChanged((g) {
      final source = update(_firstSourceOrDefault(g));
      return g.copyWith(sources: [source, ...g.sources.skip(1)]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    // A Material (not a colored Container) so the switch tiles' ink shows.
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Layer properties',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Common settings first: the name (twice as wide as a number box) and the numbers in
            // one row, then the toggles.
            _CollapsibleSection(
              title: 'General properties',
              child: _ResponsiveGrid(
                columns: 8,
                minColumnWidth: 100,
                children: [
                  _GridSpan(
                    span: 2,
                    child: TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Layer name',
                      ),
                      onChanged: (v) =>
                          widget.onChanged((g) => g.copyWith(name: v)),
                    ),
                  ),
                  if (group.fieldType == LayerFieldType.text) ...[
                    _NumberField(
                      label: 'Font (pt)',
                      step: 1,
                      value: group.fontSizePt,
                      onChanged: (v) =>
                          widget.onChanged((g) => g.copyWith(fontSizePt: v)),
                    ),
                    _NumberField(
                      label: 'Wrap width (mm)',
                      value: group.widthMm ?? 30,
                      onChanged: (v) =>
                          widget.onChanged((g) => g.copyWith(widthMm: v)),
                    ),
                    _NumberField(
                      label: 'Key width (mm)',
                      value: group.keyWidthMm,
                      onChanged: (v) =>
                          widget.onChanged((g) => g.copyWith(keyWidthMm: v)),
                      onCleared: () =>
                          widget.onChanged((g) => g.copyWith(keyWidthMm: null)),
                    ),
                    if (group.isList)
                      _NumberField(
                        label: 'Line gap (mm)',
                        value: group.lineGapMm,
                        onChanged: (v) =>
                            widget.onChanged((g) => g.copyWith(lineGapMm: v)),
                      ),
                  ] else ...[
                    _NumberField(
                      label: 'Width (mm)',
                      value: group.widthMm ?? 20,
                      onChanged: (v) =>
                          widget.onChanged((g) => g.copyWith(widthMm: v)),
                    ),
                    _NumberField(
                      label: 'Height (mm)',
                      value: group.heightMm ?? 20,
                      onChanged: (v) =>
                          widget.onChanged((g) => g.copyWith(heightMm: v)),
                    ),
                  ],
                  _NumberField(
                    label: 'X (mm)',
                    value: group.xMm,
                    onChanged: (v) =>
                        widget.onChanged((g) => g.copyWith(xMm: v)),
                  ),
                  _NumberField(
                    label: 'Y (mm)',
                    value: group.yMm,
                    onChanged: (v) =>
                        widget.onChanged((g) => g.copyWith(yMm: v)),
                  ),
                  if (group.fieldType == LayerFieldType.text) ...[
                    _GridSpan(
                      span: 2,
                      child: _alignedToInputs(
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Combine several fields'),
                          value: group.isList,
                          onChanged: (v) =>
                              widget.onChanged((g) => g.copyWith(isList: v)),
                        ),
                      ),
                    ),
                    _alignedToInputs(
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Bold (B)'),
                        value: group.bold,
                        onChanged: (v) =>
                            widget.onChanged((g) => g.copyWith(bold: v)),
                      ),
                    ),
                    if (group.isList)
                      _alignedToInputs(
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('List (L)'),
                          value: group.bulletList,
                          onChanged: (v) => widget.onChanged(
                            (g) => g.copyWith(bulletList: v),
                          ),
                        ),
                      ),
                    _GridSpan(
                      span: 2,
                      child: RemoveWordsEditor(
                        words: group.removeWords,
                        onChanged: (words) => widget.onChanged(
                          (g) => g.copyWith(removeWords: words),
                        ),
                      ),
                    ),
                    _GridSpan(
                      span: 2,
                      child: DateFormatEditor(
                        key: ValueKey('date-format-${group.id}'),
                        format: group.dateFormat,
                        onChanged: (format) => widget.onChanged(
                          (g) => g.copyWith(dateFormat: format),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (group.fieldType == LayerFieldType.text) ...[
              const SizedBox(height: 12),
              _CollapsibleSection(
                title: 'Fields',
                child: group.isList
                    ? _CombinedFieldsEditor(
                        group: group,
                        sampleFields: widget.sampleFields,
                        otherLayers: widget.otherLayers,
                        onMergeLayer: widget.onMergeLayer,
                        onChanged: widget.onChanged,
                      )
                    : _ResponsiveGrid(
                        children: [
                          TextField(
                            controller: _keyCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Key (label before the value)',
                            ),
                            onChanged: (v) =>
                                _updateFirstSource((s) => s.copyWith(key: v)),
                          ),
                          _PdfFieldPicker(
                            value: _firstSourceOrDefault(group).sourceKey,
                            fields: widget.sampleFields,
                            isFixedText:
                                (_firstSourceOrDefault(group).key ?? '')
                                    .trim()
                                    .isEmpty &&
                                (_firstSourceOrDefault(group).sourceKey ?? '')
                                    .isEmpty,
                            onChanged: (v) => _updateFirstSource(
                              (s) => s.copyWith(sourceKey: v),
                            ),
                          ),
                          TextField(
                            controller: _valueCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Sample value',
                            ),
                            onChanged: (v) =>
                                _updateFirstSource((s) => s.copyWith(value: v)),
                          ),
                        ],
                      ),
              ),
            ] else if (group.isQr)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Empty QR code image. The image itself is chosen in the card generator; '
                  'it is stretched to the width and height above.',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A titled part of the properties panel with a button to fold it away. The content stays
/// mounted while folded, so nothing typed inside it is lost.
class _CollapsibleSection extends StatefulWidget {
  const _CollapsibleSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _collapsed = !_collapsed),
          child: Row(
            children: [
              IconButton(
                tooltip: _collapsed
                    ? 'Expand ${widget.title}'
                    : 'Collapse ${widget.title}',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  _collapsed ? Icons.chevron_right : Icons.expand_more,
                ),
                onPressed: () => setState(() => _collapsed = !_collapsed),
              ),
              Text(widget.title, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
        Offstage(offstage: _collapsed, child: widget.child),
      ],
    );
  }
}

/// Marks a child of [_ResponsiveGrid] that is [span] columns wide.
class _GridSpan extends StatelessWidget {
  const _GridSpan({required this.span, required this.child});

  final int span;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Lays its children out in rows of up to [columns], each the same width; on a narrow panel
/// there are fewer columns so a field never gets squeezed below [minColumnWidth].
class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({
    required this.children,
    this.columns = 4,
    this.minColumnWidth = 170,
  });

  final List<Widget> children;
  final int columns;
  final double minColumnWidth;

  static const spacing = 12.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        var count = columns;
        while (count > 1 &&
            (available - spacing * (count - 1)) / count < minColumnWidth) {
          count--;
        }
        final width = (available - spacing * (count - 1)) / count;
        return Wrap(
          spacing: spacing,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            for (final c in children)
              SizedBox(
                width: c is _GridSpan
                    ? width * (c.span < count ? c.span : count) +
                          spacing * ((c.span < count ? c.span : count) - 1)
                    : width,
                child: c is _GridSpan ? c.child : c,
              ),
          ],
        );
      },
    );
  }
}

/// A toggle sitting in the grid beside editors that have a title above their text box: pushed
/// down so it lines up with those text boxes rather than with their titles.
Widget _alignedToInputs(Widget toggle) =>
    Padding(padding: const EdgeInsets.only(top: 26), child: toggle);

/// A numeric input with up/down buttons (and mouse-wheel support). Applies every
/// change immediately - typing, the buttons, or the wheel - so the canvas updates
/// live.
class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.onCleared,
    this.step = 0.5,
  });

  final String label;
  final double? value;
  final ValueChanged<double> onChanged;

  /// When set, the field is optional: clearing the text calls this (value = null).
  final VoidCallback? onCleared;
  final double step;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _ctrl = TextEditingController(
    text: _format(widget.value),
  );

  static String _format(double? v) => v == null ? '' : v.toStringAsFixed(1);

  @override
  void didUpdateWidget(_NumberField old) {
    super.didUpdateWidget(old);
    // Sync when the value changed from outside (e.g. dragging the layer on the
    // canvas) but never fight what's being typed.
    final typed = double.tryParse(_ctrl.text);
    final external = widget.value;
    if (external == null) {
      if (typed != null && _ctrl.text.isNotEmpty && widget.onCleared != null)
        return;
      if (_ctrl.text.isNotEmpty) _ctrl.text = '';
    } else if (typed == null || (typed - external).abs() > 0.05) {
      _ctrl.text = _format(external);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _nudge(int direction) {
    final base = double.tryParse(_ctrl.text) ?? widget.value ?? 0;
    final next = (base + direction * widget.step)
        .clamp(0, double.infinity)
        .toDouble();
    _ctrl.text = _format(next);
    widget.onChanged(double.parse(_format(next)));
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent && FocusScope.of(context).hasFocus) {
          _nudge(event.scrollDelta.dy < 0 ? 1 : -1);
        }
      },
      child: TextField(
        controller: _ctrl,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: SizedBox(
            width: 32,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SpinButton(
                  icon: Icons.keyboard_arrow_up,
                  onTap: () => _nudge(1),
                ),
                _SpinButton(
                  icon: Icons.keyboard_arrow_down,
                  onTap: () => _nudge(-1),
                ),
              ],
            ),
          ),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (v) {
          if (v.trim().isEmpty && widget.onCleared != null) {
            widget.onCleared!();
            return;
          }
          final parsed = double.tryParse(v);
          if (parsed != null && parsed >= 0) widget.onChanged(parsed);
        },
      ),
    );
  }
}

class _SpinButton extends StatelessWidget {
  const _SpinButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(height: 18, width: 32, child: Icon(icon, size: 18)),
  );
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

/// Edits a combined (List) layer: the separator that joins its fields, and the
/// fields themselves. Each field has a key (used to match the member's PDF, and
/// printed before the value unless empty) and a value, which is always printed, plus
/// its own separator to the next field.
/// Fields can be added blank, from the sample PDF, or by merging in a layer already
/// on the canvas.
class _CombinedFieldsEditor extends StatelessWidget {
  const _CombinedFieldsEditor({
    required this.group,
    required this.sampleFields,
    required this.otherLayers,
    required this.onMergeLayer,
    required this.onChanged,
  });

  final LayerGroup group;
  final List<ExtractedField> sampleFields;
  final List<LayerGroup> otherLayers;
  final void Function(String otherId) onMergeLayer;
  final void Function(LayerGroup Function(LayerGroup current) update) onChanged;

  void _addSource(LayerSourceItem item) =>
      onChanged((g) => g.copyWith(sources: [...g.sources, item]));

  void _updateAt(int index, LayerSourceItem Function(LayerSourceItem) update) =>
      onChanged(
        (g) => g.copyWith(
          sources: [
            for (var i = 0; i < g.sources.length; i++)
              if (i == index) update(g.sources[i]) else g.sources[i],
          ],
        ),
      );

  void _removeAt(int index) => onChanged(
    (g) => g.copyWith(
      sources: [
        for (var i = 0; i < g.sources.length; i++)
          if (i != index) g.sources[i],
      ],
    ),
  );

  void _onAddSelected(Object choice) {
    if (choice is ExtractedField) {
      _addSource(LayerSourceItem(key: choice.key, value: choice.value));
    } else if (choice is LayerGroup) {
      onMergeLayer(choice.id);
    } else if (choice == 'emptyline') {
      _addSource(const LayerSourceItem(emptyLine: true));
    } else {
      _addSource(const LayerSourceItem(key: '', value: ''));
    }
  }

  String _layerLabel(LayerGroup g) {
    final source = g.sources.isNotEmpty ? g.sources.first : null;
    return '${g.name}: ${source?.key ?? ''} = ${source?.value ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    final textFields = [
      for (final f in sampleFields)
        if (f.type == LayerFieldType.text) f,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                '${group.sources.length} in this group',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            PopupMenuButton<Object>(
              tooltip: 'Add a field to this group',
              onSelected: _onAddSelected,
              itemBuilder: (_) => [
                const PopupMenuItem<Object>(
                  value: 'blank',
                  child: Text('Blank field (type key and value)'),
                ),
                const PopupMenuItem<Object>(
                  value: 'emptyline',
                  child: Text('Empty line'),
                ),
                if (textFields.isNotEmpty) ...[
                  const PopupMenuDivider(),
                  const PopupMenuItem<Object>(
                    enabled: false,
                    child: Text('From the sample PDF'),
                  ),
                  for (final f in textFields)
                    PopupMenuItem<Object>(
                      value: f,
                      child: Text(
                        '${f.key ?? ''}: ${f.value ?? ''}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                if (otherLayers.isNotEmpty) ...[
                  const PopupMenuDivider(),
                  const PopupMenuItem<Object>(
                    enabled: false,
                    child: Text('Merge an existing layer'),
                  ),
                  for (final l in otherLayers)
                    PopupMenuItem<Object>(
                      value: l,
                      child: Text(
                        _layerLabel(l),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ],
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline, size: 18),
                    SizedBox(width: 4),
                    Text('Add field'),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Each field is one row of four columns: key, value, read from, join with.
        for (var i = 0; i < group.sources.length; i++)
          Padding(
            // Keyed on the field count so rows rebuild (with the right text) after an
            // add/remove, but keep focus while typing.
            key: ValueKey('${group.sources.length}-$i'),
            padding: const EdgeInsets.only(bottom: 8),
            child: group.sources[i].emptyLine
                ? Row(
                    children: [
                      const Icon(Icons.space_bar, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Empty line')),
                      IconButton(
                        tooltip: 'Remove empty line',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => _removeAt(i),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ResponsiveGrid(
                          children: [
                            TextFormField(
                              initialValue: group.sources[i].key ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Key (label)',
                                isDense: true,
                              ),
                              onChanged: (v) =>
                                  _updateAt(i, (s) => s.copyWith(key: v)),
                            ),
                            TextFormField(
                              initialValue: group.sources[i].value ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Value',
                                isDense: true,
                              ),
                              onChanged: (v) =>
                                  _updateAt(i, (s) => s.copyWith(value: v)),
                            ),
                            _PdfFieldPicker(
                              value: group.sources[i].sourceKey,
                              fields: sampleFields,
                              isFixedText:
                                  (group.sources[i].key ?? '').trim().isEmpty &&
                                  (group.sources[i].sourceKey ?? '').isEmpty,
                              onChanged: (v) =>
                                  _updateAt(i, (s) => s.copyWith(sourceKey: v)),
                            ),
                            if (i < group.sources.length - 1)
                              DropdownButtonFormField<String>(
                                initialValue:
                                    (JoinSeparator.tryFromWireName(
                                              group.sources[i].separator,
                                            ) ??
                                            JoinSeparator.comma)
                                        .wireName,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Join with next field',
                                  isDense: true,
                                ),
                                items: [
                                  for (final s in JoinSeparator.values)
                                    DropdownMenuItem<String>(
                                      value: s.wireName,
                                      child: Text(s.label),
                                    ),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    _updateAt(
                                      i,
                                      (s) => s.copyWith(separator: v),
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove field',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => _removeAt(i),
                      ),
                    ],
                  ),
          ),
      ],
    );
  }
}

/// Which field of the member's PDF a layer field reads its value from. By default the key
/// itself is looked up; choosing another field lets the key stay empty (value only on the
/// card) or read differently, without breaking the link to the PDF. A field with neither a
/// key nor a PDF field is fixed text and always prints what is typed.
class _PdfFieldPicker extends StatelessWidget {
  const _PdfFieldPicker({
    required this.value,
    required this.fields,
    required this.isFixedText,
    required this.onChanged,
  });

  final String? value;
  final List<ExtractedField> fields;
  final bool isFixedText;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final keys = <String>{
      for (final f in fields)
        if (f.type == LayerFieldType.text && (f.key ?? '').trim().isNotEmpty)
          f.key!.trim(),
      if ((value ?? '').isNotEmpty) value!,
    }.toList();

    return DropdownButtonFormField<String?>(
      initialValue: (value ?? '').isEmpty ? null : value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Read from PDF field',
        isDense: true,
        helperText: isFixedText ? 'Fixed text: not read from the PDF' : null,
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Same as key'),
        ),
        for (final k in keys)
          DropdownMenuItem<String?>(
            value: k,
            child: Text(k, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

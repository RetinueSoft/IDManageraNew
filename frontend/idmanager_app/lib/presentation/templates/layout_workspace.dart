import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core_engine/common/enums.dart';
import '../../core_engine/templates/domain/field_group.dart';
import '../../core_engine/templates/domain/template_layer.dart';
import '../shared/widgets/card_text_layer.dart';
import '../shared/widgets/zoomable_canvas.dart';
import 'collapsible_panel.dart';
import 'layer_properties_panel.dart';

/// What the canvas shows.
enum EditorView { combined, front, back }

/// The template designer's working area, shared with the card generator so the two look and
/// behave the same: the Front + Back / Front / Back switch, the zoomable canvas with the
/// cards (draggable layers), and the docked, resizable Layer properties panel underneath.
///
/// [designer] is the template designer. Without it (the card generator) the layer name and
/// the field keys are read-only and the controls that change the template's structure are
/// hidden - adding/removing fields, combining fields, words to remove and the date format.
class LayoutWorkspace extends StatelessWidget {
  const LayoutWorkspace({
    super.key,
    required this.designer,
    required this.layers,
    required this.cardWidthMm,
    required this.cardHeightMm,
    required this.frontImageBase64,
    required this.backImageBase64,
    required this.side,
    required this.combined,
    required this.selectedGroupId,
    required this.onSelectView,
    required this.onSelectLayer,
    required this.onMoveGroup,
    required this.onChanged,
    required this.onDelete,
    this.sampleFields = const [],
    this.onMergeLayer,
    this.topBar,
  });

  final bool designer;
  final List<TemplateLayer> layers;
  final double cardWidthMm;
  final double cardHeightMm;
  final String frontImageBase64;
  final String backImageBase64;

  /// The side edits go to (in the combined view, the side last clicked).
  final CardSide side;
  final bool combined;
  final String? selectedGroupId;

  final ValueChanged<EditorView> onSelectView;

  /// A click on a layer, or on empty card when the id is null.
  final void Function(CardSide side, String? groupId) onSelectLayer;
  final void Function(String groupId, double dxMm, double dyMm) onMoveGroup;
  final void Function(String groupId, LayerGroup Function(LayerGroup) update)
  onChanged;
  final VoidCallback onDelete;

  /// The fields of the template's sample PDF (designer only).
  final List<ExtractedField> sampleFields;
  final void Function(String groupId, String otherId)? onMergeLayer;

  /// Shown under the view switch - the background picker.
  final Widget? topBar;

  /// Screen pixels per millimeter at 100%. Flutter rounds each text line's height to a whole
  /// pixel, so the card is laid out at a fine scale (the error is at most half a pixel = 0.04 mm
  /// per line) and then zoomed as a view transform, keeping the screen within a hair of the PDF.
  static const double pxPerMm = 12.0;

  /// Space between the front and back cards in the combined view.
  static const double _cardGapPx = 2 * pxPerMm;

  List<LayerGroup> _groupsOf(CardSide s) {
    for (final l in layers) {
      if (l.side == s) return l.groups;
    }
    return const [];
  }

  LayerGroup? get _selectedGroup {
    final id = selectedGroupId;
    if (id == null) return null;
    for (final g in _groupsOf(side)) {
      if (g.id == id) return g;
    }
    return null;
  }

  static Uint8List _decodeImage(String base64Str) =>
      base64Str.isEmpty ? Uint8List(0) : base64Decode(base64Str);

  @override
  Widget build(BuildContext context) {
    final cardWidthPx = cardWidthMm * pxPerMm;
    final cardHeightPx = cardHeightMm * pxPerMm;
    // The cards on show: front and back side by side (the default), or just one.
    final sides = combined ? CardSide.values : [side];
    final canvasWidthPx =
        cardWidthPx * sides.length + _cardGapPx * (sides.length - 1);
    final selected = _selectedGroup;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SegmentedButton<EditorView>(
            segments: const [
              ButtonSegment(
                value: EditorView.combined,
                label: Text('Front + Back'),
              ),
              ButtonSegment(value: EditorView.front, label: Text('Front')),
              ButtonSegment(value: EditorView.back, label: Text('Back')),
            ],
            selected: {
              combined
                  ? EditorView.combined
                  : (side == CardSide.front
                        ? EditorView.front
                        : EditorView.back),
            },
            onSelectionChanged: (v) => onSelectView(v.first),
          ),
        ),
        if (topBar != null) topBar!,
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
          child: selected == null
              ? const Center(
                  child: Text('Select a layer to edit its properties'),
                )
              : LayerPropertiesPanel(
                  key: ValueKey(selected.id),
                  designer: designer,
                  group: selected,
                  sampleFields: sampleFields,
                  otherLayers: [
                    for (final g in _groupsOf(side))
                      if (g.id != selected.id &&
                          g.fieldType == LayerFieldType.text &&
                          !g.isList)
                        g,
                  ],
                  onMergeLayer: (otherId) =>
                      onMergeLayer?.call(selected.id, otherId),
                  onChanged: (update) => onChanged(selected.id, update),
                  onDelete: onDelete,
                ),
        ),
      ],
    );
  }

  /// One card of the canvas: its background image and that side's layers. Clicking a layer (or
  /// the empty card) makes this the side that edits go to.
  Widget _buildCard(CardSide cardSide, double widthPx, double heightPx) {
    final imageBytes = _decodeImage(
      cardSide == CardSide.front ? frontImageBase64 : backImageBase64,
    );
    return GestureDetector(
      onTap: () => onSelectLayer(cardSide, null),
      child: Container(
        width: widthPx,
        height: heightPx,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          color: Colors.white,
          boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (imageBytes.isNotEmpty)
              Positioned.fill(
                child: Image.memory(imageBytes, fit: BoxFit.fill),
              ),
            for (final group in _groupsOf(cardSide))
              _buildLayerWidget(cardSide, group),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerWidget(CardSide cardSide, LayerGroup group) {
    final isSelected = group.id == selectedGroupId;

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
      // The same widget the PDF layout is drawn from, so the canvas shows what prints.
      content = CardTextLayer(
        group: group,
        pxPerMm: pxPerMm,
        emptyText: designer
            ? (group.isList ? '(${group.name}: add fields)' : group.name)
            : null,
      );
    }

    return Positioned(
      left: group.xMm * pxPerMm,
      top: group.yMm * pxPerMm,
      child: GestureDetector(
        onTap: () => onSelectLayer(cardSide, group.id),
        onPanStart: (_) => onSelectLayer(cardSide, group.id),
        onPanUpdate: (details) => onMoveGroup(
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

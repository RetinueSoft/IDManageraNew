import 'package:flutter/material.dart';

import '../../../core_engine/common/enums.dart';
import '../../../core_engine/templates/domain/template_layer.dart';
import '../../../core_engine/templates/domain/value_cleaner.dart';
import 'card_text.dart';
import 'combined_layer_text.dart';

/// Draws any text layer - a single field (plain, "key: value", or with a key column) or a
/// combined (List) layer - the way the backend prints it. The designer canvas and the card
/// preview both use this, so they cannot drift from each other or from the PDF.
///
/// Like the PDF, the layer's fields are stacked top to bottom, each at least the layer's
/// line height (LineHeightMm) tall, all wrapped at the layer's width.
class CardTextLayer extends StatelessWidget {
  const CardTextLayer({super.key, required this.group, required this.pxPerMm, this.emptyText});

  final LayerGroup group;
  final double pxPerMm;

  /// Shown when the layer has no text (designer only).
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    if (group.isList) {
      return CombinedLayerText(group: group, pxPerMm: pxPerMm, emptyText: emptyText);
    }

    Widget line(String text) => CardText.text(text, group: group, pxPerMm: pxPerMm);
    final widthPx = CardText.widthPx(group, pxPerMm);
    final minRowPx = group.lineHeightMm * pxPerMm;
    final separator = group.useDashSeparator ? '-' : ':';
    final keyWidth = group.keyWidthMm ?? 0;

    final rows = <Widget>[];
    for (final source in group.sources) {
      if (source.type != LayerFieldType.text) continue;
      final key = source.key ?? '';
      // The layer's words to remove are taken out of the value (never the key), as in the PDF.
      final value = removeWordsFrom(source.value ?? '', group.removeWords);

      final Widget row;
      if (key.isEmpty) {
        row = line(value);
      } else if (keyWidth <= 0) {
        // No key width: the separator and value follow immediately after the key.
        row = line('$key$separator $value');
      } else {
        // Key width set: the separator starts at layer x + key width, then the value.
        row = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: keyWidth * pxPerMm, child: line(key)),
            SizedBox(width: CardText.separatorWidthPx(group, pxPerMm), child: line(separator)),
            SizedBox(width: CardText.valueWidthPx(group, pxPerMm), child: line(value)),
          ],
        );
      }
      rows.add(ConstrainedBox(constraints: BoxConstraints(minHeight: minRowPx), child: row));
    }

    if (rows.isEmpty) return SizedBox(width: widthPx, child: line(emptyText ?? group.name));

    return SizedBox(
      width: widthPx,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core_engine/templates/domain/layer_text.dart';
import '../../../core_engine/templates/domain/template_layer.dart';
import 'card_text.dart';

/// Draws a combined (List) text layer - on the designer canvas and the card preview.
///
/// Normally that is just [LayerGroupText.combinedText]. A layer with a key width instead
/// draws one row per field: the key (with a bullet if List is on) in a fixed-width column,
/// then the separator, then the value, so the separators and values line up.
///
/// Fonts, line height and column widths come from [CardText], which follows the backend's
/// PdfGenerationService, so what is drawn here is what prints.
class CombinedLayerText extends StatelessWidget {
  const CombinedLayerText({super.key, required this.group, required this.pxPerMm, this.emptyText});

  final LayerGroup group;
  final double pxPerMm;

  /// Shown instead of an empty layer (designer only).
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    Widget line(String text) => CardText.text(text, group: group, pxPerMm: pxPerMm);
    final widthPx = CardText.widthPx(group, pxPerMm);

    if (!group.hasAlignedKeys) {
      final text = group.combinedText;
      return SizedBox(width: widthPx, child: line(text.isEmpty && emptyText != null ? emptyText! : text));
    }

    final rows = group.bulletRows;
    if (rows.isEmpty && emptyText != null) {
      return SizedBox(width: widthPx, child: line(emptyText!));
    }

    final keyPx = group.keyWidthMm! * pxPerMm;
    final sepPx = CardText.separatorWidthPx(group, pxPerMm);
    final valuePx = CardText.valueWidthPx(group, pxPerMm);
    final separator = group.useDashSeparator ? '-' : ':';
    final bullet = group.bulletList ? '• ' : '';

    return SizedBox(
      width: widthPx,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in rows)
            if (row.isBlank)
              SizedBox(height: CardText.lineHeightPx(group, pxPerMm))
            else if (row.key.isEmpty)
              SizedBox(width: widthPx, child: line('$bullet${row.value}'))
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: keyPx, child: line('$bullet${row.key}')),
                  SizedBox(width: sepPx, child: line(separator)),
                  SizedBox(width: valuePx, child: line(row.value)),
                ],
              ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core_engine/templates/domain/template_layer.dart';

/// How card text is drawn on screen - the designer canvas and the card preview - chosen so
/// it matches what the backend prints (PdfGenerationService) line for line:
///
/// * the same fonts: Noto Sans for Latin, Noto Sans Tamil for Tamil (bundled in
///   assets/fonts, the same files the backend embeds), so glyphs and widths agree;
/// * the same line box: each line is exactly [lineHeightFactor] x the font size (plus a
///   combined layer's line gap), with the extra space split evenly above and below the
///   glyphs, measured from Noto Sans - so the baseline lands where the PDF puts it.
class CardText {
  CardText._();

  static const String latinFamily = 'NotoSans';
  static const String tamilFamily = 'NotoSansTamil';

  /// 1 point in millimeters (72 points per inch, 25.4 mm per inch).
  static const double pointsToMm = 25.4 / 72;

  /// Normal line height as a multiple of the font size - must match
  /// PdfGenerationService.LineHeightFactor.
  static const double lineHeightFactor = 1.2;

  /// The separator column of an aligned list, as a fraction of the font size - must match
  /// PdfGenerationService.SeparatorWidthFactor.
  static const double separatorWidthFactor = 0.6;

  /// The width a text layer wraps at when it has none - must match the backend's default.
  static const double defaultWidthMm = 30;

  static double fontPx(LayerGroup group, double pxPerMm) => group.fontSizePt * pointsToMm * pxPerMm;

  static double widthPx(LayerGroup group, double pxPerMm) => (group.widthMm ?? defaultWidthMm) * pxPerMm;

  /// The height of one line of a layer: a normal line height, plus (for a combined layer)
  /// its common line gap.
  static double lineHeightPx(LayerGroup group, double pxPerMm) =>
      fontPx(group, pxPerMm) * lineHeightFactor + (group.isList ? group.lineGapMm * pxPerMm : 0);

  static double separatorWidthPx(LayerGroup group, double pxPerMm) =>
      fontPx(group, pxPerMm) * separatorWidthFactor;

  /// The value column of an aligned row: the layer's own value width if it has one, else
  /// whatever is left of the layer's width (at least 10 points).
  static double valueWidthPx(LayerGroup group, double pxPerMm) {
    final own = (group.valueWidthMm ?? 0) * pxPerMm;
    if (own > 0) return own;
    final left = widthPx(group, pxPerMm) - (group.keyWidthMm ?? 0) * pxPerMm - separatorWidthPx(group, pxPerMm);
    final minimum = 10 * pointsToMm * pxPerMm;
    return left > minimum ? left : minimum;
  }

  static TextStyle style({required double fontPx, required bool bold, required double lineHeightPx}) => TextStyle(
    fontFamily: latinFamily,
    fontFamilyFallback: const [tamilFamily],
    fontSize: fontPx,
    fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    height: lineHeightPx / fontPx,
    leadingDistribution: TextLeadingDistribution.even,
    color: Colors.black,
    decoration: TextDecoration.none,
  );

  /// Forces every line to the strut's box (Noto Sans metrics), so a line that contains
  /// Tamil is not taller than one that does not - the PDF lays every line out the same way.
  static StrutStyle strut({required double fontPx, required double lineHeightPx}) => StrutStyle(
    fontFamily: latinFamily,
    fontFamilyFallback: const [tamilFamily],
    fontSize: fontPx,
    height: lineHeightPx / fontPx,
    leadingDistribution: TextLeadingDistribution.even,
    forceStrutHeight: true,
  );

  /// One block of wrapped card text.
  static Widget text(String text, {required LayerGroup group, required double pxPerMm}) {
    final font = fontPx(group, pxPerMm);
    final line = lineHeightPx(group, pxPerMm);
    return Text(
      text,
      softWrap: true,
      style: style(fontPx: font, bold: group.bold, lineHeightPx: line),
      strutStyle: strut(fontPx: font, lineHeightPx: line),
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A watermark laid over a card preview: [text] repeated in slanted rows across the whole card,
/// on top of everything. It is there so a screenshot or a photo of the preview is marked - with
/// who was previewing and when - and not usable as the real card. The printed PDF has none.
///
/// It takes no taps (it sits in an [IgnorePointer]), so the layers under it can still be selected
/// and dragged, and it scales with the card, so zooming in never gets past it.
class PreviewWatermark extends StatelessWidget {
  const PreviewWatermark({super.key, required this.text, this.opacity = 0.2});

  final String text;

  /// How strong the marks are, 0-1. Enough to show on any background, light or dark, without
  /// hiding what is on the card.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) => CustomPaint(
          key: const ValueKey('preview-watermark'),
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: WatermarkPainter(text: text, opacity: opacity),
        ),
      ),
    );
  }
}

/// Draws the repeated, slanted text of a [PreviewWatermark].
class WatermarkPainter extends CustomPainter {
  WatermarkPainter({required this.text, required this.opacity});

  final String text;
  final double opacity;

  /// The slant of the rows, in radians (a little under 30 degrees, rising to the right).
  static const double angle = -0.5;

  /// The text is this fraction of the card's shorter side tall, so it looks the same on any card size.
  static const double sizeFactor = 0.075;

  /// Rows of marks are this many text heights apart, and each row is shifted half a step from the
  /// one above - so nothing on the card is far from a mark, and a crop still catches some.
  static const double rowSpacing = 2.6;

  /// The rows the marks are laid on, as the (x, y) of each text start before the slant is applied,
  /// for a card of [size] and text of [textWidth] x [textHeight]. Public so it can be tested.
  static List<Offset> positions(
    Size size,
    double textWidth,
    double textHeight,
  ) {
    final stepX = textWidth + textHeight * 1.2;
    final stepY = textHeight * rowSpacing;
    // After rotating, the marks must still cover the corners: lay them over the card's diagonal.
    final reach = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    final spots = <Offset>[];
    var row = 0;
    for (var y = -reach; y <= reach; y += stepY, row++) {
      final shift = row.isOdd ? stepX / 2 : 0.0;
      for (var x = -reach - stepX; x <= reach; x += stepX) {
        spots.add(Offset(x + shift, y));
      }
    }
    return spots;
  }

  TextPainter _painter(double fontSize, Paint paint) => TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: fontSize * 0.08,
        foreground: paint,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    if (text.trim().isEmpty || size.isEmpty) return;

    final fontSize = math.min(size.width, size.height) * sizeFactor;
    // A light edge under dark letters: readable over a dark background as well as a light one.
    final outline = _painter(
      fontSize,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = fontSize * 0.12
        ..color = Colors.white.withValues(alpha: opacity * 1.4),
    );
    final fill = _painter(
      fontSize,
      Paint()..color = Colors.black.withValues(alpha: opacity * 1.6),
    );

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(angle);
    for (final at in positions(size, fill.width, fill.height)) {
      outline.paint(canvas, at);
      fill.paint(canvas, at);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(WatermarkPainter old) =>
      old.text != text || old.opacity != opacity;
}

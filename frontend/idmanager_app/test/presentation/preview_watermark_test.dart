import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/common/enums.dart';
import 'package:idmanager_app/core_engine/templates/domain/template_layer.dart';
import 'package:idmanager_app/presentation/cards/generate_card_screen.dart' show previewWatermarkText;
import 'package:idmanager_app/presentation/shared/widgets/preview_watermark.dart';
import 'package:idmanager_app/presentation/templates/layout_workspace.dart';

void main() {
  group('previewWatermarkText', () {
    test('says PREVIEW, who is previewing and the date', () {
      expect(
        previewWatermarkText(name: 'Ravi', phone: '9943135008', date: DateTime(2026, 9, 20)),
        'PREVIEW   Ravi   9943135008   20 Sep 2026',
      );
    });

    test('leaves out a name or phone that is missing', () {
      expect(previewWatermarkText(name: '  ', phone: '', date: DateTime(2026, 1, 5)), 'PREVIEW   5 Jan 2026');
      expect(previewWatermarkText(name: 'Ravi', phone: '', date: DateTime(2026, 12, 31)), 'PREVIEW   Ravi   31 Dec 2026');
    });
  });

  group('WatermarkPainter.positions', () {
    const size = Size(1000, 630);
    const textWidth = 500.0, textHeight = 40.0;

    test('rows are evenly spaced, and every other row is shifted half a step', () {
      final spots = WatermarkPainter.positions(size, textWidth, textHeight);
      final rows = spots.map((o) => o.dy).toSet().toList()..sort();

      final stepY = textHeight * WatermarkPainter.rowSpacing;
      for (var i = 1; i < rows.length; i++) {
        expect(rows[i] - rows[i - 1], closeTo(stepY, 0.001));
      }
      final stepX = textWidth + textHeight * 1.2;
      double firstX(double y) => (spots.where((o) => o.dy == y).map((o) => o.dx).toList()..sort()).first;
      expect((firstX(rows[1]) - firstX(rows[0])).abs() % stepX, anyOf(closeTo(stepX / 2, 0.001), closeTo(stepX / 2 - stepX, 0.001)));
    });

    test('the marks cover the whole card, corners included, even after the slant', () {
      final spots = WatermarkPainter.positions(size, textWidth, textHeight);
      final stepY = textHeight * WatermarkPainter.rowSpacing;
      final stepX = textWidth + textHeight * 1.2;
      final centre = Offset(size.width / 2, size.height / 2);
      final cosA = math.cos(-WatermarkPainter.angle), sinA = math.sin(-WatermarkPainter.angle);

      // Put a grid of points on the card into the slanted frame the marks are laid in, and ask
      // whether a mark's row runs close by and that row has a mark within one step along it.
      for (var x = 0.0; x <= size.width; x += 25) {
        for (var y = 0.0; y <= size.height; y += 25) {
          final dx = x - centre.dx, dy = y - centre.dy;
          final u = dx * cosA - dy * sinA; // along the rows
          final v = dx * sinA + dy * cosA; // across the rows
          final nearRow = spots.any((s) => (s.dy - v).abs() <= stepY / 2 && (s.dx - u).abs() <= stepX);
          expect(nearRow, isTrue, reason: 'no mark near ($x, $y)');
        }
      }
    });

    test('a bigger card gets more marks; nothing is laid out for no room', () {
      final small = WatermarkPainter.positions(const Size(500, 300), textWidth, textHeight).length;
      final large = WatermarkPainter.positions(const Size(2000, 1200), textWidth, textHeight).length;
      expect(large, greaterThan(small));
    });
  });

  group('PreviewWatermark', () {
    testWidgets('paints the text over the card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(width: 400, height: 250, child: PreviewWatermark(text: 'PREVIEW Ravi')),
        ),
      );

      final box = tester.renderObject(find.byKey(const ValueKey('preview-watermark')));
      expect(box, paints..paragraph());
      final painter = tester.widget<CustomPaint>(find.byKey(const ValueKey('preview-watermark'))).painter as WatermarkPainter;
      expect(painter.text, 'PREVIEW Ravi');
    });

    testWidgets('takes no taps: what is under it is still tapped', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              Positioned.fill(child: GestureDetector(onTap: () => taps++, child: const ColoredBox(color: Colors.white))),
              const Positioned.fill(child: PreviewWatermark(text: 'PREVIEW')),
            ],
          ),
        ),
      );

      await tester.tapAt(const Offset(200, 200));

      expect(taps, 1);
    });

    testWidgets('draws nothing for empty text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SizedBox(width: 400, height: 250, child: PreviewWatermark(text: '   '))),
      );

      expect(tester.renderObject(find.byKey(const ValueKey('preview-watermark'))), isNot(paints..paragraph()));
    });

    test('is repainted when the text changes, and not otherwise', () {
      final a = WatermarkPainter(text: 'A', opacity: 0.2);
      expect(a.shouldRepaint(WatermarkPainter(text: 'A', opacity: 0.2)), isFalse);
      expect(a.shouldRepaint(WatermarkPainter(text: 'B', opacity: 0.2)), isTrue);
      expect(a.shouldRepaint(WatermarkPainter(text: 'A', opacity: 0.3)), isTrue);
    });
  });

  group('LayoutWorkspace', () {
    const layer = LayerGroup(id: 'g', name: 'Name', xMm: 5, yMm: 5, sources: [LayerSourceItem(key: 'Name', value: 'Ravi')]);

    Future<List<(CardSide, String?)>> pumpWorkspace(WidgetTester tester, {String? watermark, bool combined = true}) async {
      tester.view.physicalSize = const Size(1800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final selected = <(CardSide, String?)>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutWorkspace(
              designer: watermark == null,
              watermark: watermark,
              layers: const [
                TemplateLayer(side: CardSide.front, groups: [layer]),
                TemplateLayer(side: CardSide.back),
              ],
              cardWidthMm: 85.6,
              cardHeightMm: 54,
              frontImageBase64: '',
              backImageBase64: '',
              side: CardSide.front,
              combined: combined,
              selectedGroupId: null,
              onSelectView: (_) {},
              onSelectLayer: (side, id) => selected.add((side, id)),
              onMoveGroup: (_, _, _) {},
              onChanged: (_, _) {},
              onDelete: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return selected;
    }

    testWidgets('a watermark is drawn on each card shown, above the layers', (tester) async {
      await pumpWorkspace(tester, watermark: 'PREVIEW Ravi');

      expect(find.byKey(const ValueKey('preview-watermark')), findsNWidgets(2));
      // ... and only one when one card is shown.
      await pumpWorkspace(tester, watermark: 'PREVIEW Ravi', combined: false);
      expect(find.byKey(const ValueKey('preview-watermark')), findsOneWidget);
    });

    testWidgets('without a watermark (the designer) nothing is drawn over the cards', (tester) async {
      await pumpWorkspace(tester);

      expect(find.byKey(const ValueKey('preview-watermark')), findsNothing);
    });

    testWidgets('a layer under the watermark can still be selected', (tester) async {
      final selected = await pumpWorkspace(tester, watermark: 'PREVIEW Ravi');

      await tester.tap(find.textContaining('Ravi'));
      await tester.pumpAndSettle();

      expect(selected, contains((CardSide.front, 'g')));
    });
  });
}

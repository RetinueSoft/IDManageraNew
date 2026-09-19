import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/presentation/shared/widgets/zoomable_canvas.dart';

double _scale(WidgetTester tester) =>
    tester.widget<InteractiveViewer>(find.byType(InteractiveViewer)).transformationController!.value.entry(0, 0);

Offset _translation(WidgetTester tester) {
  final t = tester.widget<InteractiveViewer>(find.byType(InteractiveViewer)).transformationController!.value.getTranslation();
  return Offset(t.x, t.y);
}

Future<void> _pump(WidgetTester tester, {Size card = const Size(334, 210), Size area = const Size(800, 600)}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox.fromSize(
            size: area,
            child: ZoomableCanvas(contentSize: card, child: Container(color: Colors.green)),
          ),
        ),
      ),
    ));

void main() {
  testWidgets('opens fitted to the window, centred, so the whole card is visible', (tester) async {
    await _pump(tester);
    await tester.pump(); // the post-frame fit

    // Width-limited: (800 - 2*24) / 334.
    final expected = (800 - 48) / 334;
    expect(_scale(tester), closeTo(expected, 0.001));
    // Centred: the scaled card leaves equal space on both sides.
    final t = _translation(tester);
    expect(t.dx, closeTo((800 - 334 * expected) / 2, 0.01));
    expect(t.dy, closeTo((600 - 210 * expected) / 2, 0.01));
  });

  testWidgets('a tall, narrow area fits by height instead', (tester) async {
    await _pump(tester, area: const Size(1000, 200));
    await tester.pump();

    expect(_scale(tester), closeTo((200 - 48) / 210, 0.001));
  });

  testWidgets('zoom in / zoom out change the scale, and fit brings it back', (tester) async {
    await _pump(tester);
    await tester.pump();
    final fitted = _scale(tester);

    await tester.tap(find.byTooltip('Zoom in'));
    await tester.pump();
    expect(_scale(tester), closeTo(fitted * 1.25, 0.001));

    await tester.tap(find.byTooltip('Zoom out'));
    await tester.tap(find.byTooltip('Zoom out'));
    await tester.pump();
    expect(_scale(tester), closeTo(fitted / 1.25, 0.001));

    await tester.tap(find.byTooltip('Fit to window'));
    await tester.pump();
    expect(_scale(tester), closeTo(fitted, 0.001));
  });

  testWidgets('a different card size starts fitted again', (tester) async {
    await _pump(tester);
    await tester.pump();

    await _pump(tester, card: const Size(500, 200));
    await tester.pump();
    await tester.pump();

    expect(_scale(tester), closeTo((800 - 48) / 500, 0.001));
  });

  testWidgets('zoom out stops at the minimum scale instead of shrinking forever', (tester) async {
    await _pump(tester);
    await tester.pump();

    for (var i = 0; i < 40; i++) {
      await tester.tap(find.byTooltip('Zoom out'));
    }
    await tester.pump();

    expect(_scale(tester), closeTo(0.1, 0.001));
  });
}

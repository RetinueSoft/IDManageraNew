import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/business_service/providers.dart';
import 'package:idmanager_app/business_service/templates/template_service.dart';
import 'package:idmanager_app/core_engine/common/enums.dart';
import 'package:idmanager_app/core_engine/templates/domain/card_template.dart';
import 'package:idmanager_app/core_engine/templates/domain/template_layer.dart';
import 'package:idmanager_app/presentation/shared/widgets/zoomable_canvas.dart';
import 'package:idmanager_app/presentation/templates/template_editor_screen.dart';

class _FakeTemplateService implements TemplateService {
  @override
  Future<CardTemplateDetail?> getTemplate(int id) async => CardTemplateDetail(
    template: CardTemplate(
      id: id,
      name: 'T',
      cardWidthMm: 85.6,
      cardHeightMm: 54,
      pointCost: 1,
      isActive: true,
      frontImageBase64: '',
      backImageBase64: '',
      createdAt: DateTime(2024),
    ),
    layers: const [
      TemplateLayer(
        side: CardSide.front,
        groups: [LayerGroup(id: 'f', name: 'FrontLayer', xMm: 5, yMm: 5)],
      ),
      TemplateLayer(
        side: CardSide.back,
        groups: [LayerGroup(id: 'b', name: 'BackLayer', xMm: 5, yMm: 5)],
      ),
    ],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The layer's text on the card canvas (the layers list has the name too).
Finder onCanvas(String text) =>
    find.descendant(of: find.byType(ZoomableCanvas), matching: find.text(text));

Future<void> pumpEditor(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1800, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [templateServiceProvider.overrideWithValue(_FakeTemplateService())],
      child: const MaterialApp(home: TemplateEditorScreen(templateId: 1)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the front and back cards side by side by default', (tester) async {
    await pumpEditor(tester);
    expect(onCanvas('FrontLayer'), findsOneWidget);
    expect(onCanvas('BackLayer'), findsOneWidget);
    // Front is to the left of back, on the same line.
    final front = tester.getTopLeft(onCanvas('FrontLayer'));
    final back = tester.getTopLeft(onCanvas('BackLayer'));
    expect(back.dx, greaterThan(front.dx));
    expect((back.dy - front.dy).abs(), lessThan(1));
  });

  testWidgets('Front and Back show one card each', (tester) async {
    await pumpEditor(tester);
    await tester.tap(find.text('Front').last);
    await tester.pumpAndSettle();
    expect(onCanvas('FrontLayer'), findsOneWidget);
    expect(onCanvas('BackLayer'), findsNothing);

    await tester.tap(find.text('Back').last);
    await tester.pumpAndSettle();
    expect(onCanvas('BackLayer'), findsOneWidget);
    expect(onCanvas('FrontLayer'), findsNothing);

    await tester.tap(find.text('Front + Back'));
    await tester.pumpAndSettle();
    expect(onCanvas('FrontLayer'), findsOneWidget);
    expect(onCanvas('BackLayer'), findsOneWidget);
  });

  testWidgets('clicking a layer on the back card makes back the side edits go to', (tester) async {
    await pumpEditor(tester);
    await tester.tap(onCanvas('BackLayer'));
    await tester.pumpAndSettle();
    // The properties panel shows that layer.
    expect(find.text('Layer properties'), findsOneWidget);
    final name = tester.widget<TextField>(find.widgetWithText(TextField, 'Layer name'));
    expect(name.controller!.text, 'BackLayer');
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/presentation/templates/collapsible_panel.dart';

Widget host(CollapseEdge edge) => MaterialApp(
  home: Scaffold(
    body: Row(
      children: [
        CollapsiblePanel(title: 'Layers', width: 260, edge: edge, child: const TextField(key: Key('inner'))),
        const Expanded(child: SizedBox()),
      ],
    ),
  ),
);

void main() {
  testWidgets('shrinks to a thin strip and expands again, keeping its content', (tester) async {
    await tester.pumpWidget(host(CollapseEdge.left));
    expect(tester.getSize(find.byType(CollapsiblePanel)).width, 260);

    await tester.enterText(find.byKey(const Key('inner')), 'typed');
    await tester.tap(find.byTooltip('Shrink Layers'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(CollapsiblePanel)).width, CollapsiblePanel.collapsedWidth);

    await tester.tap(find.byTooltip('Expand Layers'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(CollapsiblePanel)).width, 260);
    expect(find.text('typed'), findsOneWidget);
  });

  testWidgets('a right-edge panel works too', (tester) async {
    await tester.pumpWidget(host(CollapseEdge.right));
    await tester.tap(find.byTooltip('Shrink Layers'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(CollapsiblePanel)).width, CollapsiblePanel.collapsedWidth);
  });

  testWidgets('a bottom panel shrinks and expands by height', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(child: SizedBox()),
              CollapsiblePanel(
                title: 'Properties',
                height: 300,
                edge: CollapseEdge.bottom,
                child: TextField(key: Key('inner')),
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AnimatedContainer)).height, 300);
    await tester.enterText(find.byKey(const Key('inner')), 'typed');
    await tester.tap(find.byTooltip('Shrink Properties'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(AnimatedContainer)).height, CollapsiblePanel.collapsedHeight);
    await tester.tap(find.byTooltip('Expand Properties'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(AnimatedContainer)).height, 300);
    expect(find.text('typed'), findsOneWidget);
  });

  testWidgets('dragging the top bar resizes a bottom panel within limits', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(child: SizedBox()),
              CollapsiblePanel(title: 'Properties', height: 300, edge: CollapseEdge.bottom, child: SizedBox()),
            ],
          ),
        ),
      ),
    );
    double panelHeight() => tester.getSize(find.byType(AnimatedContainer)).height;
    await tester.drag(find.byKey(const Key('resize-handle')), const Offset(0, -100));
    await tester.pumpAndSettle();
    expect(panelHeight(), 400);
    await tester.drag(find.byKey(const Key('resize-handle')), const Offset(0, 900));
    await tester.pumpAndSettle();
    expect(panelHeight(), 150);
  });
}

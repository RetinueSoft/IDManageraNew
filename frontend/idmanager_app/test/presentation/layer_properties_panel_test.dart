import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/templates/domain/field_group.dart';
import 'package:idmanager_app/core_engine/templates/domain/template_layer.dart';
import 'package:idmanager_app/presentation/templates/layer_properties_panel.dart';

const single = LayerGroup(
  id: 'g',
  name: 'Name layer',
  xMm: 1,
  yMm: 2,
  sources: [LayerSourceItem(key: 'Name', value: 'Ravi')],
);

const combined = LayerGroup(
  id: 'c',
  name: 'Address',
  xMm: 1,
  yMm: 2,
  isList: true,
  sources: [
    LayerSourceItem(key: 'Door', value: '12'),
    LayerSourceItem(key: 'Street', value: 'Main road'),
  ],
);

Future<void> pump(WidgetTester tester, LayerGroup group, {required bool designer}) async {
  tester.view.physicalSize = const Size(1800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: LayerPropertiesPanel(
          designer: designer,
          group: group,
          sampleFields: const [],
          otherLayers: const [],
          onMergeLayer: (_) {},
          onChanged: (_) {},
          onDelete: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TextField fieldLabelled(WidgetTester tester, String label) =>
    tester.widget<TextField>(find.widgetWithText(TextField, label));

/// Holds the live group so a test can drive the panel like the real screen does (every
/// onChanged is applied) and then read back what ended up in it.
class _Harness {
  _Harness(this.group);
  LayerGroup group;
}

Future<_Harness> pumpEditable(
  WidgetTester tester,
  LayerGroup group, {
  List<ExtractedField> sampleFields = const [],
}) async {
  final harness = _Harness(group);
  tester.view.physicalSize = const Size(1800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => LayerPropertiesPanel(
            designer: true,
            group: harness.group,
            sampleFields: sampleFields,
            otherLayers: const [],
            onMergeLayer: (_) {},
            onChanged: (update) =>
                setState(() => harness.group = update(harness.group)),
            onDelete: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return harness;
}

void main() {
  group('designer', () {
    testWidgets('offers everything', (tester) async {
      await pump(tester, single, designer: true);
      expect(fieldLabelled(tester, 'Layer name').enabled, isTrue);
      expect(fieldLabelled(tester, 'Key (label before the value)').enabled, isNot(false));
      expect(find.text('Combine several fields'), findsOneWidget);
      expect(find.text('Words to remove from values'), findsOneWidget);
      expect(find.text('Date format'), findsOneWidget);
      expect(find.text('Read from PDF field'), findsOneWidget);
      expect(find.text('Sample value'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('a combined layer can add and remove fields', (tester) async {
      await pump(tester, combined, designer: true);
      expect(find.text('Add field'), findsOneWidget);
      expect(find.byTooltip('Remove field'), findsNWidgets(2));
      expect(find.text('Join with next field'), findsOneWidget);
    });

    testWidgets('a combined layer offers up/down to reorder its fields', (tester) async {
      await pump(tester, combined, designer: true);
      expect(find.byTooltip('Move up'), findsNWidgets(2));
      expect(find.byTooltip('Move down'), findsNWidgets(2));
    });

    testWidgets('the first field cannot move up, the last cannot move down', (tester) async {
      await pump(tester, combined, designer: true);
      IconButton up(int i) =>
          tester.widgetList<IconButton>(find.byWidgetPredicate((w) => w is IconButton && w.tooltip == 'Move up')).elementAt(i);
      IconButton down(int i) =>
          tester.widgetList<IconButton>(find.byWidgetPredicate((w) => w is IconButton && w.tooltip == 'Move down')).elementAt(i);

      expect(up(0).onPressed, isNull);
      expect(down(0).onPressed, isNotNull);
      expect(up(1).onPressed, isNotNull);
      expect(down(1).onPressed, isNull);
    });

    testWidgets('moving a field down swaps it with the one after it', (tester) async {
      final harness = await pumpEditable(tester, combined);

      await tester.tap(find.byTooltip('Move down').first);
      await tester.pumpAndSettle();

      expect(harness.group.sources[0].key, 'Street');
      expect(harness.group.sources[0].value, 'Main road');
      expect(harness.group.sources[1].key, 'Door');
      expect(harness.group.sources[1].value, '12');
    });

    testWidgets('moving the last field up swaps it with the one before it', (tester) async {
      final harness = await pumpEditable(tester, combined);

      await tester.tap(find.byTooltip('Move up').last);
      await tester.pumpAndSettle();

      expect(harness.group.sources[0].key, 'Street');
      expect(harness.group.sources[1].key, 'Door');
    });

    testWidgets(
      "'Read from PDF field' is a combo box: typing a value of its own is accepted, not just picking from the list",
      (tester) async {
        final harness = await pumpEditable(
          tester,
          single,
          sampleFields: const [ExtractedField(key: 'Existing field', value: 'x')],
        );

        final picker = find.ancestor(
          of: find.text('Read from PDF field'),
          matching: find.byType(TextFormField),
        );
        expect(picker, findsOneWidget);

        await tester.enterText(picker, 'My own field name');
        await tester.pumpAndSettle();

        expect(harness.group.sources.first.sourceKey, 'My own field name');
      },
    );

    testWidgets('clearing the PDF field box back to empty means "same as key" again', (tester) async {
      final harness = await pumpEditable(tester, single);
      final picker = find.ancestor(
        of: find.text('Read from PDF field'),
        matching: find.byType(TextFormField),
      );

      await tester.enterText(picker, 'Something');
      await tester.pumpAndSettle();
      expect(harness.group.sources.first.sourceKey, 'Something');

      await tester.enterText(picker, '');
      await tester.pumpAndSettle();
      expect(harness.group.sources.first.sourceKey, isNull);
    });
  });

  group('card generator', () {
    testWidgets('layer name is read-only; keys and structure controls are hidden', (tester) async {
      await pump(tester, single, designer: false);
      expect(fieldLabelled(tester, 'Layer name').enabled, isFalse);
      expect(find.text('Key (label before the value)'), findsNothing);
      expect(find.text('Combine several fields'), findsNothing);
      expect(find.text('Words to remove from values'), findsNothing);
      expect(find.text('Date format'), findsNothing);
      expect(find.text('Read from PDF field'), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      // The value and the rest of the layout stay editable.
      expect(fieldLabelled(tester, 'Value').enabled, isNull);
      expect(find.text('Bold (B)'), findsOneWidget);
      expect(find.text('Font (pt)'), findsOneWidget);
      expect(find.text('X (mm)'), findsOneWidget);
    });

    testWidgets('a combined layer has no keys and no add or remove field buttons', (tester) async {
      await pump(tester, combined, designer: false);
      expect(find.text('Add field'), findsNothing);
      expect(find.byTooltip('Remove field'), findsNothing);
      expect(find.text('Read from PDF field'), findsNothing);
      expect(find.text('Join with next field'), findsNothing);
      expect(find.text('Key (label)'), findsNothing);
      // Values can still be edited, and the List toggle is still there.
      final values = tester.widgetList<TextField>(find.widgetWithText(TextField, 'Value'));
      expect(values.every((v) => v.enabled != false), isTrue);
      expect(find.text('List (L)'), findsOneWidget);
    });
  });
}

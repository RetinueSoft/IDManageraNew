import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/common/enums.dart';
import 'package:idmanager_app/core_engine/templates/domain/field_group.dart';
import 'package:idmanager_app/presentation/templates/file_name_dialog.dart';

const fields = [
  ExtractedField(key: 'Name', value: 'Ravi Kumar'),
  ExtractedField(key: 'Card No', value: '1234567890'),
  ExtractedField(key: 'Photo', value: 'xx', type: LayerFieldType.image),
];

Future<Future<String?> Function()> open(
  WidgetTester tester, {
  String? pattern,
  List<ExtractedField> sample = fields,
}) async {
  String? result = 'unset';
  var closed = false;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showFileNameDialog(context, pattern: pattern, fields: sample);
            closed = true;
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  return () async {
    expect(closed, isTrue);
    return result;
  };
}

void main() {
  testWidgets('offers the sample PDF text fields, not images', (tester) async {
    await open(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ActionChip, 'Name'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Card No'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Photo'), findsNothing);
  });

  testWidgets('clicking fields builds the pattern and shows an example from the sample values', (tester) async {
    final result = await open(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ActionChip, 'Name'));
    await tester.enterText(find.byType(TextField), '{Name} - ');
    await tester.pump();
    await tester.tap(find.widgetWithText(ActionChip, 'Card No'));
    await tester.pump();

    expect(find.text('Example from the sample PDF: Ravi Kumar - 1234567890.pdf'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(await result(), '{Name} - {Card No}');
  });

  testWidgets('starts from the current pattern', (tester) async {
    await open(tester, pattern: '{Card No}');
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('{Card No}'), findsOneWidget);
    expect(find.text('Example from the sample PDF: 1234567890.pdf'), findsOneWidget);
  });

  testWidgets('a blank pattern says the default name is used, and returns blank', (tester) async {
    final result = await open(tester, pattern: '{Name}');
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(find.textContaining('card-<number>.pdf'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(await result(), '');
  });

  testWidgets('warns about a field the sample PDF does not have', (tester) async {
    await open(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '{Name} {Missing}');
    await tester.pump();

    expect(find.text('Not a field of the sample PDF: Missing'), findsOneWidget);
  });

  testWidgets('cancel returns nothing', (tester) async {
    final result = await open(tester, pattern: '{Name}');
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(await result(), isNull);
  });

  testWidgets('with no sample PDF it explains how to get fields', (tester) async {
    await open(tester, sample: const []);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Import the template'), findsOneWidget);
    expect(find.byType(ActionChip), findsNothing);
  });
}

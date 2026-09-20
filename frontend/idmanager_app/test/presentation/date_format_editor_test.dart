import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/presentation/templates/date_format_editor.dart';

Widget host(String? format, ValueChanged<String?> onChanged) =>
    MaterialApp(home: Scaffold(body: DateFormatEditor(format: format, onChanged: onChanged)));

void main() {
  testWidgets('shows the current format and what it prints', (tester) async {
    await tester.pumpWidget(host('dd/MM/yyyy', (_) {}));
    expect(find.text('dd/MM/yyyy'), findsOneWidget);
    expect(find.text('Prints as 07/03/2024'), findsOneWidget);
  });

  testWidgets('typing a format reports it; clearing reports null', (tester) async {
    final changes = <String?>[];
    await tester.pumpWidget(host(null, changes.add));
    await tester.enterText(find.byType(TextField), 'dd-MMM-yyyy');
    expect(changes.last, 'dd-MMM-yyyy');
    await tester.enterText(find.byType(TextField), '  ');
    expect(changes.last, isNull);
  });

  testWidgets('choosing a preset fills the field and reports it', (tester) async {
    final changes = <String?>[];
    await tester.pumpWidget(host(null, changes.add));
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('yyyy-MM-dd'));
    await tester.pumpAndSettle();
    expect(changes.last, 'yyyy-MM-dd');
    expect(find.text('yyyy-MM-dd'), findsOneWidget);
  });
}

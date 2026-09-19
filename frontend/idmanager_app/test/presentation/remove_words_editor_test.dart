import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/presentation/templates/remove_words_editor.dart';

/// Hosts the editor the way the properties panel does: it reports a new list through
/// onChanged and the panel rebuilds it with that list.
class _Host extends StatefulWidget {
  const _Host({required this.initial, required this.onChanged});

  final List<String> initial;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late List<String> words = widget.initial;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: RemoveWordsEditor(
          words: words,
          onChanged: (w) {
            setState(() => words = w);
            widget.onChanged(w);
          },
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the words already set as removable chips', (tester) async {
    await tester.pumpWidget(_Host(initial: const ['எண்', 'போஸ்ட்'], onChanged: (_) {}));

    expect(find.widgetWithText(InputChip, 'எண்'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'போஸ்ட்'), findsOneWidget);
  });

  testWidgets('typing a word and pressing Enter adds it, and the field clears', (tester) async {
    List<String>? latest;
    await tester.pumpWidget(_Host(initial: const [], onChanged: (w) => latest = w));

    await tester.enterText(find.byType(TextField), '  எண்  ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(latest, ['எண்']); // trimmed
    expect(find.widgetWithText(InputChip, 'எண்'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '');
  });

  testWidgets('several words can be added one after another', (tester) async {
    List<String>? latest;
    await tester.pumpWidget(_Host(initial: const [], onChanged: (w) => latest = w));

    for (final word in ['எண்', 'போஸ்ட்', 'No.']) {
      await tester.enterText(find.byType(TextField), word);
      await tester.tap(find.byTooltip('Add word'));
      await tester.pump();
    }

    expect(latest, ['எண்', 'போஸ்ட்', 'No.']);
  });

  testWidgets('a duplicate or blank word is not added twice', (tester) async {
    var calls = 0;
    await tester.pumpWidget(_Host(initial: const ['எண்'], onChanged: (_) => calls++));

    await tester.enterText(find.byType(TextField), 'எண்');
    await tester.tap(find.byTooltip('Add word'));
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.byTooltip('Add word'));
    await tester.pump();

    expect(calls, 0);
  });

  testWidgets('the chip delete button removes just that word', (tester) async {
    List<String>? latest;
    await tester.pumpWidget(_Host(initial: const ['எண்', 'போஸ்ட்'], onChanged: (w) => latest = w));

    await tester.tap(find.descendant(of: find.widgetWithText(InputChip, 'எண்'), matching: find.byType(Icon)));
    await tester.pump();

    expect(latest, ['போஸ்ட்']);
    expect(find.widgetWithText(InputChip, 'எண்'), findsNothing);
  });
}

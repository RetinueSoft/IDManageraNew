import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/common/uploaded_file.dart';
import 'package:idmanager_app/core_engine/templates/domain/card_background.dart';
import 'package:idmanager_app/presentation/templates/background_bar.dart';

const backgrounds = [
  CardBackground(id: 0, name: 'Default', frontImageBase64: '', backImageBase64: ''),
  CardBackground(id: 7, name: 'Blue', frontImageBase64: '', backImageBase64: ''),
  CardBackground(id: 9, name: 'Red', frontImageBase64: '', backImageBase64: ''),
];

Widget host({
  int selected = 0,
  required ValueChanged<int> onSelect,
  VoidCallback? onAdd,
  ValueChanged<CardBackground>? onDelete,
}) => MaterialApp(
  home: Scaffold(
    body: BackgroundBar(
      backgrounds: backgrounds,
      selectedId: selected,
      onSelect: onSelect,
      onAdd: onAdd,
      onDelete: onDelete,
    ),
  ),
);

UploadedFile file(String name) => UploadedFile(Uint8List.fromList([1, 2, 3]), name);

/// A button that opens the dialog and keeps what it returned.
class _Opener extends StatefulWidget {
  const _Opener({required this.picks, required this.onResult});

  final List<UploadedFile?> picks;
  final ValueChanged<NewBackground?> onResult;

  @override
  State<_Opener> createState() => _OpenerState();
}

class _OpenerState extends State<_Opener> {
  late final List<UploadedFile?> _queue = [...widget.picks];

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () async {
      final result = await showAddBackgroundDialog(
        context,
        pickImage: () async => _queue.isEmpty ? null : _queue.removeAt(0),
      );
      widget.onResult(result);
    },
    child: const Text('open'),
  );
}

Future<void> openDialog(WidgetTester tester, List<UploadedFile?> picks, ValueChanged<NewBackground?> onResult) async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: _Opener(picks: picks, onResult: onResult))));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

FilledButton addButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Add'));

void main() {
  testWidgets('shows every background and selects one with a tap', (tester) async {
    final picked = <int>[];
    await tester.pumpWidget(host(onSelect: picked.add));

    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Blue'), findsOneWidget);
    expect(find.text('Red'), findsOneWidget);

    await tester.tap(find.text('Blue'));
    expect(picked, [7]);
    await tester.tap(find.text('Default'));
    expect(picked, [7, 0]);
  });

  testWidgets('switch-only mode (card generator) has no add or remove', (tester) async {
    await tester.pumpWidget(host(onSelect: (_) {}));

    expect(find.text('Add background'), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('designer mode can add, and remove any background except the default', (tester) async {
    // Wide enough that the test font's wide letters don't push chips under the Add button.
    tester.view.physicalSize = const Size(1800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final removed = <String>[];
    var added = 0;
    await tester.pumpWidget(
      host(onSelect: (_) {}, onAdd: () => added++, onDelete: (b) => removed.add(b.name)),
    );

    await tester.tap(find.text('Add background'));
    expect(added, 1);
    // One remove button per extra background; none on the template's own.
    expect(find.byIcon(Icons.close), findsNWidgets(2));
    await tester.tap(find.byTooltip('Remove background Red'));
    expect(removed, ['Red']);
  });

  group('add background dialog', () {
    testWidgets('Add is enabled only with a name and both images', (tester) async {
      await openDialog(tester, [file('front.png'), file('back.png')], (_) {});
      expect(addButton(tester).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Festival');
      await tester.pump();
      expect(addButton(tester).onPressed, isNull);

      await tester.tap(find.text('Choose front image'));
      await tester.pumpAndSettle();
      expect(addButton(tester).onPressed, isNull);

      await tester.tap(find.text('Choose back image'));
      await tester.pumpAndSettle();
      expect(addButton(tester).onPressed, isNotNull);
      expect(find.text('front.png'), findsOneWidget);
      expect(find.text('back.png'), findsOneWidget);
    });

    testWidgets('returns what was entered', (tester) async {
      NewBackground? result;
      await openDialog(tester, [file('front.png'), file('back.png')], (r) => result = r);

      await tester.enterText(find.byType(TextField), '  Festival ');
      await tester.tap(find.text('Choose front image'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose back image'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Add'));
      await tester.pumpAndSettle();

      expect(result?.name, 'Festival');
      expect(result?.front.name, 'front.png');
      expect(result?.back.name, 'back.png');
    });

    testWidgets('cancelling returns nothing', (tester) async {
      var called = false;
      NewBackground? result = NewBackground(name: 'x', front: file('f'), back: file('b'));
      await openDialog(tester, [], (r) {
        called = true;
        result = r;
      });

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(result, isNull);
    });
  });
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/application/templates/template_editor_controller.dart';
import 'package:idmanager_app/business_service/providers.dart';
import 'package:idmanager_app/business_service/templates/template_service.dart';
import 'package:idmanager_app/core_engine/common/uploaded_file.dart';
import 'package:idmanager_app/core_engine/templates/domain/card_template.dart';
import 'package:idmanager_app/presentation/templates/template_editor_screen.dart';

class _FakeTemplates implements TemplateService {
  final added = <String>[];
  final deleted = <int>[];

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
    combinations: const [Combination(id: 7, name: 'Blue', frontImageBase64: '', backImageBase64: '')],
  );

  @override
  Future<Combination> addCombination({
    required int templateId,
    required String name,
    required UploadedFile frontFile,
    required UploadedFile backFile,
  }) async {
    added.add(name);
    return Combination(id: 100 + added.length, name: name, frontImageBase64: '', backImageBase64: '');
  }

  @override
  Future<void> deleteCombination(int combinationId) async => deleted.add(combinationId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<(ProviderContainer, _FakeTemplates)> pumpEditor(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1800, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final fake = _FakeTemplates();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [templateServiceProvider.overrideWithValue(fake)],
      child: const MaterialApp(home: TemplateEditorScreen(templateId: 1)),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(tester.element(find.byType(TemplateEditorScreen)));
  return (container, fake);
}

void main() {
  testWidgets('the designer lists the backgrounds and can switch between them', (tester) async {
    final (container, _) = await pumpEditor(tester);
    final provider = templateEditorControllerProvider(1);

    expect(find.text('Default'), findsOneWidget);
    expect(find.text('Blue'), findsOneWidget);
    expect(find.text('Add background'), findsOneWidget);
    expect(container.read(provider).value!.selectedBackgroundId, 0);

    await tester.tap(find.text('Blue'));
    await tester.pumpAndSettle();
    expect(container.read(provider).value!.selectedBackgroundId, 7);
  });

  testWidgets('adding a background selects it and it is saved on the template right away', (tester) async {
    final (container, fake) = await pumpEditor(tester);
    final controller = container.read(templateEditorControllerProvider(1).notifier);

    final error = await controller.addBackground(
      name: 'Festival',
      front: UploadedFile(Uint8List.fromList([1]), 'f.png'),
      back: UploadedFile(Uint8List.fromList([2]), 'b.png'),
    );
    await tester.pumpAndSettle();

    expect(error, isNull);
    expect(fake.added, ['Festival']);
    final state = container.read(templateEditorControllerProvider(1)).value!;
    expect([for (final c in state.template.combinations) c.name], ['Blue', 'Festival']);
    expect(state.selectedBackgroundId, 101);
    expect(find.text('Festival'), findsOneWidget);
  });

  testWidgets('removing the shown background falls back to the default; the default cannot be removed', (tester) async {
    final (container, fake) = await pumpEditor(tester);
    final provider = templateEditorControllerProvider(1);
    final controller = container.read(provider.notifier);
    controller.selectBackground(7);

    await controller.deleteBackground(0);
    expect(fake.deleted, isEmpty);

    await controller.deleteBackground(7);
    await tester.pumpAndSettle();

    expect(fake.deleted, [7]);
    final state = container.read(provider).value!;
    expect(state.template.combinations, isEmpty);
    expect(state.selectedBackgroundId, 0);
    expect(find.text('Blue'), findsNothing);
  });
}

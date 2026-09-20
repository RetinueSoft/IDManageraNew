import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/application/templates/template_editor_controller.dart';
import 'package:idmanager_app/business_service/providers.dart';
import 'package:idmanager_app/business_service/templates/template_service.dart';
import 'package:idmanager_app/core_engine/templates/domain/card_template.dart';
import 'package:idmanager_app/core_engine/templates/domain/field_group.dart';
import 'package:idmanager_app/core_engine/templates/domain/template_layer.dart';
import 'package:idmanager_app/presentation/templates/template_editor_screen.dart';

class _FakeTemplates implements TemplateService {
  _FakeTemplates(this.pattern);

  final String? pattern;
  final saved = <String?>[];

  @override
  Future<CardTemplateDetail?> getTemplate(int id) async => CardTemplateDetail(
    template: CardTemplate(
      id: id,
      name: 'T',
      cardWidthMm: 85.6,
      cardHeightMm: 54,
      pointCost: 1,
      isActive: true,
      fileNamePattern: pattern,
      frontImageBase64: '',
      backImageBase64: '',
      createdAt: DateTime(2024),
    ),
  );

  @override
  Future<void> saveLayers(
    int templateId,
    List<TemplateLayer> layers, {
    List<FieldGroup>? groups,
    String? fileNamePattern,
  }) async => saved.add(fileNamePattern);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<(ProviderContainer, _FakeTemplates)> pumpEditor(WidgetTester tester, {String? pattern}) async {
  tester.view.physicalSize = const Size(1800, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final fake = _FakeTemplates(pattern);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [templateServiceProvider.overrideWithValue(fake)],
      child: const MaterialApp(home: TemplateEditorScreen(templateId: 1)),
    ),
  );
  await tester.pumpAndSettle();
  return (ProviderScope.containerOf(tester.element(find.byType(TemplateEditorScreen))), fake);
}

void main() {
  testWidgets('the designer has a button for the downloaded PDF name, starting from the saved pattern', (tester) async {
    await pumpEditor(tester, pattern: '{Name}');

    await tester.tap(find.byTooltip('Downloaded PDF name (built from the member fields)'));
    await tester.pumpAndSettle();

    expect(find.text('Downloaded PDF name'), findsOneWidget);
    expect(find.text('{Name}'), findsOneWidget);
  });

  testWidgets('OK sets the pattern (not saved until Save) and Save sends it', (tester) async {
    final (container, fake) = await pumpEditor(tester);
    final provider = templateEditorControllerProvider(1);

    await tester.tap(find.byTooltip('Downloaded PDF name (built from the member fields)'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '{Name} - {Card No}');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(container.read(provider).value!.template.template.fileNamePattern, '{Name} - {Card No}');
    expect(fake.saved, isEmpty);

    await container.read(provider.notifier).save();
    expect(fake.saved, ['{Name} - {Card No}']);
  });

  testWidgets('cancelling changes nothing', (tester) async {
    final (container, _) = await pumpEditor(tester, pattern: '{Name}');

    await tester.tap(find.byTooltip('Downloaded PDF name (built from the member fields)'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'something else');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(container.read(templateEditorControllerProvider(1)).value!.template.template.fileNamePattern, '{Name}');
  });

  testWidgets('clearing the pattern is saved as blank so the backend clears it', (tester) async {
    final (container, fake) = await pumpEditor(tester, pattern: '{Name}');
    final controller = container.read(templateEditorControllerProvider(1).notifier);

    controller.setFileNamePattern('   ');
    expect(container.read(templateEditorControllerProvider(1)).value!.template.template.fileNamePattern, isNull);
    await controller.save();

    expect(fake.saved, ['']);
  });
}

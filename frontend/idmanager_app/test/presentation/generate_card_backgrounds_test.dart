import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/application/cards/generate_card_controller.dart';
import 'package:idmanager_app/business_service/cards/card_generation_service.dart';
import 'package:idmanager_app/business_service/providers.dart';
import 'package:idmanager_app/business_service/templates/template_service.dart';
import 'package:idmanager_app/core_engine/cards/domain/generated_card.dart';
import 'package:idmanager_app/core_engine/cards/domain/qr_slot.dart';
import 'package:idmanager_app/core_engine/common/enums.dart';
import 'package:idmanager_app/core_engine/common/lookup_option.dart';
import 'package:idmanager_app/core_engine/common/uploaded_file.dart';
import 'package:idmanager_app/core_engine/templates/domain/card_template.dart';
import 'package:idmanager_app/core_engine/templates/domain/template_layer.dart';
import 'package:idmanager_app/presentation/cards/generate_card_screen.dart';

class _FakeTemplates implements TemplateService {
  @override
  Future<List<LookupOption>> getActiveTemplateOptions() async => [(id: 1, label: 'Ration card')];

  @override
  Future<CardTemplateDetail?> getTemplate(int id) async => CardTemplateDetail(
    template: CardTemplate(
      id: id,
      name: 'Ration card',
      cardWidthMm: 85.6,
      cardHeightMm: 54,
      pointCost: 1,
      isActive: true,
      frontImageBase64: '',
      backImageBase64: '',
      createdAt: DateTime(2024),
    ),
    combinations: const [
      Combination(id: 7, name: 'Blue', frontImageBase64: '', backImageBase64: ''),
      Combination(id: 9, name: 'Festival', frontImageBase64: '', backImageBase64: ''),
    ],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCards implements CardGenerationService {
  /// The background each Preview asked for, in order.
  final generatedWith = <int>[];

  /// The background each download was printed on.
  final downloadedWith = <int>[];

  @override
  Future<List<QrSlot>> getQrSlots(int templateId) async => const [];

  @override
  Future<GeneratedCard> generate({
    required int templateId,
    required int combinationId,
    required UploadedFile file,
    Map<String, UploadedFile> qrImages = const {},
  }) async {
    generatedWith.add(combinationId);
    return GeneratedCard(
      idCardId: 100 + generatedWith.length,
      layers: const [TemplateLayer(side: CardSide.front)],
      cardWidthMm: 85.6,
      cardHeightMm: 54,
      frontImageBase64: '',
      backImageBase64: '',
    );
  }

  @override
  Future<Uint8List> downloadPdf(int idCardId, List<TemplateLayer> layers, int combinationId) async {
    downloadedWith.add(combinationId);
    return Uint8List(0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<(ProviderContainer, _FakeCards)> pumpGenerator(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1800, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final cards = _FakeCards();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        templateServiceProvider.overrideWithValue(_FakeTemplates()),
        cardGenerationServiceProvider.overrideWithValue(cards),
      ],
      child: const MaterialApp(home: GenerateCardScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return (ProviderScope.containerOf(tester.element(find.byType(GenerateCardScreen))), cards);
}

Future<void> chooseTemplate(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(DropdownButtonFormField<int>, 'Template'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Ration card').last);
  await tester.pumpAndSettle();
}

Future<void> chooseBackground(WidgetTester tester, String name) async {
  await tester.tap(find.widgetWithText(DropdownButtonFormField<int>, 'Background'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(name).last);
  await tester.pumpAndSettle();
}

Future<void> preview(WidgetTester tester, ProviderContainer container) async {
  container
      .read(generateCardControllerProvider.notifier)
      .setPdfFile(UploadedFile(Uint8List.fromList([1]), 'member.pdf'));
  await tester.tap(find.text('Preview card'));
  await tester.pumpAndSettle();
}

const placeholder = 'Preview will appear here after parsing the PDF.';

void main() {
  testWidgets('there is no background drop-down until a template is chosen', (tester) async {
    await pumpGenerator(tester);

    expect(find.widgetWithText(DropdownButtonFormField<int>, 'Background'), findsNothing);
  });

  testWidgets('choosing a template adds a Background drop-down but shows no background yet', (tester) async {
    final (container, _) = await pumpGenerator(tester);
    await chooseTemplate(tester);

    expect(find.widgetWithText(DropdownButtonFormField<int>, 'Background'), findsOneWidget);
    // Nothing is drawn until Preview: no thumbnails strip, no card, just the placeholder.
    expect(find.text(placeholder), findsOneWidget);
    expect(find.text('Add background'), findsNothing);
    expect(container.read(generateCardControllerProvider).value!.selectedCombinationId, 0);
  });

  testWidgets("the drop-down lists the template's backgrounds", (tester) async {
    await pumpGenerator(tester).then((_) => null);
    await chooseTemplate(tester);

    await tester.tap(find.widgetWithText(DropdownButtonFormField<int>, 'Background'));
    await tester.pumpAndSettle();

    expect(find.text('Default'), findsWidgets);
    expect(find.text('Blue'), findsOneWidget);
    expect(find.text('Festival'), findsOneWidget);
  });

  testWidgets('Preview shows the chosen background alone', (tester) async {
    final (container, cards) = await pumpGenerator(tester);
    await chooseTemplate(tester);
    await chooseBackground(tester, 'Blue');
    // Choosing does not preview anything by itself.
    expect(cards.generatedWith, isEmpty);
    expect(find.text(placeholder), findsOneWidget);

    await preview(tester, container);

    expect(cards.generatedWith, [7]);
    expect(find.text(placeholder), findsNothing);
    expect(find.text('Front + Back'), findsOneWidget);
    // Only the picked one is on show: no strip of the other backgrounds.
    expect(find.text('Festival'), findsNothing);
  });

  testWidgets('another background only takes effect when Preview is pressed again', (tester) async {
    final (container, cards) = await pumpGenerator(tester);
    await chooseTemplate(tester);
    await chooseBackground(tester, 'Blue');
    await preview(tester, container);

    await chooseBackground(tester, 'Festival');

    // The card on screen is still the Blue one; nothing was generated by picking.
    var state = container.read(generateCardControllerProvider).value!;
    expect(cards.generatedWith, [7]);
    expect(state.selectedCombinationId, 9);
    expect(state.resultCombinationId, 7);

    await tester.tap(find.text('Preview card'));
    await tester.pumpAndSettle();

    state = container.read(generateCardControllerProvider).value!;
    // A new preview is a new card on the new background (so it is charged like any card).
    expect(cards.generatedWith, [7, 9]);
    expect(state.resultCombinationId, 9);
    expect(state.result!.idCardId, 102);
  });

  testWidgets('the download is printed on the background that was previewed', (tester) async {
    final (container, cards) = await pumpGenerator(tester);
    await chooseTemplate(tester);
    await chooseBackground(tester, 'Blue');
    await preview(tester, container);
    // Pick another background but do not preview it.
    await chooseBackground(tester, 'Festival');

    await container.read(generateCardControllerProvider.notifier).downloadPdf();

    expect(cards.downloadedWith, [7]);
  });

  testWidgets('choosing another template starts again on its default background', (tester) async {
    final (container, _) = await pumpGenerator(tester);
    await chooseTemplate(tester);
    await chooseBackground(tester, 'Blue');
    await preview(tester, container);

    await container.read(generateCardControllerProvider.notifier).selectTemplate(1);
    await tester.pumpAndSettle();

    final state = container.read(generateCardControllerProvider).value!;
    expect(state.selectedCombinationId, 0);
    expect(state.result, isNull);
    expect(state.resultCombinationId, isNull);
    expect(find.text(placeholder), findsOneWidget);
  });
}

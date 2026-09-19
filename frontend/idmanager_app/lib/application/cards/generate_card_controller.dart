import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/common/uploaded_file.dart';
import 'generate_card_state.dart';

part 'generate_card_controller.g.dart';

@riverpod
class GenerateCardController extends _$GenerateCardController {
  @override
  Future<GenerateCardState> build() async {
    final options = await ref.watch(templateServiceProvider).getActiveTemplateOptions();
    return GenerateCardState(templateOptions: options);
  }

  Future<void> selectTemplate(int? templateId) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(
      selectedTemplateId: templateId,
      combinationOptions: const [],
      selectedCombinationId: null,
      result: null,
    ));
    if (templateId == null) return;

    final options = await ref.read(cardGenerationServiceProvider).getCombinationOptions(templateId);
    final refreshed = state.value;
    if (refreshed == null) return;
    state = AsyncData(refreshed.copyWith(
      combinationOptions: options,
      selectedCombinationId: options.isNotEmpty ? options.first.id : null,
    ));
  }

  void selectCombination(int? combinationId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedCombinationId: combinationId));
  }

  void setPdfFile(UploadedFile file) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(pdfFile: file, error: null));
  }

  Future<void> generate() async {
    final current = state.value;
    if (current == null) return;
    if (current.selectedTemplateId == null || current.selectedCombinationId == null || current.pdfFile == null) {
      state = AsyncData(current.copyWith(error: 'Select a template, a combination and a PDF file.'));
      return;
    }

    state = AsyncData(current.copyWith(isBusy: true, error: null));
    try {
      final result = await ref.read(cardGenerationServiceProvider).generate(
        templateId: current.selectedTemplateId!,
        combinationId: current.selectedCombinationId!,
        file: current.pdfFile!,
      );
      state = AsyncData(current.copyWith(isBusy: false, result: result));
    } catch (e) {
      state = AsyncData(current.copyWith(isBusy: false, error: e.toString()));
    }
  }

  Future<Uint8List?> downloadPdf() async {
    final current = state.value;
    if (current?.result == null) return null;

    state = AsyncData(current!.copyWith(isBusy: true));
    try {
      final bytes = await ref.read(cardGenerationServiceProvider).downloadPdf(current.result!.idCardId);
      state = AsyncData(current.copyWith(isBusy: false));
      return bytes;
    } catch (e) {
      state = AsyncData(current.copyWith(isBusy: false, error: e.toString()));
      return null;
    }
  }
}

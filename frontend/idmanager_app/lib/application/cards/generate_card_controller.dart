import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../points/points_refresh.dart';
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
      qrSlots: const [],
      qrFiles: const {},
      result: null,
    ));
    if (templateId == null) return;

    final service = ref.read(cardGenerationServiceProvider);
    final options = await service.getCombinationOptions(templateId);
    final slots = await service.getQrSlots(templateId);
    final refreshed = state.value;
    if (refreshed == null) return;
    state = AsyncData(refreshed.copyWith(
      combinationOptions: options,
      selectedCombinationId: options.isNotEmpty ? options.first.id : null,
      qrSlots: slots,
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

  /// Sets the image the user picked for one of the template's QR slots.
  void setQrFile(String slotKey, UploadedFile file) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(qrFiles: {...current.qrFiles, slotKey: file}, error: null));
  }

  Future<void> generate() async {
    final current = state.value;
    if (current == null) return;
    // A combination is only needed when the template has some; otherwise the
    // template's own front and back images are used.
    final needsCombination = current.combinationOptions.isNotEmpty;
    if (current.selectedTemplateId == null ||
        (needsCombination && current.selectedCombinationId == null) ||
        current.pdfFile == null) {
      state = AsyncData(current.copyWith(
        error: needsCombination
            ? 'Select a template, a combination and a PDF file.'
            : 'Select a template and a PDF file.',
      ));
      return;
    }

    state = AsyncData(current.copyWith(isBusy: true, error: null));
    try {
      final result = await ref.read(cardGenerationServiceProvider).generate(
        templateId: current.selectedTemplateId!,
        combinationId: current.selectedCombinationId ?? 0,
        file: current.pdfFile!,
        qrImages: current.qrFiles,
      );
      state = AsyncData(current.copyWith(isBusy: false, result: result));
      refreshPointsData(ref); // the card's points are recorded (pending) now
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
      refreshPointsData(ref); // the points are applied when the PDF is downloaded
      return bytes;
    } catch (e) {
      state = AsyncData(current.copyWith(isBusy: false, error: e.toString()));
      return null;
    }
  }
}

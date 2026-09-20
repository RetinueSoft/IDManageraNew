import '../../core_engine/cards/domain/downloaded_pdf.dart';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/common/enums.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../../core_engine/templates/domain/card_background.dart';
import '../../core_engine/templates/domain/template_layer.dart';
import '../points/points_refresh.dart';
import 'generate_card_state.dart';

part 'generate_card_controller.g.dart';

@riverpod
class GenerateCardController extends _$GenerateCardController {
  @override
  Future<GenerateCardState> build() async {
    final options = await ref
        .watch(templateServiceProvider)
        .getActiveTemplateOptions();
    return GenerateCardState(templateOptions: options);
  }

  Future<void> selectTemplate(int? templateId) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        selectedTemplateId: templateId,
        template: null,
        selectedCombinationId: CardBackground.defaultId,
        qrSlots: const [],
        qrFiles: const {},
        result: null,
        resultCombinationId: null,
      ),
    );
    if (templateId == null) return;

    final service = ref.read(cardGenerationServiceProvider);
    final detail = await ref
        .read(templateServiceProvider)
        .getTemplate(templateId);
    final slots = await service.getQrSlots(templateId);
    final refreshed = state.value;
    // The user may have picked another template while this one was loading.
    if (refreshed == null || refreshed.selectedTemplateId != templateId) return;
    state = AsyncData(refreshed.copyWith(template: detail, qrSlots: slots));
  }

  /// Chooses the background the next preview is made on (0 = the template's own). The card on
  /// screen keeps the background it was previewed with until Preview is pressed again - each
  /// preview is a new card, and points are taken for the card that is downloaded.
  void selectCombination(int? combinationId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        selectedCombinationId: combinationId ?? CardBackground.defaultId,
      ),
    );
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
    state = AsyncData(
      current.copyWith(
        qrFiles: {...current.qrFiles, slotKey: file},
        error: null,
      ),
    );
  }

  void selectSide(CardSide side) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(side: side, combined: false, selectedGroupId: null),
    );
  }

  /// Show front and back side by side. The active side is kept.
  void selectCombined() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(combined: true, selectedGroupId: null));
  }

  /// Selects a layer (or nothing) on [side] and makes that side the one edits go to.
  void selectLayer(CardSide side, String? groupId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(side: side, selectedGroupId: groupId));
  }

  /// Changes one layer of the previewed card (only this card - the template is untouched).
  void updateGroup(
    String groupId,
    LayerGroup Function(LayerGroup current) update,
  ) {
    final current = state.value;
    final result = current?.result;
    if (current == null || result == null) return;
    state = AsyncData(
      current.copyWith(
        result: result.copyWith(
          layers: [
            for (final l in result.layers)
              if (l.side == current.side)
                l.copyWith(
                  groups: [
                    for (final g in l.groups)
                      if (g.id == groupId) update(g) else g,
                  ],
                )
              else
                l,
          ],
        ),
      ),
    );
  }

  void moveGroup(String groupId, double dxMm, double dyMm) {
    final result = state.value?.result;
    if (result == null) return;
    updateGroup(
      groupId,
      (g) => g.copyWith(
        xMm: (g.xMm + dxMm).clamp(0, result.cardWidthMm - 1),
        yMm: (g.yMm + dyMm).clamp(0, result.cardHeightMm - 1),
      ),
    );
  }

  /// Removes the selected layer from this card.
  void deleteSelected() {
    final current = state.value;
    final result = current?.result;
    final id = current?.selectedGroupId;
    if (current == null || result == null || id == null) return;
    state = AsyncData(
      current.copyWith(
        selectedGroupId: null,
        result: result.copyWith(
          layers: [
            for (final l in result.layers)
              if (l.side == current.side)
                l.copyWith(
                  groups: [
                    for (final g in l.groups)
                      if (g.id != id) g,
                  ],
                )
              else
                l,
          ],
        ),
      ),
    );
  }

  Future<void> generate() async {
    final current = state.value;
    if (current == null) return;
    if (current.selectedTemplateId == null || current.pdfFile == null) {
      state = AsyncData(
        current.copyWith(error: 'Select a template and a PDF file.'),
      );
      return;
    }

    state = AsyncData(current.copyWith(isBusy: true, error: null));
    try {
      final result = await ref
          .read(cardGenerationServiceProvider)
          .generate(
            templateId: current.selectedTemplateId!,
            combinationId: current.selectedCombinationId,
            file: current.pdfFile!,
            qrImages: current.qrFiles,
          );
      state = AsyncData(
        current.copyWith(
          isBusy: false,
          result: result,
          resultCombinationId: current.selectedCombinationId,
          combined: true,
          selectedGroupId: null,
        ),
      );
      refreshPointsData(ref); // the card's points are recorded (pending) now
    } catch (e) {
      state = AsyncData(current.copyWith(isBusy: false, error: e.toString()));
    }
  }

  Future<DownloadedPdf?> downloadPdf() async {
    final current = state.value;
    if (current?.result == null) return null;

    state = AsyncData(current!.copyWith(isBusy: true));
    try {
      // The card is printed as it is shown, including any adjustments made in the preview.
      final pdf = await ref
          .read(cardGenerationServiceProvider)
          .downloadPdf(
            current.result!.idCardId,
            current.result!.layers,
            current.resultCombinationId ?? CardBackground.defaultId,
          );
      state = AsyncData(current.copyWith(isBusy: false));
      refreshPointsData(
        ref,
      ); // the points are applied when the PDF is downloaded
      return pdf;
    } catch (e) {
      state = AsyncData(current.copyWith(isBusy: false, error: e.toString()));
      return null;
    }
  }
}

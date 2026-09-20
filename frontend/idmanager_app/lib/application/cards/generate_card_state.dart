import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core_engine/cards/domain/generated_card.dart';
import '../../core_engine/cards/domain/qr_slot.dart';
import '../../core_engine/common/enums.dart';
import '../../core_engine/common/lookup_option.dart';
import '../../core_engine/common/uploaded_file.dart';

part 'generate_card_state.freezed.dart';

@freezed
sealed class GenerateCardState with _$GenerateCardState {
  const factory GenerateCardState({
    @Default(<LookupOption>[]) List<LookupOption> templateOptions,
    int? selectedTemplateId,
    @Default(<LookupOption>[]) List<LookupOption> combinationOptions,
    int? selectedCombinationId,
    UploadedFile? pdfFile,
    @Default(<QrSlot>[]) List<QrSlot> qrSlots,
    @Default(<String, UploadedFile>{}) Map<String, UploadedFile> qrFiles,
    GeneratedCard? result,

    /// The preview works like the template designer's canvas: front and back side by side by
    /// default, [side] is the card edits go to, and one layer can be selected and adjusted.
    @Default(CardSide.front) CardSide side,
    @Default(true) bool combined,
    String? selectedGroupId,
    @Default(false) bool isBusy,
    String? error,
  }) = _GenerateCardState;
}

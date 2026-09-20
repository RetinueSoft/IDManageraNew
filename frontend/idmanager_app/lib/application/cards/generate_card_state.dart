import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core_engine/cards/domain/generated_card.dart';
import '../../core_engine/cards/domain/qr_slot.dart';
import '../../core_engine/common/enums.dart';
import '../../core_engine/common/lookup_option.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../../core_engine/templates/domain/card_template.dart';

part 'generate_card_state.freezed.dart';

@freezed
sealed class GenerateCardState with _$GenerateCardState {
  const factory GenerateCardState({
    @Default(<LookupOption>[]) List<LookupOption> templateOptions,
    int? selectedTemplateId,

    /// The selected template with its backgrounds (its own plus any it has added).
    CardTemplateDetail? template,

    /// The background the card is printed on (0 = the template's own). It can be switched
    /// before and after previewing without generating again.
    @Default(0) int selectedCombinationId,
    UploadedFile? pdfFile,
    @Default(<QrSlot>[]) List<QrSlot> qrSlots,
    @Default(<String, UploadedFile>{}) Map<String, UploadedFile> qrFiles,
    GeneratedCard? result,

    /// The background [result] was generated with - what the download prints on. Choosing another
    /// background does not change the preview until Preview is pressed again.
    int? resultCombinationId,

    /// The preview works like the template designer's canvas: front and back side by side by
    /// default, [side] is the card edits go to, and one layer can be selected and adjusted.
    @Default(CardSide.front) CardSide side,
    @Default(true) bool combined,
    String? selectedGroupId,
    @Default(false) bool isBusy,
    String? error,
  }) = _GenerateCardState;
}

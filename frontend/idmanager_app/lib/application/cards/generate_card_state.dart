import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core_engine/cards/domain/generated_card.dart';
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
    GeneratedCard? result,
    @Default(false) bool isBusy,
    String? error,
  }) = _GenerateCardState;
}

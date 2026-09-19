import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core_engine/common/uploaded_file.dart';

part 'template_form_state.freezed.dart';

@freezed
sealed class TemplateFormState with _$TemplateFormState {
  const factory TemplateFormState({
    @Default('') String name,
    @Default(85.6) double cardWidthMm,
    @Default(54.0) double cardHeightMm,
    @Default(1) int pointCost,
    @Default(true) bool isActive,
    UploadedFile? frontFile,
    UploadedFile? backFile,
    String? existingFrontImageBase64,
    String? existingBackImageBase64,
    @Default(<String, String>{}) Map<String, String> errors,
    @Default(false) bool isSaving,
  }) = _TemplateFormState;
}

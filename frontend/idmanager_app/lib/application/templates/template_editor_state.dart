import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core_engine/common/enums.dart';
import '../../core_engine/templates/domain/card_template.dart';
import '../../core_engine/templates/domain/template_layer.dart';

part 'template_editor_state.freezed.dart';

@freezed
sealed class TemplateEditorState with _$TemplateEditorState {
  const factory TemplateEditorState({
    required CardTemplateDetail template,
    required List<TemplateLayer> layers,
    @Default(CardSide.front) CardSide side,
    String? selectedGroupId,
    @Default(false) bool isSaving,
  }) = _TemplateEditorState;
}

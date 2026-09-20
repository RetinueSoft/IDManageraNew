import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core_engine/common/enums.dart';
import '../../core_engine/templates/domain/card_template.dart';
import '../../core_engine/templates/domain/field_group.dart';
import '../../core_engine/templates/domain/template_layer.dart';

part 'template_editor_state.freezed.dart';

@freezed
sealed class TemplateEditorState with _$TemplateEditorState {
  const factory TemplateEditorState({
    required CardTemplateDetail template,
    required List<TemplateLayer> layers,
    /// Fields extracted from the template's one sample PDF - the palette layers are added from.
    @Default(<ExtractedField>[]) List<ExtractedField> sampleFields,
    /// The side edits go to (add/delete layer, the layers list, the properties panel). In the
    /// combined view it is the side of the layer last clicked.
    @Default(CardSide.front) CardSide side,

    /// Show the front and back cards side by side (the default), each editable.
    @Default(true) bool combined,
    String? selectedGroupId,
    @Default(false) bool isSaving,
  }) = _TemplateEditorState;
}

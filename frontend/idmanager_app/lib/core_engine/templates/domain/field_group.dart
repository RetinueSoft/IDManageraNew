import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/enums.dart';

part 'field_group.freezed.dart';

/// A field extracted from a parsed sample PDF, before it's dragged onto a layer
/// position.
@freezed
sealed class ExtractedField with _$ExtractedField {
  const factory ExtractedField({
    String? key,
    String? value,
    @Default(LayerFieldType.text) LayerFieldType type,
  }) = _ExtractedField;
}

@freezed
sealed class FieldGroup with _$FieldGroup {
  const factory FieldGroup({
    required String name,
    @Default(0) int index,
    @Default(<ExtractedField>[]) List<ExtractedField> items,
  }) = _FieldGroup;
}

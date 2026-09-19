import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/enums.dart';

part 'template_layer.freezed.dart';

/// The physical-unit layer model. All geometry is in millimeters relative to the
/// template's card size, so on-screen zoom is a pure view transform and PDF export
/// renders at true size regardless of the source image's pixel resolution.
@freezed
sealed class LayerSourceItem with _$LayerSourceItem {
  const factory LayerSourceItem({
    String? key,
    String? value,
    @Default(LayerFieldType.text) LayerFieldType type,
    String? separator,
  }) = _LayerSourceItem;
}

@freezed
sealed class LayerGroup with _$LayerGroup {
  const factory LayerGroup({
    /// Client-side only identity for the designer canvas (drag/select/delete) -
    /// never sent to or read from the backend, which has no concept of it.
    required String id,
    required String name,
    @Default(LayerFieldType.text) LayerFieldType fieldType,
    required double xMm,
    required double yMm,
    double? widthMm,
    double? heightMm,
    @Default(10) double fontSizePt,
    @Default(5) double lineHeightMm,
    double? keyWidthMm,
    double? valueWidthMm,
    @Default(false) bool bold,
    @Default(false) bool isList,
    @Default(false) bool emptyLineEveryAfter,
    @Default(false) bool newLineAfterFirst,
    @Default(false) bool newLineBeforeLast,
    @Default(false) bool formatAsDate,
    @Default(false) bool useDashSeparator,
    @Default(<LayerSourceItem>[]) List<LayerSourceItem> sources,
  }) = _LayerGroup;
}

@freezed
sealed class TemplateLayer with _$TemplateLayer {
  const factory TemplateLayer({
    required CardSide side,
    @Default(<LayerGroup>[]) List<LayerGroup> groups,
  }) = _TemplateLayer;
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/enums.dart';

part 'template_layer.freezed.dart';

/// The physical-unit layer model. All geometry is in millimeters relative to the
/// template's card size, so on-screen zoom is a pure view transform and PDF export
/// renders at true size regardless of the source image's pixel resolution.
@freezed
sealed class LayerSourceItem with _$LayerSourceItem {
  const factory LayerSourceItem({
    /// What is printed before the value ("key: value"); empty prints the value alone. Also the
    /// PDF field this source reads, unless [sourceKey] says otherwise.
    String? key,

    /// The field of the member's PDF this source reads its value from, when that is not
    /// [key] - so a label can be hidden or different without losing the link to the PDF.
    /// Null means "read [key]". A source with neither is fixed text, never overwritten.
    String? sourceKey,
    String? value,
    @Default(LayerFieldType.text) LayerFieldType type,

    /// In a combined (List) layer: how this field joins the NEXT one - a
    /// JoinSeparator wire name ('comma', 'dash', 'space', 'newline'). Null means comma.
    String? separator,

    /// In a combined layer: this entry is not a field but one empty line.
    @Default(false) bool emptyLine,
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
    /// A combined group: all [sources] render as one text, each joined to the next by
    /// its own separator.
    @Default(false) bool isList,

    /// In a combined layer: extra space (mm) added between all of its lines, common
    /// to the whole layer. 0 keeps the normal line spacing.
    @Default(0) double lineGapMm,

    /// An image layer left empty in the template; the card generator fills it with an
    /// image the user picks (a QR code). Its source's key names the slot, e.g. 'QR 1'.
    @Default(false) bool isQr,

    /// Words stripped out of every field's value in this layer (e.g. 'எண்' from
    /// 'எண் :117 கூளமடை'), whole words only, never from keys. One list per layer.
    @Default(<String>[]) List<String> removeWords,

    /// In a combined layer: print each field on its own line with a bullet point.
    @Default(false) bool bulletList,
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

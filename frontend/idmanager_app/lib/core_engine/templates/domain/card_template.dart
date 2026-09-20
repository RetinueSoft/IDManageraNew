import 'package:freezed_annotation/freezed_annotation.dart';

import 'field_group.dart';
import 'template_layer.dart';

part 'card_template.freezed.dart';

@freezed
sealed class Combination with _$Combination {
  const factory Combination({
    required int id,
    required String name,
    required String frontImageBase64,
    required String backImageBase64,
  }) = _Combination;
}

@freezed
sealed class CardTemplate with _$CardTemplate {
  const factory CardTemplate({
    required int id,
    required String name,
    required double cardWidthMm,
    required double cardHeightMm,
    required int pointCost,
    required bool isActive,

    /// What a downloaded card PDF is called - the member's PDF fields as {Field}, e.g.
    /// '{Name} - {Card No}'. Null means "card-<id>".
    String? fileNamePattern,
    required String frontImageBase64,
    required String backImageBase64,
    required DateTime createdAt,
  }) = _CardTemplate;
}

/// The full designer payload: [template]'s summary plus its field groups, layers
/// and combinations.
@freezed
sealed class CardTemplateDetail with _$CardTemplateDetail {
  const factory CardTemplateDetail({
    required CardTemplate template,
    @Default(<FieldGroup>[]) List<FieldGroup> groups,
    @Default(<TemplateLayer>[]) List<TemplateLayer> layers,
    @Default(<Combination>[]) List<Combination> combinations,
  }) = _CardTemplateDetail;
}

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../templates/domain/template_layer.dart';

part 'generated_card.freezed.dart';

@freezed
sealed class GeneratedCard with _$GeneratedCard {
  const factory GeneratedCard({
    required int idCardId,
    @Default(<TemplateLayer>[]) List<TemplateLayer> layers,
    required double cardWidthMm,
    required double cardHeightMm,
    required String frontImageBase64,
    required String backImageBase64,
  }) = _GeneratedCard;
}

import 'layer.dart';

class GenerateCardResponse {
  final int idCardId;
  final List<TemplateLayer> layers;
  final double cardWidthMm;
  final double cardHeightMm;
  final String frontImageBase64;
  final String backImageBase64;

  GenerateCardResponse({
    required this.idCardId,
    required this.layers,
    required this.cardWidthMm,
    required this.cardHeightMm,
    required this.frontImageBase64,
    required this.backImageBase64,
  });

  factory GenerateCardResponse.fromJson(Map<String, dynamic> json) => GenerateCardResponse(
        idCardId: json['idCardId'] as int,
        layers: (json['layers'] as List<dynamic>? ?? [])
            .map((e) => TemplateLayer.fromJson(e as Map<String, dynamic>))
            .toList(),
        cardWidthMm: (json['cardWidthMm'] as num?)?.toDouble() ?? 85.6,
        cardHeightMm: (json['cardHeightMm'] as num?)?.toDouble() ?? 54.0,
        frontImageBase64: json['frontImageBase64'] as String? ?? '',
        backImageBase64: json['backImageBase64'] as String? ?? '',
      );
}

import 'enums.dart';
import 'layer.dart';

class ExtractedField {
  String? key;
  String? value;
  LayerFieldType type;

  ExtractedField({this.key, this.value, this.type = LayerFieldType.text});

  factory ExtractedField.fromJson(Map<String, dynamic> json) => ExtractedField(
        key: json['key'] as String?,
        value: json['value'] as String?,
        type: LayerFieldType.fromInt(json['type'] as int? ?? 1),
      );

  Map<String, dynamic> toJson() => {'key': key, 'value': value, 'type': type.toInt()};
}

class FieldGroup {
  String name;
  int index;
  List<ExtractedField> items;

  FieldGroup({required this.name, this.index = 0, List<ExtractedField>? items}) : items = items ?? [];

  factory FieldGroup.fromJson(Map<String, dynamic> json) => FieldGroup(
        name: json['name'] as String? ?? '',
        index: json['index'] as int? ?? 0,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => ExtractedField.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'index': index,
        'items': items.map((i) => i.toJson()).toList(),
      };
}

class CombinationDto {
  final int id;
  final String name;
  final String frontImageBase64;
  final String backImageBase64;

  CombinationDto({
    required this.id,
    required this.name,
    required this.frontImageBase64,
    required this.backImageBase64,
  });

  factory CombinationDto.fromJson(Map<String, dynamic> json) => CombinationDto(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        frontImageBase64: json['frontImageBase64'] as String? ?? '',
        backImageBase64: json['backImageBase64'] as String? ?? '',
      );
}

class TemplateSummary {
  final int id;
  final String name;
  final double cardWidthMm;
  final double cardHeightMm;
  final int pointCost;
  final bool status;
  final String frontImageBase64;
  final String backImageBase64;
  final DateTime createdAt;

  TemplateSummary({
    required this.id,
    required this.name,
    required this.cardWidthMm,
    required this.cardHeightMm,
    required this.pointCost,
    required this.status,
    required this.frontImageBase64,
    required this.backImageBase64,
    required this.createdAt,
  });

  factory TemplateSummary.fromJson(Map<String, dynamic> json) => TemplateSummary(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        cardWidthMm: (json['cardWidthMm'] as num?)?.toDouble() ?? 85.6,
        cardHeightMm: (json['cardHeightMm'] as num?)?.toDouble() ?? 54.0,
        pointCost: json['pointCost'] as int? ?? 1,
        status: json['status'] as bool? ?? false,
        frontImageBase64: json['frontImageBase64'] as String? ?? '',
        backImageBase64: json['backImageBase64'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class TemplateDetail extends TemplateSummary {
  final List<FieldGroup> groups;
  final List<TemplateLayer> layers;
  final List<CombinationDto> combinations;

  TemplateDetail({
    required super.id,
    required super.name,
    required super.cardWidthMm,
    required super.cardHeightMm,
    required super.pointCost,
    required super.status,
    required super.frontImageBase64,
    required super.backImageBase64,
    required super.createdAt,
    required this.groups,
    required this.layers,
    required this.combinations,
  });

  factory TemplateDetail.fromJson(Map<String, dynamic> json) => TemplateDetail(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        cardWidthMm: (json['cardWidthMm'] as num?)?.toDouble() ?? 85.6,
        cardHeightMm: (json['cardHeightMm'] as num?)?.toDouble() ?? 54.0,
        pointCost: json['pointCost'] as int? ?? 1,
        status: json['status'] as bool? ?? false,
        frontImageBase64: json['frontImageBase64'] as String? ?? '',
        backImageBase64: json['backImageBase64'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        groups: (json['groups'] as List<dynamic>? ?? [])
            .map((e) => FieldGroup.fromJson(e as Map<String, dynamic>))
            .toList(),
        layers: (json['layers'] as List<dynamic>? ?? [])
            .map((e) => TemplateLayer.fromJson(e as Map<String, dynamic>))
            .toList(),
        combinations: (json['combinations'] as List<dynamic>? ?? [])
            .map((e) => CombinationDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

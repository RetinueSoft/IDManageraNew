import '../../core_engine/common/enums.dart';
import '../../core_engine/common/id_generator.dart';
import '../../core_engine/templates/domain/card_template.dart';
import '../../core_engine/templates/domain/field_group.dart';
import '../../core_engine/templates/domain/template_layer.dart';

LayerSourceItem sourceItemFromJson(Map<String, dynamic> json) => LayerSourceItem(
  key: json['key'] as String?,
  sourceKey: json['sourceKey'] as String?,
  value: json['value'] as String?,
  type: LayerFieldType.fromInt(json['type'] as int? ?? 1),
  separator: json['separator'] as String?,
  emptyLine: json['emptyLine'] as bool? ?? false,
);

Map<String, dynamic> sourceItemToJson(LayerSourceItem s) => {
  'key': s.key,
  'sourceKey': s.sourceKey,
  'value': s.value,
  'type': s.type.toInt(),
  'separator': s.separator,
  'emptyLine': s.emptyLine,
};

LayerGroup layerGroupFromJson(Map<String, dynamic> json) => LayerGroup(
  id: IdGenerator.generate(),
  name: json['name'] as String? ?? '',
  fieldType: LayerFieldType.fromInt(json['fieldType'] as int? ?? 1),
  xMm: (json['xMm'] as num?)?.toDouble() ?? 0,
  yMm: (json['yMm'] as num?)?.toDouble() ?? 0,
  widthMm: (json['widthMm'] as num?)?.toDouble(),
  heightMm: (json['heightMm'] as num?)?.toDouble(),
  fontSizePt: (json['fontSizePt'] as num?)?.toDouble() ?? 10,
  lineHeightMm: (json['lineHeightMm'] as num?)?.toDouble() ?? 5,
  keyWidthMm: (json['keyWidthMm'] as num?)?.toDouble(),
  valueWidthMm: (json['valueWidthMm'] as num?)?.toDouble(),
  bold: json['bold'] as bool? ?? false,
  isList: json['isList'] as bool? ?? false,
  lineGapMm: (json['lineGapMm'] as num?)?.toDouble() ?? 0,
  isQr: json['isQr'] as bool? ?? false,
  removeWords: [for (final w in json['removeWords'] as List<dynamic>? ?? const []) w as String],
  dateFormat: json['dateFormat'] as String?,
  bulletList: json['bulletList'] as bool? ?? false,
  emptyLineEveryAfter: json['emptyLineEveryAfter'] as bool? ?? false,
  newLineAfterFirst: json['newLineAfterFirst'] as bool? ?? false,
  newLineBeforeLast: json['newLineBeforeLast'] as bool? ?? false,
  formatAsDate: json['formatAsDate'] as bool? ?? false,
  useDashSeparator: json['useDashSeparator'] as bool? ?? false,
  sources: (json['sources'] as List<dynamic>? ?? [])
      .map((e) => sourceItemFromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> layerGroupToJson(LayerGroup g) => {
  'name': g.name,
  'fieldType': g.fieldType.toInt(),
  'xMm': g.xMm,
  'yMm': g.yMm,
  'widthMm': g.widthMm,
  'heightMm': g.heightMm,
  'fontSizePt': g.fontSizePt,
  'lineHeightMm': g.lineHeightMm,
  'keyWidthMm': g.keyWidthMm,
  'valueWidthMm': g.valueWidthMm,
  'bold': g.bold,
  'isList': g.isList,
  'lineGapMm': g.lineGapMm,
  'isQr': g.isQr,
  'removeWords': g.removeWords,
  'dateFormat': g.dateFormat,
  'bulletList': g.bulletList,
  'emptyLineEveryAfter': g.emptyLineEveryAfter,
  'newLineAfterFirst': g.newLineAfterFirst,
  'newLineBeforeLast': g.newLineBeforeLast,
  'formatAsDate': g.formatAsDate,
  'useDashSeparator': g.useDashSeparator,
  'sources': g.sources.map(sourceItemToJson).toList(),
};

TemplateLayer templateLayerFromJson(Map<String, dynamic> json) => TemplateLayer(
  side: CardSide.fromInt(json['side'] as int? ?? 1),
  groups: (json['groups'] as List<dynamic>? ?? [])
      .map((e) => layerGroupFromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> templateLayerToJson(TemplateLayer l) => {
  'side': l.side.toInt(),
  'groups': l.groups.map(layerGroupToJson).toList(),
};

ExtractedField extractedFieldFromJson(Map<String, dynamic> json) => ExtractedField(
  key: json['key'] as String?,
  value: json['value'] as String?,
  type: LayerFieldType.fromInt(json['type'] as int? ?? 1),
);

Map<String, dynamic> extractedFieldToJson(ExtractedField f) => {
  'key': f.key,
  'value': f.value,
  'type': f.type.toInt(),
};

Map<String, dynamic> fieldGroupToJson(FieldGroup g) => {
  'name': g.name,
  'index': g.index,
  'items': g.items.map(extractedFieldToJson).toList(),
};

FieldGroup fieldGroupFromJson(Map<String, dynamic> json) => FieldGroup(
  name: json['name'] as String? ?? '',
  index: json['index'] as int? ?? 0,
  items: (json['items'] as List<dynamic>? ?? [])
      .map((e) => extractedFieldFromJson(e as Map<String, dynamic>))
      .toList(),
);

Combination combinationFromJson(Map<String, dynamic> json) => Combination(
  id: json['id'] as int,
  name: json['name'] as String? ?? '',
  frontImageBase64: json['frontImageBase64'] as String? ?? '',
  backImageBase64: json['backImageBase64'] as String? ?? '',
);

CardTemplate cardTemplateFromJson(Map<String, dynamic> json) => CardTemplate(
  id: json['id'] as int,
  name: json['name'] as String? ?? '',
  cardWidthMm: (json['cardWidthMm'] as num?)?.toDouble() ?? 85.6,
  cardHeightMm: (json['cardHeightMm'] as num?)?.toDouble() ?? 54.0,
  pointCost: json['pointCost'] as int? ?? 1,
  isActive: json['isActive'] as bool? ?? false,
  frontImageBase64: json['frontImageBase64'] as String? ?? '',
  backImageBase64: json['backImageBase64'] as String? ?? '',
  createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
);

CardTemplateDetail cardTemplateDetailFromJson(Map<String, dynamic> json) => CardTemplateDetail(
  template: cardTemplateFromJson(json),
  groups: (json['groups'] as List<dynamic>? ?? [])
      .map((e) => fieldGroupFromJson(e as Map<String, dynamic>))
      .toList(),
  layers: (json['layers'] as List<dynamic>? ?? [])
      .map((e) => templateLayerFromJson(e as Map<String, dynamic>))
      .toList(),
  combinations: (json['combinations'] as List<dynamic>? ?? [])
      .map((e) => combinationFromJson(e as Map<String, dynamic>))
      .toList(),
);

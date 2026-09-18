import 'enums.dart';

/// The physical-unit layer model. All geometry is in millimeters relative to the
/// template's card size, so on-screen zoom is a pure view transform and PDF export
/// renders at true size regardless of the source image's pixel resolution.
class LayerSourceItem {
  String? key;
  String? value;
  LayerFieldType type;
  String? separator;

  LayerSourceItem({this.key, this.value, this.type = LayerFieldType.text, this.separator});

  factory LayerSourceItem.fromJson(Map<String, dynamic> json) => LayerSourceItem(
        key: json['key'] as String?,
        value: json['value'] as String?,
        type: LayerFieldType.fromInt(json['type'] as int? ?? 1),
        separator: json['separator'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
        'type': type.toInt(),
        'separator': separator,
      };
}

class LayerGroup {
  String name;
  LayerFieldType fieldType;
  double xMm;
  double yMm;
  double? widthMm;
  double? heightMm;
  double fontSizePt;
  double lineHeightMm;
  double? keyWidthMm;
  double? valueWidthMm;
  bool bold;
  bool isList;
  bool emptyLineEveryAfter;
  bool newLineAfterFirst;
  bool newLineBeforeLast;
  bool formatAsDate;
  bool useDashSeparator;
  List<LayerSourceItem> sources;

  LayerGroup({
    required this.name,
    this.fieldType = LayerFieldType.text,
    required this.xMm,
    required this.yMm,
    this.widthMm,
    this.heightMm,
    this.fontSizePt = 10,
    this.lineHeightMm = 5,
    this.keyWidthMm,
    this.valueWidthMm,
    this.bold = false,
    this.isList = false,
    this.emptyLineEveryAfter = false,
    this.newLineAfterFirst = false,
    this.newLineBeforeLast = false,
    this.formatAsDate = false,
    this.useDashSeparator = false,
    List<LayerSourceItem>? sources,
  }) : sources = sources ?? [];

  factory LayerGroup.fromJson(Map<String, dynamic> json) => LayerGroup(
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
        emptyLineEveryAfter: json['emptyLineEveryAfter'] as bool? ?? false,
        newLineAfterFirst: json['newLineAfterFirst'] as bool? ?? false,
        newLineBeforeLast: json['newLineBeforeLast'] as bool? ?? false,
        formatAsDate: json['formatAsDate'] as bool? ?? false,
        useDashSeparator: json['useDashSeparator'] as bool? ?? false,
        sources: (json['sources'] as List<dynamic>? ?? [])
            .map((e) => LayerSourceItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'fieldType': fieldType.toInt(),
        'xMm': xMm,
        'yMm': yMm,
        'widthMm': widthMm,
        'heightMm': heightMm,
        'fontSizePt': fontSizePt,
        'lineHeightMm': lineHeightMm,
        'keyWidthMm': keyWidthMm,
        'valueWidthMm': valueWidthMm,
        'bold': bold,
        'isList': isList,
        'emptyLineEveryAfter': emptyLineEveryAfter,
        'newLineAfterFirst': newLineAfterFirst,
        'newLineBeforeLast': newLineBeforeLast,
        'formatAsDate': formatAsDate,
        'useDashSeparator': useDashSeparator,
        'sources': sources.map((s) => s.toJson()).toList(),
      };
}

class TemplateLayer {
  CardSide side;
  List<LayerGroup> groups;

  TemplateLayer({required this.side, List<LayerGroup>? groups}) : groups = groups ?? [];

  factory TemplateLayer.fromJson(Map<String, dynamic> json) => TemplateLayer(
        side: CardSide.fromInt(json['side'] as int? ?? 1),
        groups: (json['groups'] as List<dynamic>? ?? [])
            .map((e) => LayerGroup.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'side': side.toInt(),
        'groups': groups.map((g) => g.toJson()).toList(),
      };
}

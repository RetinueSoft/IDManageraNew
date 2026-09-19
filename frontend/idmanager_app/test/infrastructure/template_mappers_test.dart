import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/common/enums.dart';
import 'package:idmanager_app/core_engine/templates/domain/template_layer.dart';
import 'package:idmanager_app/infrastructure/repositories/template_mappers.dart';

void main() {
  group('LayerSourceItem JSON', () {
    test('round-trips every field', () {
      final source = LayerSourceItem(key: 'Name', value: 'Jane', type: LayerFieldType.text, separator: '-');

      final json = sourceItemToJson(source);
      final back = sourceItemFromJson(json);

      expect(back, source);
    });

    test('toJson emits the backend-expected integer for LayerFieldType, not a string', () {
      final json = sourceItemToJson(LayerSourceItem(type: LayerFieldType.image));
      expect(json['type'], 2);
    });

    test('fromJson defaults an unset/null type to text (backend default = 1)', () {
      final parsed = sourceItemFromJson({'key': null, 'value': null});
      expect(parsed.type, LayerFieldType.text);
    });
  });

  group('LayerGroup JSON', () {
    test('round-trips a text group including formatting flags', () {
      final group = LayerGroup(
        id: 'g1',
        name: 'Name field',
        fieldType: LayerFieldType.text,
        xMm: 12.5,
        yMm: 7.25,
        widthMm: 30,
        fontSizePt: 11,
        lineHeightMm: 5.5,
        bold: true,
        isList: true,
        useDashSeparator: true,
        sources: [LayerSourceItem(key: 'Name', value: 'Jane', type: LayerFieldType.text)],
      );

      final json = layerGroupToJson(group);
      // id is a client-only field for canvas selection - the backend has no
      // concept of it, so it must never be sent.
      expect(json.containsKey('id'), isFalse);

      final back = layerGroupFromJson(json);
      expect(back.name, group.name);
      expect(back.xMm, group.xMm);
      expect(back.yMm, group.yMm);
      expect(back.widthMm, group.widthMm);
      expect(back.fontSizePt, group.fontSizePt);
      expect(back.bold, isTrue);
      expect(back.isList, isTrue);
      expect(back.useDashSeparator, isTrue);
      expect(back.sources.single.value, 'Jane');
    });

    test('fromJson generates a fresh, non-empty client-side id every time', () {
      final json = layerGroupToJson(LayerGroup(id: 'ignored', name: 'X', xMm: 0, yMm: 0));

      final a = layerGroupFromJson(json);
      final b = layerGroupFromJson(json);

      expect(a.id, isNotEmpty);
      expect(b.id, isNotEmpty);
      expect(a.id, isNot(equals(b.id)));
    });
  });

  group('TemplateLayer JSON', () {
    test('round-trips side and nested groups', () {
      final layer = TemplateLayer(
        side: CardSide.back,
        groups: [LayerGroup(id: 'g1', name: 'QR', fieldType: LayerFieldType.image, xMm: 1, yMm: 2, widthMm: 20, heightMm: 20)],
      );

      final json = templateLayerToJson(layer);
      expect(json['side'], 2); // CardSide.back must serialize as 2, matching the backend enum.

      final back = templateLayerFromJson(json);
      expect(back.side, CardSide.back);
      expect(back.groups.single.name, 'QR');
      expect(back.groups.single.fieldType, LayerFieldType.image);
    });
  });

  group('ExtractedField / FieldGroup JSON', () {
    test('fromJson maps every field including type', () {
      final field = extractedFieldFromJson({'key': 'DOB', 'value': '2000-01-01', 'type': 1});
      expect(field.key, 'DOB');
      expect(field.value, '2000-01-01');
      expect(field.type, LayerFieldType.text);
    });

    test('fromJson parses nested items inside a group', () {
      final group = fieldGroupFromJson({
        'name': 'Personal',
        'index': 0,
        'items': [
          {'key': 'Name', 'value': 'Jane', 'type': 1},
        ],
      });

      expect(group.name, 'Personal');
      expect(group.items.single.key, 'Name');
    });
  });

  group('CardTemplate / CardTemplateDetail JSON', () {
    test('cardTemplateFromJson maps the summary fields', () {
      final template = cardTemplateFromJson({
        'id': 5,
        'name': 'Employee Card',
        'cardWidthMm': 85.6,
        'cardHeightMm': 54.0,
        'pointCost': 2,
        'isActive': true,
        'frontImageBase64': 'abc',
        'backImageBase64': 'def',
        'createdAt': '2026-01-01T00:00:00Z',
      });

      expect(template.id, 5);
      expect(template.name, 'Employee Card');
      expect(template.cardWidthMm, 85.6);
      expect(template.isActive, isTrue);
    });

    test('cardTemplateDetailFromJson assembles groups, layers and combinations', () {
      final detail = cardTemplateDetailFromJson({
        'id': 1,
        'name': 'Card',
        'cardWidthMm': 85.6,
        'cardHeightMm': 54.0,
        'pointCost': 1,
        'isActive': true,
        'frontImageBase64': '',
        'backImageBase64': '',
        'createdAt': '2026-01-01T00:00:00Z',
        'groups': [
          {'name': 'Personal', 'index': 0, 'items': []},
        ],
        'layers': [
          {'side': 1, 'groups': []},
        ],
        'combinations': [
          {'id': 1, 'name': 'Gold', 'frontImageBase64': '', 'backImageBase64': ''},
        ],
      });

      expect(detail.template.name, 'Card');
      expect(detail.groups.single.name, 'Personal');
      expect(detail.layers.single.side, CardSide.front);
      expect(detail.combinations.single.name, 'Gold');
    });

    test('cardTemplateDetailFromJson tolerates missing optional collections', () {
      final detail = cardTemplateDetailFromJson({
        'id': 1,
        'name': 'Card',
        'cardWidthMm': 85.6,
        'cardHeightMm': 54.0,
        'pointCost': 1,
        'isActive': true,
        'frontImageBase64': '',
        'backImageBase64': '',
        'createdAt': '2026-01-01T00:00:00Z',
      });

      expect(detail.groups, isEmpty);
      expect(detail.layers, isEmpty);
      expect(detail.combinations, isEmpty);
    });
  });
}

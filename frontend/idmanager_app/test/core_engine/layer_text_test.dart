import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/templates/domain/layer_text.dart';
import 'package:idmanager_app/core_engine/templates/domain/template_layer.dart';

LayerGroup _group(List<LayerSourceItem> sources, {bool bullets = false, double? keyWidthMm}) => LayerGroup(
  id: 'g',
  name: 'g',
  xMm: 0,
  yMm: 0,
  isList: true,
  bulletList: bullets,
  keyWidthMm: keyWidthMm,
  sources: sources,
);

void main() {
  group('LayerGroup.combinedText', () {
    test('prints "key: value" when the key is set and just the value when it is empty', () {
      final g = _group([
        const LayerSourceItem(key: 'Street', value: 'MG Road'),
        const LayerSourceItem(key: '', value: 'Pune'),
      ]);
      expect(g.combinedText, 'Street: MG Road, Pune');
    });

    test('each field joins the next with its own separator, comma by default', () {
      final g = _group([
        const LayerSourceItem(value: 'A', separator: 'dash'),
        const LayerSourceItem(value: 'B'),
        const LayerSourceItem(value: 'C', separator: 'newline'),
        const LayerSourceItem(value: 'D'),
      ]);
      expect(g.combinedText, 'A - B, C\nD');
    });

    test('skips fields with no value without leaving stray separators', () {
      final g = _group([
        const LayerSourceItem(value: 'A', separator: 'dash'),
        const LayerSourceItem(key: 'Empty', value: ''),
        const LayerSourceItem(value: 'C'),
      ]);
      expect(g.combinedText, 'A - C');
    });

    test('an empty line entry puts a blank line between two fields', () {
      final g = _group([
        const LayerSourceItem(value: 'A'),
        const LayerSourceItem(emptyLine: true),
        const LayerSourceItem(value: 'B'),
      ]);
      expect(g.combinedText, 'A\n\nB');
    });

    test('bullet list puts each field on its own bulleted line', () {
      final g = _group([
        const LayerSourceItem(key: 'Street', value: 'MG Road'),
        const LayerSourceItem(value: 'Pune'),
      ], bullets: true);
      expect(g.combinedText, '\u2022 Street: MG Road\n\u2022 Pune');
    });
  });

  group('LayerGroup.bulletRows / hasAlignedKeys', () {
    test('aligned keys need a positive key width, with or without bullets', () {
      final sources = [const LayerSourceItem(key: 'A', value: '1')];
      expect(_group(sources, keyWidthMm: 20).hasAlignedKeys, isTrue);
      expect(_group(sources, bullets: true, keyWidthMm: 20).hasAlignedKeys, isTrue);
      expect(_group(sources, bullets: true).hasAlignedKeys, isFalse);
      expect(_group(sources, keyWidthMm: 0).hasAlignedKeys, isFalse);
    });

    test('rows skip empty values, keep blank lines and drop trailing ones', () {
      final rows = _group([
        const LayerSourceItem(key: 'A', value: '1'),
        const LayerSourceItem(key: 'X', value: ''),
        const LayerSourceItem(emptyLine: true),
        const LayerSourceItem(value: '2'),
        const LayerSourceItem(emptyLine: true),
      ], bullets: true, keyWidthMm: 20).bulletRows;

      expect(rows.map((r) => r.isBlank).toList(), [false, true, false]);
      expect(rows.first.key, 'A');
      expect(rows.last.value, '2');
    });
  });
}

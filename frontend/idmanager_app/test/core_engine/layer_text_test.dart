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

    test('skips a field that has neither a key nor a value, without leaving stray separators', () {
      final g = _group([
        const LayerSourceItem(value: 'A', separator: 'dash'),
        const LayerSourceItem(key: '', value: ''),
        const LayerSourceItem(value: 'C'),
      ]);
      expect(g.combinedText, 'A - C');
    });

    test('a field with a key but no value still prints its key (a label or heading)', () {
      final g = _group([
        const LayerSourceItem(key: 'Address', value: '', separator: 'space'),
        const LayerSourceItem(value: 'MG Road'),
      ]);
      expect(g.combinedText, 'Address: MG Road');
    });

    test('a key-only field is kept in a bullet list too', () {
      final g = _group([
        const LayerSourceItem(key: 'Members', value: ''),
        const LayerSourceItem(value: 'Asha'),
      ], bullets: true);
      expect(g.combinedText, '• Members:\n• Asha');
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

    test('rows keep a key with no value (its label), skip fully empty fields', () {
      final rows = _group([
        const LayerSourceItem(key: 'Address', value: ''),
        const LayerSourceItem(key: '', value: ''),
        const LayerSourceItem(key: 'City', value: 'Pune'),
      ], keyWidthMm: 20).bulletRows;

      expect(rows.map((r) => r.key).toList(), ['Address', 'City']);
      expect(rows.first.value, '');
    });

    test('rows skip empty values, keep blank lines and drop trailing ones', () {
      final rows = _group([
        const LayerSourceItem(key: 'A', value: '1'),
        const LayerSourceItem(key: '', value: ''),
        const LayerSourceItem(emptyLine: true),
        const LayerSourceItem(value: '2'),
        const LayerSourceItem(emptyLine: true),
      ], bullets: true, keyWidthMm: 20).bulletRows;

      expect(rows.map((r) => r.isBlank).toList(), [false, true, false]);
      expect(rows.first.key, 'A');
      expect(rows.last.value, '2');
    });

    // ---- a key with value-only fields after it: one row, a hanging label ----

    test('value-only fields after a key continue its row, joined by their own separators', () {
      final rows = _group([
        const LayerSourceItem(key: 'Address', value: '', separator: 'space'),
        const LayerSourceItem(value: 'Line 1'),
        const LayerSourceItem(key: '', value: ''), // empty: skipped, no stray separator
        const LayerSourceItem(value: 'Village'),
        const LayerSourceItem(value: 'District', separator: 'dash'),
        const LayerSourceItem(value: '614001'),
      ], keyWidthMm: 20).bulletRows;

      expect(rows, hasLength(1));
      expect(rows.single.key, 'Address');
      expect(rows.single.value, 'Line 1, Village, District - 614001');
    });

    test('a newline separator inside a row breaks the value onto a new line in the value column', () {
      final rows = _group([
        const LayerSourceItem(key: 'Address', value: 'Line 1', separator: 'newline'),
        const LayerSourceItem(value: 'Line 2'),
      ], keyWidthMm: 20).bulletRows;

      expect(rows.single.value, 'Line 1\nLine 2');
    });

    test('the next key starts a new row, and the value-only fields after it continue that one', () {
      final rows = _group([
        const LayerSourceItem(key: 'Name', value: 'Asha'),
        const LayerSourceItem(key: 'Address', value: ''),
        const LayerSourceItem(value: 'MG Road'),
        const LayerSourceItem(value: 'Pune'),
      ], keyWidthMm: 20).bulletRows;

      expect(rows.map((r) => r.key).toList(), ['Name', 'Address']);
      expect(rows.map((r) => r.value).toList(), ['Asha', 'MG Road, Pune']);
    });

    test('value-only fields with no key before them form one row with no label column', () {
      final rows = _group([
        const LayerSourceItem(value: 'A'),
        const LayerSourceItem(value: 'B'),
      ], keyWidthMm: 20).bulletRows;

      expect(rows, hasLength(1));
      expect(rows.single.key, '');
      expect(rows.single.value, 'A, B');
    });

    test('an empty line ends the row: what follows starts fresh', () {
      final rows = _group([
        const LayerSourceItem(key: 'Address', value: 'MG Road'),
        const LayerSourceItem(emptyLine: true),
        const LayerSourceItem(value: 'Notes'),
      ], keyWidthMm: 20).bulletRows;

      expect(rows.map((r) => r.isBlank).toList(), [false, true, false]);
      expect(rows.last.key, '');
      expect(rows.last.value, 'Notes');
    });

    test('in a bullet list every field stays its own row', () {
      final rows = _group([
        const LayerSourceItem(key: 'Address', value: ''),
        const LayerSourceItem(value: 'MG Road'),
        const LayerSourceItem(value: 'Pune'),
      ], bullets: true, keyWidthMm: 20).bulletRows;

      expect(rows.map((r) => r.value).toList(), ['', 'MG Road', 'Pune']);
    });
  });
}

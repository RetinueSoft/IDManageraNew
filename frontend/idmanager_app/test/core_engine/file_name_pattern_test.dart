import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/templates/domain/field_group.dart';
import 'package:idmanager_app/core_engine/templates/domain/file_name_pattern.dart';

List<ExtractedField> fields(Map<String, String> values) => [
  for (final e in values.entries) ExtractedField(key: e.key, value: e.value),
];

void main() {
  group('previewFileName', () {
    test('fills fields into the pattern', () {
      expect(
        previewFileName('{Name} - {Card No}', fields({'Name': 'Ravi Kumar', 'Card No': '1234567890'})),
        'Ravi Kumar - 1234567890',
      );
    });

    test('matches field names ignoring case and spaces', () {
      expect(previewFileName('{ name }-{CARD   no}', fields({'Name': 'Ravi', 'card no': '42'})), 'Ravi-42');
    });

    test('a name without fields is used as written', () {
      expect(previewFileName('Member card', fields({})), 'Member card');
    });

    test('no pattern, or nothing usable, means no name', () {
      expect(previewFileName(null, fields({'Name': 'Ravi'})), isNull);
      expect(previewFileName('   ', fields({'Name': 'Ravi'})), isNull);
      expect(previewFileName('{Name}', fields({'Other': 'x'})), isNull);
    });

    test('a missing field leaves no dangling separator', () {
      expect(previewFileName('{Name} - {Card No}', fields({'Name': 'Ravi'})), 'Ravi');
      expect(previewFileName('{Name} - {Card No}', fields({'Card No': '1234'})), '1234');
    });

    test('blank values count as missing; the first value of a field wins', () {
      expect(previewFileName('{Name}_{No}', fields({'Name': 'Ravi', 'No': '  '})), 'Ravi');
      expect(
        previewFileName('{Name}', [const ExtractedField(key: 'Name', value: 'First'), const ExtractedField(key: 'name', value: 'Second')]),
        'First',
      );
    });

    test('characters no file system allows are cleaned up', () {
      expect(previewFileName('{F}', fields({'F': '01/01/1968'})), '01-01-1968');
      expect(previewFileName('{F}', fields({'F': r'a\b:c'})), 'a-b-c');
      expect(previewFileName('{F}', fields({'F': 'what?*<>|"'})), 'what');
      expect(previewFileName('{F}', fields({'F': 'many   spaces'})), 'many spaces');
      expect(previewFileName('{F}', fields({'F': 'ends with dot.'})), 'ends with dot');
    });

    test('Tamil names are kept', () {
      expect(
        previewFileName('{பெயர்} - {எண்}', fields({'பெயர்': 'ரவி குமார்', 'எண்': '117'})),
        'ரவி குமார் - 117',
      );
    });

    test('a long name is shortened', () {
      expect(previewFileName('{Name}', fields({'Name': 'a' * 500}))!.length, maxFileNameLength);
    });
  });

  test('fieldsInFileNamePattern lists the placeholders', () {
    expect(fieldsInFileNamePattern('{Name} - { Card No } - x'), ['Name', 'Card No']);
    expect(fieldsInFileNamePattern('plain'), isEmpty);
    expect(fieldsInFileNamePattern(null), isEmpty);
    expect(fieldsInFileNamePattern('{}'), isEmpty);
  });
}

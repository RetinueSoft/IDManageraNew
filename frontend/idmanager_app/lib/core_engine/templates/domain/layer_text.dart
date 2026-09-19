import 'template_layer.dart';
import 'value_cleaner.dart';

/// How a combined (List) layer joins its fields.
enum JoinSeparator {
  comma('comma', ', ', 'Comma ( , )'),
  dash('dash', ' - ', 'Dash ( - )'),
  space('space', ' ', 'Space'),
  newLine('newline', '\n', 'New line');

  const JoinSeparator(this.wireName, this.text, this.label);

  /// The value stored in the layer JSON (matches the backend's JoinSeparator).
  final String wireName;
  final String text;
  final String label;

  static JoinSeparator fromWireName(String? name) =>
      values.firstWhere((s) => s.wireName == name, orElse: () => comma);

  /// Null when [name] is null or unknown.
  static JoinSeparator? tryFromWireName(String? name) {
    for (final s in values) {
      if (s.wireName == name) return s;
    }
    return null;
  }
}

/// One line of an aligned bullet list (see [LayerGroupText.bulletRows]).
class BulletRow {
  const BulletRow.blank() : key = '', value = '', isBlank = true;
  const BulletRow(this.key, this.value) : isBlank = false;

  final String key;
  final String value;
  final bool isBlank;
}

extension LayerGroupText on LayerGroup {
  /// A field's value as printed in a combined layer: trimmed, with the layer's words to remove
  /// taken out. Must match the backend's ValueCleaner.RemoveWords(value.Trim()).Trim().
  String cleanValue(String? value) => removeWordsFrom((value ?? '').trim(), removeWords).trim();

  /// A combined layer with a key width: every field is its own row and the keys share
  /// one column ([keyWidthMm] wide) so the separators and values line up. (Bullets are
  /// optional.) Must match PdfGenerationService's aligned table.
  bool get hasAlignedKeys => isList && (keyWidthMm ?? 0) > 0;

  /// The rows of an aligned layer (a key width is set).
  ///
  /// A field with a key starts a row: the key in the key column, the value in the value
  /// column. Value-only fields after it *continue that row's value*, joined by their own
  /// separators (comma, dash, new line...), so a label such as "Address" can head a run of
  /// values that flow together in the value column and wrap under it. The next key starts
  /// a new row. A key with no value keeps its label; a field with neither key nor value is
  /// skipped. An "empty line" entry adds a blank row and ends the current row; trailing
  /// blank rows are dropped.
  ///
  /// In a bullet list every field is its own row (its own bullet). Must match
  /// PdfGenerationService.BulletRows on the backend.
  List<BulletRow> get bulletRows {
    final keys = <String>[];
    final values = <String>[];
    final blanks = <bool>[];
    var openRow = -1; // the row a value-only field may continue (never in a bullet list)
    var pendingJoin = '';

    for (final s in sources) {
      if (s.emptyLine) {
        keys.add('');
        values.add('');
        blanks.add(true);
        openRow = -1;
        continue;
      }
      final key = (s.key ?? '').trim();
      final value = cleanValue(s.value);
      if (key.isEmpty && value.isEmpty) continue;

      if (!bulletList && key.isEmpty && openRow >= 0) {
        values[openRow] = values[openRow].isEmpty ? value : '${values[openRow]}$pendingJoin$value';
      } else {
        keys.add(key);
        values.add(value);
        blanks.add(false);
        openRow = bulletList ? -1 : keys.length - 1;
      }
      pendingJoin = (JoinSeparator.tryFromWireName(s.separator) ?? JoinSeparator.comma).text;
    }

    final rows = [
      for (var i = 0; i < keys.length; i++) blanks[i] ? const BulletRow.blank() : BulletRow(keys[i], values[i]),
    ];
    while (rows.isNotEmpty && rows.last.isBlank) {
      rows.removeLast();
    }
    return rows;
  }

  /// The text of a combined layer: each field as "key: value" (just the value when its key
  /// is empty, and "key:" when it has a key but no value - a label or heading), skipping
  /// only fields that have neither a key nor a value. Each field is followed by its
  /// own separator (comma unless set) before the next field. An "empty line" entry
  /// turns the gap before the next field into a blank line. With [bulletList] every
  /// field gets a "•" bullet and its own line. Must match
  /// PdfGenerationService.CombinedText on the backend.
  String get combinedText {
    final keyValueSeparator = useDashSeparator ? '-' : ':';

    final buffer = StringBuffer();
    var wroteAny = false;
    var pendingJoin = '';
    var emptyLines = 0;

    for (final s in sources) {
      if (s.emptyLine) {
        emptyLines++;
        continue;
      }
      final key = (s.key ?? '').trim();
      final value = cleanValue(s.value);
      if (key.isEmpty && value.isEmpty) continue;

      if (wroteAny) {
        buffer.write(emptyLines > 0 ? '\n' * (emptyLines + 1) : (bulletList ? '\n' : pendingJoin));
      } else if (emptyLines > 0) {
        buffer.write('\n' * emptyLines);
      }

      if (bulletList) buffer.write('\u2022 ');
      if (key.isEmpty) {
        buffer.write(value);
      } else if (value.isEmpty) {
        buffer.write('$key$keyValueSeparator');
      } else {
        buffer.write('$key$keyValueSeparator $value');
      }

      pendingJoin = (JoinSeparator.tryFromWireName(s.separator) ?? JoinSeparator.comma).text;
      wroteAny = true;
      emptyLines = 0;
    }
    return buffer.toString();
  }
}

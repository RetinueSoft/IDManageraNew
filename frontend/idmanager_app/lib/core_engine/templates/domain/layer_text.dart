import 'template_layer.dart';

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
  /// A combined layer with a key width: every field is its own row and the keys share
  /// one column ([keyWidthMm] wide) so the separators and values line up. (Bullets are
  /// optional.) Must match PdfGenerationService's aligned table.
  bool get hasAlignedKeys => isList && (keyWidthMm ?? 0) > 0;

  /// The rows of an aligned layer: one per field that has a key or a value (a key with no
  /// value keeps its label), plus one blank line per "empty line" entry (trailing blank
  /// lines are dropped).
  List<BulletRow> get bulletRows {
    final rows = <BulletRow>[];
    for (final s in sources) {
      if (s.emptyLine) {
        rows.add(const BulletRow.blank());
        continue;
      }
      final key = (s.key ?? '').trim();
      final value = (s.value ?? '').trim();
      if (key.isEmpty && value.isEmpty) continue;
      rows.add(BulletRow(key, value));
    }
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
      final value = (s.value ?? '').trim();
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

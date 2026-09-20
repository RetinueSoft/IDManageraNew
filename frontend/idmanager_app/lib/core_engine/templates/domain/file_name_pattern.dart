import 'field_group.dart';

// A template's file name pattern: what a downloaded card PDF is called, with the member's PDF
// fields as {Field} - e.g. '{Name} - {Card No}'. The backend (PdfFileNameBuilder) builds the real
// name; this mirrors its rules so the designer can show what a pattern will give, from the
// sample PDF's values. Keep the two in step.

const int maxFileNameLength = 100;

final _placeholder = RegExp(r'\{([^{}]*)\}');
final _spaces = RegExp(r'\s+');

String _normalizeKey(String? key) => (key ?? '').trim().replaceAll(_spaces, ' ').toLowerCase();

/// The field names a pattern refers to, in order ('{Name} - {Age}' gives Name, Age).
List<String> fieldsInFileNamePattern(String? pattern) => [
  if (pattern != null && pattern.isNotEmpty)
    for (final m in _placeholder.allMatches(pattern))
      if (m.group(1)!.trim().isNotEmpty) m.group(1)!.trim(),
];

/// The file name (without '.pdf') for [pattern] filled in from [fields] (matched by name, ignoring
/// case and extra spaces), or null when there is no pattern or nothing usable is left.
String? previewFileName(String? pattern, Iterable<ExtractedField> fields) {
  if (pattern == null || pattern.trim().isEmpty) return null;

  final byKey = <String, String>{};
  for (final f in fields) {
    final key = _normalizeKey(f.key);
    final value = f.value ?? '';
    if (key.isEmpty || value.trim().isEmpty) continue;
    byKey.putIfAbsent(key, () => value);
  }

  final filled = pattern.replaceAllMapped(
    _placeholder,
    (m) => (byKey[_normalizeKey(m.group(1))] ?? '').trim(),
  );
  final name = sanitizeFileName(filled);
  return name.isEmpty ? null : name;
}

/// Makes [text] a valid file name: characters no file system allows are replaced or dropped, runs
/// of spaces collapse, and separators left dangling by an empty field are trimmed.
String sanitizeFileName(String text) {
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    final c = String.fromCharCode(rune);
    if (c == '/' || c == '\\' || c == ':') {
      buffer.write('-');
    } else if ('*?"<>|'.contains(c)) {
      continue;
    } else if (rune < 0x20 || (rune >= 0x7f && rune < 0xa0)) {
      buffer.write(' ');
    } else {
      buffer.write(c);
    }
  }

  var name = buffer.toString().replaceAll(_spaces, ' ').trim();
  if (name.length > maxFileNameLength) name = name.substring(0, maxFileNameLength);
  return _trimEnds(name);
}

String _trimEnds(String s) {
  const dangling = ' -_,.;';
  var start = 0;
  var end = s.length;
  while (start < end && dangling.contains(s[start])) {
    start++;
  }
  while (end > start && dangling.contains(s[end - 1])) {
    end--;
  }
  return s.substring(start, end);
}

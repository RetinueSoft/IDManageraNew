/// Strips a layer's "words to remove" out of a value, e.g. "எண்" from "எண் :117 கூளமடை" so the
/// card prints "117 கூளமடை". The backend has the same function (ValueCleaner.cs) and the same
/// tests: the designer and the printed PDF must clean values identically.
///
/// Only WHOLE words are removed - "எண்" is not taken out of "எண்ணிக்கை" - where a word is a run of
/// letters, combining marks (Tamil vowel signs are marks) and digits. Matching ignores case.
///
/// Returns [value] with every occurrence of each word in [words] removed, then tidied: runs of
/// spaces collapse, doubled commas left by a removed word collapse, and separators (: , ; . -)
/// are trimmed from both ends. A value that contains none of the words is returned exactly as
/// it was, punctuation and all.
String removeWordsFrom(String value, List<String> words) {
  if (value.isEmpty || words.isEmpty) return value;

  const wordChar = r'[\p{L}\p{M}\p{N}]';
  var result = value;
  var changed = false;
  for (final raw in words) {
    final word = raw.trim();
    if (word.isEmpty) continue;

    final pattern = RegExp(
      '(?<!$wordChar)${RegExp.escape(word)}(?!$wordChar)',
      caseSensitive: false,
      unicode: true,
    );
    if (!pattern.hasMatch(result)) continue;

    result = result.replaceAll(pattern, '');
    changed = true;
  }
  if (!changed) return value;

  result = result.replaceAll(RegExp(r'\s+'), ' ');
  result = result.replaceAll(RegExp(r',(\s*,)+'), ',');
  return _trimSeparators(result);
}

String _trimSeparators(String text) {
  const separators = ' :,;.-';
  var start = 0;
  var end = text.length;
  while (start < end && separators.contains(text[start])) {
    start++;
  }
  while (end > start && separators.contains(text[end - 1])) {
    end--;
  }
  return text.substring(start, end);
}

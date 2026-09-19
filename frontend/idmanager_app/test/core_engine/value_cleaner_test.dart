import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/templates/domain/value_cleaner.dart';

/// A layer can list words to strip out of its values (e.g. "எண்" from "எண் :117 கூளமடை").
/// The same cases are tested on the backend (ValueCleanerTests.cs): the designer and the
/// printed PDF must clean values identically.
void main() {
  test('removes the word and tidies what is left behind', () {
    // "எண் :117 கூளமடை" -> "117 கூளமடை": the word goes, and so does the ":" it leaves at the start.
    expect(removeWordsFrom('எண் :117 கூளமடை', ['எண்']), '117 கூளமடை');
  });

  test('only whole words are removed', () {
    // "எண்ணிக்கை" starts with "எண்" but is a different word.
    expect(removeWordsFrom('எண்ணிக்கை 3', ['எண்']), 'எண்ணிக்கை 3');
    expect(removeWordsFrom('Palace No Colony', ['No']), 'Palace Colony');
    expect(removeWordsFrom('Number 5', ['No']), 'Number 5');
  });

  test('several words can be removed', () {
    expect(removeWordsFrom('எண் :117 கூளமடை போஸ்ட்', ['எண்', 'போஸ்ட்']), '117 கூளமடை');
  });

  test('every occurrence is removed', () {
    expect(removeWordsFrom('X A X B X', ['X']), 'A B');
  });

  test('Latin words match regardless of case', () {
    expect(removeWordsFrom('NO. 117 Palace', ['no.']), '117 Palace');
  });

  test('a phrase with spaces can be removed', () {
    expect(removeWordsFrom('Door No Colony', ['Door No']), 'Colony');
  });

  test('a removed word between commas does not leave a double comma', () {
    expect(removeWordsFrom('MG Road, X, Pune', ['X']), 'MG Road, Pune');
  });

  test('removing everything leaves an empty value', () {
    expect(removeWordsFrom('எண்', ['எண்']), '');
  });

  test('a value with none of the words is returned untouched, punctuation and all', () {
    for (final value in ['117 கூளமடை.', ' spaced  out ', ': 5 -']) {
      expect(removeWordsFrom(value, ['எண்', 'No']), value);
    }
  });

  test('no words, or blank words, leave the value alone', () {
    expect(removeWordsFrom('எண் 5', []), 'எண் 5');
    expect(removeWordsFrom('எண் 5', ['', '  ']), 'எண் 5');
  });

  test('words with regex characters are taken literally', () {
    expect(removeWordsFrom('A (x) B', ['(x)']), 'A B');
    expect(removeWordsFrom('A B', ['.']), 'A B'); // "." is not a wildcard
  });

  test('words are trimmed', () {
    expect(removeWordsFrom('எண் :117 கூளமடை', ['  எண்  ']), '117 கூளமடை');
  });
}

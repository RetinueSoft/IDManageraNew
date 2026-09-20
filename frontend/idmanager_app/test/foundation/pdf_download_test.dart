import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/foundation/files/pdf_download.dart';

Uint8List bytes(int seed) => Uint8List.fromList([seed, seed, seed]);

String fileName(File f) => f.path.split(Platform.pathSeparator).last;

void main() {
  group('uniqueFileName', () {
    test('keeps the name when it is free', () {
      expect(uniqueFileName('Ravi', 'pdf', (_) => false), 'Ravi.pdf');
    });

    test('adds (1), then (2) ... the way Windows does when the name is taken', () {
      final taken = {'Ravi.pdf'};
      expect(uniqueFileName('Ravi', 'pdf', taken.contains), 'Ravi (1).pdf');
      taken.add('Ravi (1).pdf');
      expect(uniqueFileName('Ravi', 'pdf', taken.contains), 'Ravi (2).pdf');
    });

    test('takes the first free number, even with a gap', () {
      final taken = {'Ravi.pdf', 'Ravi (2).pdf'};
      expect(uniqueFileName('Ravi', 'pdf', taken.contains), 'Ravi (1).pdf');
    });

    test('works without an extension', () {
      expect(uniqueFileName('notes', '', {'notes'}.contains), 'notes (1)');
    });
  });

  group('saveAsNewFile', () {
    late Directory dir;

    setUp(() => dir = Directory.systemTemp.createTempSync('pdf_download_test'));
    tearDown(() => dir.deleteSync(recursive: true));

    List<String> names() => (dir.listSync().map((e) => e.path.split(Platform.pathSeparator).last).toList()..sort());

    test('saves under the name as it is when it is free', () async {
      final file = await saveAsNewFile(dir, 'Ravi Kumar', 'pdf', bytes(1));

      expect(fileName(file), 'Ravi Kumar.pdf');
      expect(file.readAsBytesSync(), bytes(1));
    });

    test('never replaces a file that is already there: the next one is "name (1).pdf"', () async {
      await saveAsNewFile(dir, 'Ravi', 'pdf', bytes(1));

      final second = await saveAsNewFile(dir, 'Ravi', 'pdf', bytes(2));
      final third = await saveAsNewFile(dir, 'Ravi', 'pdf', bytes(3));

      expect(fileName(second), 'Ravi (1).pdf');
      expect(fileName(third), 'Ravi (2).pdf');
      expect(names(), ['Ravi (1).pdf', 'Ravi (2).pdf', 'Ravi.pdf']);
      // The first file still holds what it held.
      expect(File('${dir.path}${Platform.pathSeparator}Ravi.pdf').readAsBytesSync(), bytes(1));
      expect(second.readAsBytesSync(), bytes(2));
      expect(third.readAsBytesSync(), bytes(3));
    });

    test('a file put there by someone else is left alone too', () async {
      final theirs = File('${dir.path}${Platform.pathSeparator}Ravi.pdf')..writeAsBytesSync(bytes(9));

      final saved = await saveAsNewFile(dir, 'Ravi', 'pdf', bytes(1));

      expect(fileName(saved), 'Ravi (1).pdf');
      expect(theirs.readAsBytesSync(), bytes(9));
    });

    test('takes the first free number when there is a gap', () async {
      File('${dir.path}${Platform.pathSeparator}Ravi.pdf').writeAsBytesSync(bytes(9));
      File('${dir.path}${Platform.pathSeparator}Ravi (2).pdf').writeAsBytesSync(bytes(9));

      final saved = await saveAsNewFile(dir, 'Ravi', 'pdf', bytes(1));

      expect(fileName(saved), 'Ravi (1).pdf');
    });

    test('several saves at the same moment each get their own file - nothing is lost', () async {
      final saved = await Future.wait([for (var i = 1; i <= 6; i++) saveAsNewFile(dir, 'Ravi', 'pdf', bytes(i))]);

      expect(saved.map((f) => f.path).toSet(), hasLength(6));
      expect(dir.listSync(), hasLength(6));
      final contents = saved.map((f) => f.readAsBytesSync()[0]).toList()..sort();
      expect(contents, [1, 2, 3, 4, 5, 6]);
    });

    test('a name with characters Windows does not allow is cleaned up', () async {
      final file = await saveAsNewFile(dir, 'a/b:c?d', 'pdf', bytes(1));

      expect(fileName(file), 'a-b-cd.pdf');
    });

    test('an empty name becomes "file"', () async {
      final file = await saveAsNewFile(dir, '  ', 'pdf', bytes(1));

      expect(fileName(file), 'file.pdf');
    });

    test('a Tamil name is kept', () async {
      final file = await saveAsNewFile(dir, 'ரவி குமார் - 117', 'pdf', bytes(1));
      final again = await saveAsNewFile(dir, 'ரவி குமார் - 117', 'pdf', bytes(2));

      expect(fileName(file), 'ரவி குமார் - 117.pdf');
      expect(fileName(again), 'ரவி குமார் - 117 (1).pdf');
    });

    test('a name that already ends in (1) still gets its own number', () async {
      await saveAsNewFile(dir, 'Ravi (1)', 'pdf', bytes(1));

      final again = await saveAsNewFile(dir, 'Ravi (1)', 'pdf', bytes(2));

      expect(fileName(again), 'Ravi (1) (1).pdf');
    });
  });
}

import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../core_engine/templates/domain/file_name_pattern.dart'
    show sanitizeFileName;

/// The name for a new file that does not clash with one that is there, the way Windows does it: the
/// name as it is when it is free, else "name (1).pdf", "name (2).pdf" ... - never replacing a file.
/// [exists] says whether a candidate name (with its extension) is taken.
String uniqueFileName(
  String name,
  String extension,
  bool Function(String candidate) exists,
) {
  final ext = extension.isEmpty ? '' : '.$extension';
  var candidate = '$name$ext';
  for (var n = 1; exists(candidate); n++) {
    candidate = '$name ($n)$ext';
  }
  return candidate;
}

/// Writes [bytes] as a **new** file in [directory], named [name].[extension] - or "name (1).ext",
/// "name (2).ext" ... when that name is taken - and returns it. An existing file is never replaced:
/// the file is created exclusively, so even two saves at the same moment cannot pick the same name.
Future<File> saveAsNewFile(
  Directory directory,
  String name,
  String extension,
  Uint8List bytes,
) async {
  final safeName = sanitizeFileName(name).isEmpty
      ? 'file'
      : sanitizeFileName(name);
  final ext = extension.isEmpty ? '' : '.$extension';
  for (var n = 0; ; n++) {
    final fileName = n == 0 ? '$safeName$ext' : '$safeName ($n)$ext';
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');
    try {
      await file.create(
        exclusive: true,
      ); // fails if the name is taken - then try the next one
    } on PathExistsException {
      continue;
    } on FileSystemException {
      // Some platforms report "already exists" as a plain FileSystemException.
      if (await file.exists()) continue;
      rethrow;
    }
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}

/// Saves a downloaded card PDF the normal way for the platform and returns the name it was saved as.
///
/// On a computer (Windows, Mac, Linux) it goes into the Downloads folder and never replaces a file
/// that is already there: "Ravi.pdf", then "Ravi (1).pdf", "Ravi (2).pdf" ... In a browser the
/// browser does that itself (it downloads "Ravi (1).pdf" when "Ravi.pdf" already exists).
Future<String> savePdfDownload({
  required String name,
  required Uint8List bytes,
}) async {
  final desktop =
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  final downloads = desktop ? await getDownloadsDirectory() : null;
  if (downloads == null) {
    await FileSaver.instance.saveFile(
      name: name,
      bytes: bytes,
      ext: 'pdf',
      mimeType: MimeType.pdf,
    );
    return '$name.pdf';
  }

  final file = await saveAsNewFile(downloads, name, 'pdf', bytes);
  return file.path.split(Platform.pathSeparator).last;
}

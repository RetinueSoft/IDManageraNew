import 'dart:typed_data';

/// A downloaded card PDF and the name to save it as (without '.pdf') - built by the backend
/// from the template's file name pattern (e.g. the member's name).
class DownloadedPdf {
  const DownloadedPdf(this.bytes, this.name);

  final Uint8List bytes;
  final String name;
}

/// The name to save a download as, from the response headers: the backend's X-File-Name (URL
/// encoded; readable everywhere, including a browser) or else Content-Disposition; [fallback]
/// when neither gives one. Any '.pdf' is dropped - the saver adds the extension.
String pdfNameFromHeaders({String? fileNameHeader, String? contentDisposition, String fallback = 'card'}) {
  final name = _decode(fileNameHeader) ?? _fromContentDisposition(contentDisposition);
  final cleaned = (name ?? '').trim().replaceFirst(RegExp(r'\.pdf$', caseSensitive: false), '').trim();
  return cleaned.isEmpty ? fallback : cleaned;
}

String? _decode(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  try {
    return Uri.decodeComponent(value.trim());
  } catch (_) {
    return value.trim();
  }
}

String? _fromContentDisposition(String? header) {
  if (header == null) return null;
  // filename*=UTF-8''%E0%AE... (RFC 5987) is what ASP.NET sends for a non-ASCII name.
  final extended = RegExp(r"filename\*\s*=\s*[^']*'[^']*'([^;]+)", caseSensitive: false).firstMatch(header);
  if (extended != null) return _decode(extended.group(1));
  final plain = RegExp(r'filename\s*=\s*"?([^";]+)"?', caseSensitive: false).firstMatch(header);
  return plain?.group(1);
}

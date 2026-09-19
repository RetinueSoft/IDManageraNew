import 'dart:typed_data';

/// A file picked on-device, ready to upload - name is kept only for the
/// multipart request's filename field.
class UploadedFile {
  const UploadedFile(this.bytes, this.name);

  final Uint8List bytes;
  final String name;
}

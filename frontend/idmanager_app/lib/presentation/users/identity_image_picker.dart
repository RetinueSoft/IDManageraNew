import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core_engine/common/uploaded_file.dart';

/// The most an identity card image may weigh (the backend refuses more).
const maxIdentityImageBytes = 5 * 1024 * 1024;

/// The picture types accepted for an identity card image.
const identityImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];

/// Why [file] cannot be used as an identity card image, or null when it can. Checked on the device
/// so a wrong pick is told about at once, not after saving.
String? identityImageProblem(UploadedFile file) {
  final name = file.name.toLowerCase();
  if (!identityImageExtensions.any((ext) => name.endsWith('.$ext'))) {
    return 'Use a JPG, PNG or WebP picture.';
  }
  if (file.bytes.length > maxIdentityImageBytes)
    return 'The picture is larger than 5 MB.';
  if (file.bytes.isEmpty) return 'That file is empty.';
  return null;
}

Future<UploadedFile?> _pickFromDisk() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
  );
  final file = result?.files.firstOrNull;
  if (file == null || file.bytes == null) return null;
  return UploadedFile(file.bytes!, file.name);
}

/// One side (front or back) of a member's identity card: a preview, a button to choose or replace
/// the picture, and one to remove it. Nothing is required.
class IdentityImagePicker extends StatelessWidget {
  const IdentityImagePicker({
    super.key,
    required this.label,
    required this.bytes,
    required this.onPicked,
    required this.onRemoved,
    this.onRejected,
    this.pickImage = _pickFromDisk,
  });

  /// "Front" / "Back".
  final String label;

  /// The picture now shown, or null when there is none.
  final Uint8List? bytes;

  /// A picture was chosen (already checked with [identityImageProblem]).
  final ValueChanged<UploadedFile> onPicked;
  final VoidCallback onRemoved;

  /// A picture was chosen but cannot be used; says why.
  final ValueChanged<String>? onRejected;

  final Future<UploadedFile?> Function() pickImage;

  Future<void> _choose() async {
    final file = await pickImage();
    if (file == null) return;
    final problem = identityImageProblem(file);
    if (problem != null) {
      onRejected?.call(problem);
      return;
    }
    onPicked(file);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = bytes != null && bytes!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label of the ID card',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        Container(
          width: 220,
          height: 140,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: hasImage
              ? Image.memory(
                  bytes!,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.broken_image_outlined),
                )
              : Text(
                  'No $label picture',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _choose,
              icon: const Icon(Icons.upload_file, size: 18),
              label: Text(hasImage ? 'Replace $label' : 'Choose $label'),
            ),
            if (hasImage)
              TextButton.icon(
                onPressed: onRemoved,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Remove'),
              ),
          ],
        ),
      ],
    );
  }
}

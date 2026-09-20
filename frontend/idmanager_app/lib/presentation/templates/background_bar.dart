import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core_engine/common/uploaded_file.dart';
import '../../core_engine/templates/domain/card_background.dart';

/// The backgrounds of a template as a strip of thumbnails, one tap to switch between them. Used
/// in the template designer (with add / delete) and in the card generator (switch only), so
/// both switch backgrounds the same way.
class BackgroundBar extends StatefulWidget {
  const BackgroundBar({
    super.key,
    required this.backgrounds,
    required this.selectedId,
    required this.onSelect,
    this.onAdd,
    this.onDelete,
  });

  final List<CardBackground> backgrounds;
  final int selectedId;
  final ValueChanged<int> onSelect;

  /// Designer only: the "Add background" button.
  final VoidCallback? onAdd;

  /// Designer only: the remove button on every background except the template's own.
  final ValueChanged<CardBackground>? onDelete;

  @override
  State<BackgroundBar> createState() => _BackgroundBarState();
}

class _BackgroundBarState extends State<BackgroundBar> {
  // Thumbnails are decoded once per image, not on every rebuild of the screen.
  final Map<int, (String, Uint8List)> _thumbs = {};

  Uint8List _thumbFor(CardBackground b) {
    final cached = _thumbs[b.id];
    if (cached != null && identical(cached.$1, b.frontImageBase64))
      return cached.$2;
    final bytes = b.frontImageBase64.isEmpty
        ? Uint8List(0)
        : base64Decode(b.frontImageBase64);
    _thumbs[b.id] = (b.frontImageBase64, bytes);
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Text('Background', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: 12),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final b in widget.backgrounds)
                  Padding(
                    padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
                    child: _BackgroundChip(
                      background: b,
                      thumbnail: _thumbFor(b),
                      selected: b.id == widget.selectedId,
                      scheme: scheme,
                      onTap: () => widget.onSelect(b.id),
                      onDelete: widget.onDelete == null || b.isDefault
                          ? null
                          : () => widget.onDelete!(b),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.onAdd != null)
            TextButton.icon(
              onPressed: widget.onAdd,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: const Text('Add background'),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _BackgroundChip extends StatelessWidget {
  const _BackgroundChip({
    required this.background,
    required this.thumbnail,
    required this.selected,
    required this.scheme,
    required this.onTap,
    required this.onDelete,
  });

  final CardBackground background;
  final Uint8List thumbnail;
  final bool selected;
  final ColorScheme scheme;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? scheme.secondaryContainer : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        key: ValueKey('background-${background.id}'),
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  width: 48,
                  height: 30,
                  child: thumbnail.isEmpty
                      ? ColoredBox(color: scheme.surfaceContainerHighest)
                      : Image.memory(
                          thumbnail,
                          fit: BoxFit.cover,
                          cacheWidth: 96,
                          gaplessPlayback: true,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Text(background.name, overflow: TextOverflow.ellipsis),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: onDelete,
                  child: Tooltip(
                    message: 'Remove background ${background.name}',
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(Icons.close, size: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// What the "Add background" dialog collects.
class NewBackground {
  const NewBackground({
    required this.name,
    required this.front,
    required this.back,
  });

  final String name;
  final UploadedFile front;
  final UploadedFile back;
}

Future<UploadedFile?> _pickImage() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
  );
  final file = result?.files.firstOrNull;
  if (file == null || file.bytes == null) return null;
  return UploadedFile(file.bytes!, file.name);
}

/// Asks for a name and the front and back images of a new background; null when cancelled.
Future<NewBackground?> showAddBackgroundDialog(
  BuildContext context, {
  Future<UploadedFile?> Function() pickImage = _pickImage,
}) => showDialog<NewBackground>(
  context: context,
  builder: (_) => AddBackgroundDialog(pickImage: pickImage),
);

class AddBackgroundDialog extends StatefulWidget {
  const AddBackgroundDialog({super.key, this.pickImage = _pickImage});

  final Future<UploadedFile?> Function() pickImage;

  @override
  State<AddBackgroundDialog> createState() => _AddBackgroundDialogState();
}

class _AddBackgroundDialogState extends State<AddBackgroundDialog> {
  final _name = TextEditingController();
  UploadedFile? _front;
  UploadedFile? _back;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _complete =>
      _name.text.trim().isNotEmpty && _front != null && _back != null;

  Future<void> _pick(bool front) async {
    final file = await widget.pickImage();
    if (file == null || !mounted) return;
    setState(() => front ? _front = file : _back = file);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add background'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Name (e.g. Blue, Festival)',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _pick(true),
              icon: const Icon(Icons.image_outlined),
              label: Text(
                _front?.name ?? 'Choose front image',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _pick(false),
              icon: const Icon(Icons.image_outlined),
              label: Text(
                _back?.name ?? 'Choose back image',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _complete
              ? () => Navigator.pop(
                  context,
                  NewBackground(
                    name: _name.text.trim(),
                    front: _front!,
                    back: _back!,
                  ),
                )
              : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../core_engine/common/enums.dart';
import '../../core_engine/templates/domain/field_group.dart';
import '../../core_engine/templates/domain/file_name_pattern.dart';

/// Asks what a downloaded card PDF of this template should be called: the member's PDF fields
/// become part of the name, e.g. "{Name} - {Card No}" gives "Ravi Kumar - 1234567890.pdf".
/// Returns the pattern (blank for the default card name), or null when cancelled.
Future<String?> showFileNameDialog(
  BuildContext context, {
  required String? pattern,
  required List<ExtractedField> fields,
}) => showDialog<String>(
  context: context,
  builder: (_) => FileNameDialog(pattern: pattern, fields: fields),
);

class FileNameDialog extends StatefulWidget {
  const FileNameDialog({super.key, required this.pattern, required this.fields});

  final String? pattern;

  /// The template's sample PDF fields - what can go into the name, with their sample values.
  final List<ExtractedField> fields;

  @override
  State<FileNameDialog> createState() => _FileNameDialogState();
}

class _FileNameDialogState extends State<FileNameDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.pattern ?? '');

  List<ExtractedField> get _textFields => [
    for (final f in widget.fields)
      if (f.type == LayerFieldType.text && (f.key ?? '').trim().isNotEmpty) f,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Puts {Field} where the cursor is (or at the end).
  void _insert(String key) {
    final text = _controller.text;
    final selection = _controller.selection;
    final at = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final inserted = '{$key}';
    _controller.value = TextEditingValue(
      text: text.replaceRange(at, end, inserted),
      selection: TextSelection.collapsed(offset: at + inserted.length),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pattern = _controller.text;
    final example = previewFileName(pattern, widget.fields);
    final knownKeys = {for (final f in _textFields) f.key!.trim().toLowerCase()};
    final unknown = [
      for (final k in fieldsInFileNamePattern(pattern))
        if (!knownKeys.contains(k.toLowerCase())) k,
    ];

    return AlertDialog(
      title: const Text('Downloaded PDF name'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Name the downloaded card after the member: click fields to add them.'),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'File name',
                hintText: '{Name} - {Card No}',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            if (_textFields.isEmpty)
              Text(
                'Import the template\'s sample PDF to pick fields from it. You can also type {Field name}.',
                style: theme.textTheme.bodySmall,
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final f in _textFields)
                    ActionChip(
                      label: Text(f.key!.trim()),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _insert(f.key!.trim()),
                    ),
                ],
              ),
            const SizedBox(height: 12),
            Text(
              pattern.trim().isEmpty
                  ? 'Blank: the file is called card-<number>.pdf'
                  : example == null
                  ? 'The sample PDF gives no name - the file falls back to card-<number>.pdf'
                  : 'Example from the sample PDF: $example.pdf',
              style: theme.textTheme.bodyMedium,
            ),
            if (unknown.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Not a field of the sample PDF: ${unknown.join(', ')}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, _controller.text.trim()), child: const Text('OK')),
      ],
    );
  }
}

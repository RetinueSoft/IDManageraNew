import 'package:flutter/material.dart';

import '../../core_engine/templates/domain/date_formatter.dart';

/// The date format for a layer: a value in the layer that is a date (e.g. "01-Jan-1968") is
/// printed in this format ("01/01/1968" for dd/MM/yyyy). Type a format or pick a preset; blank
/// leaves dates as they are. Shows what the format looks like.
class DateFormatEditor extends StatefulWidget {
  const DateFormatEditor({
    super.key,
    required this.format,
    required this.onChanged,
  });

  final String? format;

  /// Called with the new format, or null when it was cleared.
  final ValueChanged<String?> onChanged;

  static const presets = [
    'dd/MM/yyyy',
    'dd-MM-yyyy',
    'dd.MM.yyyy',
    'dd-MMM-yyyy',
    'dd MMMM yyyy',
    'MM/dd/yyyy',
    'yyyy-MM-dd',
  ];

  @override
  State<DateFormatEditor> createState() => _DateFormatEditorState();
}

class _DateFormatEditorState extends State<DateFormatEditor> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.format ?? '',
  );

  @override
  void didUpdateWidget(DateFormatEditor old) {
    super.didUpdateWidget(old);
    // Another layer was selected (or a preset was chosen): show its format.
    if ((widget.format ?? '') != _controller.text.trim()) {
      _controller.text = widget.format ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _set(String text) {
    final format = text.trim();
    widget.onChanged(format.isEmpty ? null : format);
  }

  @override
  Widget build(BuildContext context) {
    final example = exampleForFormat(_controller.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date format', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Format for date values (e.g. dd/MM/yyyy)',
                  helperText: example == null
                      ? 'Blank keeps dates as they are'
                      : 'Prints as $example',
                  isDense: true,
                ),
                onChanged: (text) {
                  setState(() {});
                  _set(text);
                },
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Common formats',
              icon: const Icon(Icons.arrow_drop_down),
              onSelected: (format) {
                _controller.text = format;
                setState(() {});
                _set(format);
              },
              itemBuilder: (_) => [
                for (final f in DateFormatEditor.presets)
                  PopupMenuItem(
                    value: f,
                    child: Text('$f   (${exampleForFormat(f)})'),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

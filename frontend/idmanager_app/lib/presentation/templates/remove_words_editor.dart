import 'package:flutter/material.dart';

/// The words to strip out of every field's value in this layer - e.g. "எண்" from the address
/// value "எண் :117 கூளமடை" so the card prints "117 கூளமடை". One list per layer, any number of
/// words; each shows as a chip that can be removed. Whole words only, and never from keys.
class RemoveWordsEditor extends StatefulWidget {
  const RemoveWordsEditor({
    super.key,
    required this.words,
    required this.onChanged,
  });

  final List<String> words;
  final ValueChanged<List<String>> onChanged;

  @override
  State<RemoveWordsEditor> createState() => RemoveWordsEditorState();
}

class RemoveWordsEditorState extends State<RemoveWordsEditor> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final word = _controller.text.trim();
    if (word.isEmpty) return;
    if (!widget.words.contains(word)) {
      widget.onChanged([...widget.words, word]);
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Words to remove from values',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Add a word to remove',
                  helperText: 'Whole words only; never removed from keys',
                  isDense: true,
                ),
                onSubmitted: (_) => _add(),
              ),
            ),
            IconButton(
              tooltip: 'Add word',
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _add,
            ),
          ],
        ),
        if (widget.words.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final word in widget.words)
                InputChip(
                  label: Text(word),
                  visualDensity: VisualDensity.compact,
                  onDeleted: () => widget.onChanged([
                    for (final w in widget.words)
                      if (w != word) w,
                  ]),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

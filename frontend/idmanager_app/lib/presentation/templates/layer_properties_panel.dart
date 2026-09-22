import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core_engine/common/enums.dart';
import '../../core_engine/templates/domain/field_group.dart';
import '../../core_engine/templates/domain/layer_text.dart';
import '../../core_engine/templates/domain/template_layer.dart';
import 'date_format_editor.dart';
import 'remove_words_editor.dart';

class LayerPropertiesPanel extends StatefulWidget {
  const LayerPropertiesPanel({
    super.key,
    required this.designer,
    required this.group,
    required this.sampleFields,
    required this.otherLayers,
    required this.onMergeLayer,
    required this.onChanged,
    required this.onDelete,
  });

  /// The template designer. Without it (editing one generated card) the layer name and field
  /// keys are not editable and nothing that changes the template's structure is offered: no
  /// keys, adding/removing fields, combining, words to remove or date format.
  final bool designer;
  final LayerGroup group;
  final List<ExtractedField> sampleFields;
  final List<LayerGroup> otherLayers;
  final void Function(String otherId) onMergeLayer;
  final void Function(LayerGroup Function(LayerGroup current) update) onChanged;
  final VoidCallback onDelete;

  @override
  State<LayerPropertiesPanel> createState() => _LayerPropertiesPanelState();
}

class _LayerPropertiesPanelState extends State<LayerPropertiesPanel> {
  late TextEditingController _nameCtrl;
  late TextEditingController _keyCtrl;
  late TextEditingController _valueCtrl;

  @override
  void initState() {
    super.initState();
    final source = widget.group.sources.isNotEmpty
        ? widget.group.sources.first
        : null;
    _nameCtrl = TextEditingController(text: widget.group.name);
    _keyCtrl = TextEditingController(text: source?.key ?? '');
    _valueCtrl = TextEditingController(text: source?.value ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _keyCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  LayerSourceItem _firstSourceOrDefault(LayerGroup g) => g.sources.isNotEmpty
      ? g.sources.first
      : LayerSourceItem(type: g.fieldType);

  void _updateFirstSource(LayerSourceItem Function(LayerSourceItem) update) {
    widget.onChanged((g) {
      final source = update(_firstSourceOrDefault(g));
      return g.copyWith(sources: [source, ...g.sources.skip(1)]);
    });
  }

  /// A toggle in the grid. In the designer it is pushed down to line up with the text boxes of
  /// the editors beside it (which have a title above their box).
  Widget _toggleSlot(Widget toggle) =>
      widget.designer ? _alignedToInputs(toggle) : toggle;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    // A Material (not a colored Container) so the switch tiles' ink shows.
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Layer properties',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (widget.designer)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: widget.onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Common settings first: the name (twice as wide as a number box) and the numbers in
            // one row, then the toggles.
            _CollapsibleSection(
              title: 'General properties',
              child: _ResponsiveGrid(
                columns: 8,
                minColumnWidth: 100,
                children: [
                  _GridSpan(
                    span: 2,
                    child: TextField(
                      controller: _nameCtrl,
                      enabled: widget.designer,
                      decoration: const InputDecoration(
                        labelText: 'Layer name',
                      ),
                      onChanged: (v) =>
                          widget.onChanged((g) => g.copyWith(name: v)),
                    ),
                  ),
                  if (group.fieldType == LayerFieldType.text) ...[
                    _NumberField(
                      label: 'Font (pt)',
                      step: 1,
                      value: group.fontSizePt,
                      onChanged: (v) =>
                          widget.onChanged((g) => g.copyWith(fontSizePt: v)),
                    ),
                    _NumberField(
                      label: 'Wrap width (mm)',
                      value: group.widthMm ?? 30,
                      onChanged: (v) =>
                          widget.onChanged((g) => g.copyWith(widthMm: v)),
                    ),
                    _NumberField(
                      label: 'Key width (mm)',
                      value: group.keyWidthMm,
                      onChanged: (v) =>
                          widget.onChanged((g) => g.copyWith(keyWidthMm: v)),
                      onCleared: () =>
                          widget.onChanged((g) => g.copyWith(keyWidthMm: null)),
                    ),
                    if (group.isList)
                      _NumberField(
                        label: 'Line gap (mm)',
                        value: group.lineGapMm,
                        onChanged: (v) =>
                            widget.onChanged((g) => g.copyWith(lineGapMm: v)),
                      ),
                  ] else ...[
                    _NumberField(
                      label: 'Width (mm)',
                      value: group.widthMm ?? 20,
                      onChanged: (v) =>
                          widget.onChanged((g) => g.copyWith(widthMm: v)),
                    ),
                    _NumberField(
                      label: 'Height (mm)',
                      value: group.heightMm ?? 20,
                      onChanged: (v) =>
                          widget.onChanged((g) => g.copyWith(heightMm: v)),
                    ),
                  ],
                  _NumberField(
                    label: 'X (mm)',
                    value: group.xMm,
                    onChanged: (v) =>
                        widget.onChanged((g) => g.copyWith(xMm: v)),
                  ),
                  _NumberField(
                    label: 'Y (mm)',
                    value: group.yMm,
                    onChanged: (v) =>
                        widget.onChanged((g) => g.copyWith(yMm: v)),
                  ),
                  if (group.fieldType == LayerFieldType.text) ...[
                    if (widget.designer)
                      _GridSpan(
                        span: 2,
                        child: _alignedToInputs(
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Combine several fields'),
                            value: group.isList,
                            onChanged: (v) =>
                                widget.onChanged((g) => g.copyWith(isList: v)),
                          ),
                        ),
                      ),
                    _toggleSlot(
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Bold (B)'),
                        value: group.bold,
                        onChanged: (v) =>
                            widget.onChanged((g) => g.copyWith(bold: v)),
                      ),
                    ),
                    if (group.isList)
                      _toggleSlot(
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('List (L)'),
                          value: group.bulletList,
                          onChanged: (v) => widget.onChanged(
                            (g) => g.copyWith(bulletList: v),
                          ),
                        ),
                      ),
                    if (widget.designer)
                      _GridSpan(
                        span: 2,
                        child: RemoveWordsEditor(
                          words: group.removeWords,
                          onChanged: (words) => widget.onChanged(
                            (g) => g.copyWith(removeWords: words),
                          ),
                        ),
                      ),
                    if (widget.designer)
                      _GridSpan(
                        span: 2,
                        child: DateFormatEditor(
                          key: ValueKey('date-format-${group.id}'),
                          format: group.dateFormat,
                          onChanged: (format) => widget.onChanged(
                            (g) => g.copyWith(dateFormat: format),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            if (group.fieldType == LayerFieldType.text) ...[
              const SizedBox(height: 12),
              _CollapsibleSection(
                title: 'Fields',
                child: group.isList
                    ? CombinedFieldsEditor(
                        designer: widget.designer,
                        group: group,
                        sampleFields: widget.sampleFields,
                        otherLayers: widget.otherLayers,
                        onMergeLayer: widget.onMergeLayer,
                        onChanged: widget.onChanged,
                      )
                    : _ResponsiveGrid(
                        children: [
                          if (widget.designer)
                            TextField(
                              controller: _keyCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Key (label before the value)',
                              ),
                              onChanged: (v) =>
                                  _updateFirstSource((s) => s.copyWith(key: v)),
                            ),
                          if (widget.designer)
                            PdfFieldPicker(
                              value: _firstSourceOrDefault(group).sourceKey,
                              fields: widget.sampleFields,
                              isFixedText:
                                  (_firstSourceOrDefault(group).key ?? '')
                                      .trim()
                                      .isEmpty &&
                                  (_firstSourceOrDefault(group).sourceKey ?? '')
                                      .isEmpty,
                              onChanged: (v) => _updateFirstSource(
                                (s) => s.copyWith(sourceKey: v),
                              ),
                            ),
                          TextField(
                            controller: _valueCtrl,
                            decoration: InputDecoration(
                              labelText: widget.designer
                                  ? 'Sample value'
                                  : 'Value',
                            ),
                            onChanged: (v) =>
                                _updateFirstSource((s) => s.copyWith(value: v)),
                          ),
                        ],
                      ),
              ),
            ] else if (group.isQr && widget.designer)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Empty QR code image. The image itself is chosen in the card generator; '
                  'it is stretched to the width and height above.',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A titled part of the properties panel with a button to fold it away. The content stays
/// mounted while folded, so nothing typed inside it is lost.
class _CollapsibleSection extends StatefulWidget {
  const _CollapsibleSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _collapsed = !_collapsed),
          child: Row(
            children: [
              IconButton(
                tooltip: _collapsed
                    ? 'Expand ${widget.title}'
                    : 'Collapse ${widget.title}',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  _collapsed ? Icons.chevron_right : Icons.expand_more,
                ),
                onPressed: () => setState(() => _collapsed = !_collapsed),
              ),
              Text(widget.title, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
        Offstage(offstage: _collapsed, child: widget.child),
      ],
    );
  }
}

/// Marks a child of [_ResponsiveGrid] that is [span] columns wide.
class _GridSpan extends StatelessWidget {
  const _GridSpan({required this.span, required this.child});

  final int span;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Lays its children out in rows of up to [columns], each the same width; on a narrow panel
/// there are fewer columns so a field never gets squeezed below [minColumnWidth].
class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({
    required this.children,
    this.columns = 4,
    this.minColumnWidth = 170,
  });

  final List<Widget> children;
  final int columns;
  final double minColumnWidth;

  static const spacing = 12.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        var count = columns;
        while (count > 1 &&
            (available - spacing * (count - 1)) / count < minColumnWidth) {
          count--;
        }
        final width = (available - spacing * (count - 1)) / count;
        return Wrap(
          spacing: spacing,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            for (final c in children)
              SizedBox(
                width: c is _GridSpan
                    ? width * (c.span < count ? c.span : count) +
                          spacing * ((c.span < count ? c.span : count) - 1)
                    : width,
                child: c is _GridSpan ? c.child : c,
              ),
          ],
        );
      },
    );
  }
}

/// A toggle sitting in the grid beside editors that have a title above their text box: pushed
/// down so it lines up with those text boxes rather than with their titles.
Widget _alignedToInputs(Widget toggle) =>
    Padding(padding: const EdgeInsets.only(top: 26), child: toggle);

/// A numeric input with up/down buttons (and mouse-wheel support). Applies every
/// change immediately - typing, the buttons, or the wheel - so the canvas updates
/// live.
class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.onCleared,
    this.step = 0.5,
  });

  final String label;
  final double? value;
  final ValueChanged<double> onChanged;

  /// When set, the field is optional: clearing the text calls this (value = null).
  final VoidCallback? onCleared;
  final double step;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _ctrl = TextEditingController(
    text: _format(widget.value),
  );

  static String _format(double? v) => v == null ? '' : v.toStringAsFixed(1);

  @override
  void didUpdateWidget(_NumberField old) {
    super.didUpdateWidget(old);
    // Sync when the value changed from outside (e.g. dragging the layer on the
    // canvas) but never fight what's being typed.
    final typed = double.tryParse(_ctrl.text);
    final external = widget.value;
    if (external == null) {
      if (typed != null && _ctrl.text.isNotEmpty && widget.onCleared != null)
        return;
      if (_ctrl.text.isNotEmpty) _ctrl.text = '';
    } else if (typed == null || (typed - external).abs() > 0.05) {
      _ctrl.text = _format(external);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _nudge(int direction) {
    final base = double.tryParse(_ctrl.text) ?? widget.value ?? 0;
    final next = (base + direction * widget.step)
        .clamp(0, double.infinity)
        .toDouble();
    _ctrl.text = _format(next);
    widget.onChanged(double.parse(_format(next)));
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent && FocusScope.of(context).hasFocus) {
          _nudge(event.scrollDelta.dy < 0 ? 1 : -1);
        }
      },
      child: TextField(
        controller: _ctrl,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: SizedBox(
            width: 32,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SpinButton(
                  icon: Icons.keyboard_arrow_up,
                  onTap: () => _nudge(1),
                ),
                _SpinButton(
                  icon: Icons.keyboard_arrow_down,
                  onTap: () => _nudge(-1),
                ),
              ],
            ),
          ),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (v) {
          if (v.trim().isEmpty && widget.onCleared != null) {
            widget.onCleared!();
            return;
          }
          final parsed = double.tryParse(v);
          if (parsed != null && parsed >= 0) widget.onChanged(parsed);
        },
      ),
    );
  }
}

class _SpinButton extends StatelessWidget {
  const _SpinButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: SizedBox(height: 18, width: 32, child: Icon(icon, size: 18)),
  );
}

/// Edits a combined (List) layer: the separator that joins its fields, and the
/// fields themselves. Each field has a key (used to match the member's PDF, and
/// printed before the value unless empty) and a value, which is always printed, plus
/// its own separator to the next field.
/// Fields can be added blank, from the sample PDF, or by merging in a layer already
/// on the canvas, and reordered with the up/down buttons on each row.
class CombinedFieldsEditor extends StatefulWidget {
  const CombinedFieldsEditor({
    super.key,
    required this.designer,
    required this.group,
    required this.sampleFields,
    required this.otherLayers,
    required this.onMergeLayer,
    required this.onChanged,
  });

  /// Only the designer may add, remove or reorder fields, edit keys or pick the PDF field; on
  /// a generated card just the values (and how they join) can change.
  final bool designer;
  final LayerGroup group;
  final List<ExtractedField> sampleFields;
  final List<LayerGroup> otherLayers;
  final void Function(String otherId) onMergeLayer;
  final void Function(LayerGroup Function(LayerGroup current) update) onChanged;

  @override
  State<CombinedFieldsEditor> createState() => _CombinedFieldsEditorState();
}

class _CombinedFieldsEditorState extends State<CombinedFieldsEditor> {
  /// Bumped on every reorder so the two moved rows remount with their new content; typing
  /// never touches this, so the field being typed into keeps its focus.
  int _moveVersion = 0;

  void _addSource(LayerSourceItem item) =>
      widget.onChanged((g) => g.copyWith(sources: [...g.sources, item]));

  void _updateAt(int index, LayerSourceItem Function(LayerSourceItem) update) =>
      widget.onChanged(
        (g) => g.copyWith(
          sources: [
            for (var i = 0; i < g.sources.length; i++)
              if (i == index) update(g.sources[i]) else g.sources[i],
          ],
        ),
      );

  void _removeAt(int index) => widget.onChanged(
    (g) => g.copyWith(
      sources: [
        for (var i = 0; i < g.sources.length; i++)
          if (i != index) g.sources[i],
      ],
    ),
  );

  void _swap(int a, int b) {
    widget.onChanged((g) {
      final sources = [...g.sources];
      final moved = sources.removeAt(a);
      sources.insert(b, moved);
      return g.copyWith(sources: sources);
    });
    setState(() => _moveVersion++);
  }

  void _onAddSelected(Object choice) {
    if (choice is ExtractedField) {
      _addSource(LayerSourceItem(key: choice.key, value: choice.value));
    } else if (choice is LayerGroup) {
      widget.onMergeLayer(choice.id);
    } else if (choice == 'emptyline') {
      _addSource(const LayerSourceItem(emptyLine: true));
    } else {
      _addSource(const LayerSourceItem(key: '', value: ''));
    }
  }

  String _layerLabel(LayerGroup g) {
    final source = g.sources.isNotEmpty ? g.sources.first : null;
    return '${g.name}: ${source?.key ?? ''} = ${source?.value ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final designer = widget.designer;
    final textFields = [
      for (final f in widget.sampleFields)
        if (f.type == LayerFieldType.text) f,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                '${group.sources.length} in this group',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (designer)
              PopupMenuButton<Object>(
                tooltip: 'Add a field to this group',
                onSelected: _onAddSelected,
                itemBuilder: (_) => [
                  const PopupMenuItem<Object>(
                    value: 'blank',
                    child: Text('Blank field (type key and value)'),
                  ),
                  const PopupMenuItem<Object>(
                    value: 'emptyline',
                    child: Text('Empty line'),
                  ),
                  if (textFields.isNotEmpty) ...[
                    const PopupMenuDivider(),
                    const PopupMenuItem<Object>(
                      enabled: false,
                      child: Text('From the sample PDF'),
                    ),
                    for (final f in textFields)
                      PopupMenuItem<Object>(
                        value: f,
                        child: Text(
                          '${f.key ?? ''}: ${f.value ?? ''}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  if (widget.otherLayers.isNotEmpty) ...[
                    const PopupMenuDivider(),
                    const PopupMenuItem<Object>(
                      enabled: false,
                      child: Text('Merge an existing layer'),
                    ),
                    for (final l in widget.otherLayers)
                      PopupMenuItem<Object>(
                        value: l,
                        child: Text(
                          _layerLabel(l),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ],
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline, size: 18),
                      SizedBox(width: 4),
                      Text('Add field'),
                    ],
                  ),
                ),
              ),
          ],
        ),
        // Each field is one row of four columns: key, value, read from, join with.
        for (var i = 0; i < group.sources.length; i++)
          Padding(
            // Keyed on the field count and the move counter so rows rebuild (with the right
            // text) after an add/remove/reorder, but keep focus while just typing.
            key: ValueKey('${group.sources.length}-$_moveVersion-$i'),
            padding: const EdgeInsets.only(bottom: 8),
            child: group.sources[i].emptyLine
                ? Row(
                    children: [
                      const Icon(Icons.space_bar, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Empty line')),
                      if (designer) ...[
                        _ReorderButtons(
                          canMoveUp: i > 0,
                          canMoveDown: i < group.sources.length - 1,
                          onMoveUp: () => _swap(i, i - 1),
                          onMoveDown: () => _swap(i, i + 1),
                        ),
                        IconButton(
                          tooltip: 'Remove empty line',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _removeAt(i),
                        ),
                      ],
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ResponsiveGrid(
                          children: [
                            if (designer)
                              TextFormField(
                                initialValue: group.sources[i].key ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Key (label)',
                                  isDense: true,
                                ),
                                onChanged: (v) =>
                                    _updateAt(i, (s) => s.copyWith(key: v)),
                              ),
                            TextFormField(
                              initialValue: group.sources[i].value ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Value',
                                isDense: true,
                              ),
                              onChanged: (v) =>
                                  _updateAt(i, (s) => s.copyWith(value: v)),
                            ),
                            if (designer)
                              PdfFieldPicker(
                                value: group.sources[i].sourceKey,
                                fields: widget.sampleFields,
                                isFixedText:
                                    (group.sources[i].key ?? '')
                                        .trim()
                                        .isEmpty &&
                                    (group.sources[i].sourceKey ?? '').isEmpty,
                                onChanged: (v) => _updateAt(
                                  i,
                                  (s) => s.copyWith(sourceKey: v),
                                ),
                              ),
                            if (designer && i < group.sources.length - 1)
                              DropdownButtonFormField<String>(
                                initialValue:
                                    (JoinSeparator.tryFromWireName(
                                              group.sources[i].separator,
                                            ) ??
                                            JoinSeparator.comma)
                                        .wireName,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Join with next field',
                                  isDense: true,
                                ),
                                items: [
                                  for (final s in JoinSeparator.values)
                                    DropdownMenuItem<String>(
                                      value: s.wireName,
                                      child: Text(s.label),
                                    ),
                                ],
                                onChanged: (v) {
                                  if (v != null) {
                                    _updateAt(
                                      i,
                                      (s) => s.copyWith(separator: v),
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                      if (designer) ...[
                        _ReorderButtons(
                          canMoveUp: i > 0,
                          canMoveDown: i < group.sources.length - 1,
                          onMoveUp: () => _swap(i, i - 1),
                          onMoveDown: () => _swap(i, i + 1),
                        ),
                        IconButton(
                          tooltip: 'Remove field',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _removeAt(i),
                        ),
                      ],
                    ],
                  ),
          ),
      ],
    );
  }
}

/// Which field of the member's PDF a layer field reads its value from. By default the key
/// itself is looked up; choosing another field lets the key stay empty (value only on the
/// card) or read differently, without breaking the link to the PDF. A field with neither a
/// key nor a PDF field is fixed text and always prints what is typed.
///
/// A combo box, not a plain dropdown: the sample PDF's fields are offered as suggestions, but
/// typing a name of its own is just as valid - the field a template needs is not always one
/// the sample happened to have.
class PdfFieldPicker extends StatelessWidget {
  const PdfFieldPicker({
    super.key,
    required this.value,
    required this.fields,
    required this.isFixedText,
    required this.onChanged,
  });

  final String? value;
  final List<ExtractedField> fields;
  final bool isFixedText;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final keys = <String>{
      for (final f in fields)
        if (f.type == LayerFieldType.text && (f.key ?? '').trim().isNotEmpty)
          f.key!.trim(),
    }.toList();

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: value ?? ''),
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        return query.isEmpty
            ? keys
            : keys.where((k) => k.toLowerCase().contains(query));
      },
      onSelected: (selection) =>
          onChanged(selection.trim().isEmpty ? null : selection),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Read from PDF field',
            isDense: true,
            hintText: 'Same as key',
            helperText: isFixedText ? 'Fixed text: not read from the PDF' : null,
          ),
          onChanged: (v) => onChanged(v.trim().isEmpty ? null : v),
        );
      },
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 320),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final option in options)
                  ListTile(
                    dense: true,
                    title: Text(option, overflow: TextOverflow.ellipsis),
                    onTap: () => onSelected(option),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Up/down arrows to move a field within its group. Disabled (greyed) at either end.
class _ReorderButtons extends StatelessWidget {
  const _ReorderButtons({
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  static const _constraints = BoxConstraints(minWidth: 28, minHeight: 22);

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: 'Move up',
        icon: const Icon(Icons.keyboard_arrow_up, size: 18),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: _constraints,
        onPressed: canMoveUp ? onMoveUp : null,
      ),
      IconButton(
        tooltip: 'Move down',
        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: _constraints,
        onPressed: canMoveDown ? onMoveDown : null,
      ),
    ],
  );
}

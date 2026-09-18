import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../../core/models/layer.dart';
import '../../core/models/template.dart';
import '../../core/state/providers.dart';

/// The core editor: a background card image with zoom (InteractiveViewer) and
/// draggable text/image layers positioned in millimeters. Screen zoom is purely a
/// view transform - layer geometry (xMm/yMm/widthMm/heightMm/fontSizePt) never
/// changes with zoom, so the same numbers drive an exact-size PDF print on the
/// backend (see PdfGenerationService).
class TemplateEditorScreen extends ConsumerStatefulWidget {
  final TemplateDetail template;
  const TemplateEditorScreen({super.key, required this.template});

  @override
  ConsumerState<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
  // Base render resolution before the InteractiveViewer's own zoom is applied.
  static const double pxPerMm = 4.0;
  static const double ptToMm = 25.4 / 72;

  late List<TemplateLayer> _layers;
  CardSide _side = CardSide.front;
  LayerGroup? _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _layers = widget.template.layers.isNotEmpty
        ? widget.template.layers
        : [TemplateLayer(side: CardSide.front), TemplateLayer(side: CardSide.back)];
    if (_layers.every((l) => l.side != CardSide.front)) {
      _layers.add(TemplateLayer(side: CardSide.front));
    }
    if (_layers.every((l) => l.side != CardSide.back)) {
      _layers.add(TemplateLayer(side: CardSide.back));
    }
  }

  TemplateLayer get _currentLayer => _layers.firstWhere((l) => l.side == _side);

  Uint8List _decodeImage(String base64Str) =>
      base64Str.isEmpty ? Uint8List(0) : base64Decode(base64Str);

  void _addGroup(LayerFieldType type) {
    setState(() {
      final group = LayerGroup(
        name: type == LayerFieldType.text ? 'New Text' : 'New Image',
        fieldType: type,
        xMm: widget.template.cardWidthMm / 2 - 10,
        yMm: widget.template.cardHeightMm / 2 - 5,
        widthMm: type == LayerFieldType.image ? 20 : 30,
        heightMm: type == LayerFieldType.image ? 20 : null,
        sources: [
          LayerSourceItem(
            key: type == LayerFieldType.text ? 'Label' : null,
            value: type == LayerFieldType.text ? 'Sample' : null,
            type: type,
          ),
        ],
      );
      _currentLayer.groups.add(group);
      _selected = group;
    });
  }

  void _deleteSelected() {
    if (_selected == null) return;
    setState(() {
      _currentLayer.groups.remove(_selected);
      _selected = null;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(templateApiProvider).saveLayers(widget.template.id, _layers);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Layout saved.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidthPx = widget.template.cardWidthMm * pxPerMm;
    final cardHeightPx = widget.template.cardHeightMm * pxPerMm;
    final imageBytes = _decodeImage(
      _side == CardSide.front ? widget.template.frontImageBase64 : widget.template.backImageBase64,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Design: ${widget.template.name}'),
        actions: [
          IconButton(
            tooltip: 'Add text layer',
            icon: const Icon(Icons.text_fields),
            onPressed: () => _addGroup(LayerFieldType.text),
          ),
          IconButton(
            tooltip: 'Add image layer',
            icon: const Icon(Icons.image_outlined),
            onPressed: () => _addGroup(LayerFieldType.image),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SegmentedButton<CardSide>(
                    segments: const [
                      ButtonSegment(value: CardSide.front, label: Text('Front')),
                      ButtonSegment(value: CardSide.back, label: Text('Back')),
                    ],
                    selected: {_side},
                    onSelectionChanged: (s) => setState(() {
                      _side = s.first;
                      _selected = null;
                    }),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey.shade300,
                    child: InteractiveViewer(
                      minScale: 0.3,
                      maxScale: 6,
                      constrained: false,
                      boundaryMargin: const EdgeInsets.all(200),
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = null),
                        child: Container(
                          width: cardWidthPx,
                          height: cardHeightPx,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              if (imageBytes.isNotEmpty)
                                Positioned.fill(
                                  child: Image.memory(imageBytes, fit: BoxFit.fill),
                                ),
                              for (final group in _currentLayer.groups)
                                _buildLayerWidget(group, cardWidthPx, cardHeightPx),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 300,
            child: _selected == null
                ? const Center(child: Text('Select a layer to edit its properties'))
                : _PropertiesPanel(
                    key: ValueKey(_selected),
                    group: _selected!,
                    onChanged: () => setState(() {}),
                    onDelete: _deleteSelected,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerWidget(LayerGroup group, double cardWidthPx, double cardHeightPx) {
    final isSelected = identical(_selected, group);
    final left = group.xMm * pxPerMm;
    final top = group.yMm * pxPerMm;

    Widget content;
    if (group.fieldType == LayerFieldType.image) {
      final widthPx = (group.widthMm ?? 20) * pxPerMm;
      final heightPx = (group.heightMm ?? 20) * pxPerMm;
      content = Container(
        width: widthPx,
        height: heightPx,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey, style: BorderStyle.solid)),
        child: const Icon(Icons.image, color: Colors.blueGrey),
      );
    } else {
      final fontSizePx = group.fontSizePt * ptToMm * pxPerMm;
      final source = group.sources.isNotEmpty ? group.sources.first : null;
      final text = source?.key != null && source!.key!.isNotEmpty
          ? '${source.key}: ${source.value ?? ''}'
          : (source?.value ?? group.name);
      content = Text(
        text,
        style: TextStyle(
          fontSize: fontSizePx,
          fontWeight: group.bold ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => setState(() => _selected = group),
        onPanUpdate: (details) => setState(() {
          group.xMm = (group.xMm + details.delta.dx / pxPerMm)
              .clamp(0, widget.template.cardWidthMm - 1);
          group.yMm = (group.yMm + details.delta.dy / pxPerMm)
              .clamp(0, widget.template.cardHeightMm - 1);
        }),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 1.5),
          ),
          child: content,
        ),
      ),
    );
  }
}

class _PropertiesPanel extends StatefulWidget {
  final LayerGroup group;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const _PropertiesPanel({super.key, required this.group, required this.onChanged, required this.onDelete});

  @override
  State<_PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<_PropertiesPanel> {
  late TextEditingController _keyCtrl;
  late TextEditingController _valueCtrl;

  @override
  void initState() {
    super.initState();
    final source = widget.group.sources.isNotEmpty ? widget.group.sources.first : null;
    _keyCtrl = TextEditingController(text: source?.key ?? '');
    _valueCtrl = TextEditingController(text: source?.value ?? '');
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _ensureSource() {
    if (widget.group.sources.isEmpty) {
      widget.group.sources.add(LayerSourceItem(type: widget.group.fieldType));
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Layer properties', style: Theme.of(context).textTheme.titleMedium),
              IconButton(icon: const Icon(Icons.delete_outline), onPressed: widget.onDelete),
            ],
          ),
          const SizedBox(height: 8),
          if (group.fieldType == LayerFieldType.text) ...[
            TextField(
              controller: _keyCtrl,
              decoration: const InputDecoration(labelText: 'Field key (matches source PDF)'),
              onChanged: (v) {
                _ensureSource();
                group.sources.first.key = v;
                widget.onChanged();
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _valueCtrl,
              decoration: const InputDecoration(labelText: 'Sample value'),
              onChanged: (v) {
                _ensureSource();
                group.sources.first.value = v;
                widget.onChanged();
              },
            ),
            const SizedBox(height: 8),
            _NumberField(
              label: 'Font size (pt)',
              value: group.fontSizePt,
              onChanged: (v) {
                group.fontSizePt = v;
                widget.onChanged();
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bold'),
              value: group.bold,
              onChanged: (v) {
                group.bold = v;
                widget.onChanged();
              },
            ),
          ] else ...[
            _NumberField(
              label: 'Width (mm)',
              value: group.widthMm ?? 20,
              onChanged: (v) {
                group.widthMm = v;
                widget.onChanged();
              },
            ),
            const SizedBox(height: 8),
            _NumberField(
              label: 'Height (mm)',
              value: group.heightMm ?? 20,
              onChanged: (v) {
                group.heightMm = v;
                widget.onChanged();
              },
            ),
          ],
          const Divider(height: 32),
          _NumberField(
            label: 'X position (mm)',
            value: group.xMm,
            onChanged: (v) {
              group.xMm = v;
              widget.onChanged();
            },
          ),
          const SizedBox(height: 8),
          _NumberField(
            label: 'Y position (mm)',
            value: group.yMm,
            onChanged: (v) {
              group.yMm = v;
              widget.onChanged();
            },
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _NumberField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('$label-${value.toStringAsFixed(1)}'),
      initialValue: value.toStringAsFixed(1),
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onFieldSubmitted: (v) {
        final parsed = double.tryParse(v);
        if (parsed != null) onChanged(parsed);
      },
    );
  }
}

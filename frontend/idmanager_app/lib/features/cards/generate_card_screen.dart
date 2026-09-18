import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/card.dart';
import '../../core/models/enums.dart';
import '../../core/models/layer.dart';
import '../../core/models/template.dart';
import '../../core/network/template_api.dart';
import '../../core/state/providers.dart';

class GenerateCardScreen extends ConsumerStatefulWidget {
  const GenerateCardScreen({super.key});

  @override
  ConsumerState<GenerateCardScreen> createState() => _GenerateCardScreenState();
}

class _GenerateCardScreenState extends ConsumerState<GenerateCardScreen> {
  static const double pxPerMm = 4.0;
  static const double ptToMm = 25.4 / 72;

  List<TemplateSummary> _templates = [];
  TemplateSummary? _selectedTemplate;
  TemplateDetail? _templateDetail;
  CombinationDto? _selectedCombination;
  PlatformFile? _pdfFile;
  GenerateCardResponse? _result;
  CardSide _side = CardSide.front;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref.read(templateApiProvider).getAll(pageSize: 100).then((r) {
      setState(() => _templates = r.items.where((t) => t.status).toList());
    });
  }

  Future<void> _onTemplateSelected(TemplateSummary? t) async {
    setState(() {
      _selectedTemplate = t;
      _templateDetail = null;
      _selectedCombination = null;
      _result = null;
    });
    if (t == null) return;
    final detail = await ref.read(templateApiProvider).getTemplate(t.id);
    setState(() {
      _templateDetail = detail;
      _selectedCombination = detail.combinations.isNotEmpty ? detail.combinations.first : null;
    });
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pdfFile = result.files.first);
    }
  }

  Future<void> _generate() async {
    if (_selectedTemplate == null || _selectedCombination == null || _pdfFile == null) {
      setState(() => _error = 'Select a template, a combination and a PDF file.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await ref.read(cardApiProvider).generate(
            templateId: _selectedTemplate!.id,
            combinationId: _selectedCombination!.id,
            file: PickedFile(_pdfFile!.bytes!, _pdfFile!.name),
          );
      setState(() => _result = response);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _download() async {
    if (_result == null) return;
    setState(() => _loading = true);
    try {
      final bytes = await ref.read(cardApiProvider).download(_result!.idCardId);
      await FileSaver.instance.saveFile(
        name: 'card-${_result!.idCardId}',
        bytes: Uint8List.fromList(bytes),
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card PDF saved.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate ID Card')),
      body: Row(
        children: [
          SizedBox(
            width: 340,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<TemplateSummary>(
                  initialValue: _selectedTemplate,
                  decoration: const InputDecoration(labelText: 'Template'),
                  items: _templates
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                      .toList(),
                  onChanged: _onTemplateSelected,
                ),
                if (_templateDetail != null) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CombinationDto>(
                    initialValue: _selectedCombination,
                    decoration: const InputDecoration(labelText: 'Combination'),
                    items: _templateDetail!.combinations
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                        .toList(),
                    onChanged: (c) => setState(() => _selectedCombination = c),
                  ),
                ],
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickPdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(_pdfFile?.name ?? 'Choose member PDF'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _generate,
                  child: _loading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Preview card'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                if (_result != null) ...[
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _loading ? null : _download,
                    icon: const Icon(Icons.download),
                    label: const Text('Download print-ready PDF'),
                  ),
                ],
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _result == null
                ? const Center(child: Text('Preview will appear here after parsing the PDF.'))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SegmentedButton<CardSide>(
                          segments: const [
                            ButtonSegment(value: CardSide.front, label: Text('Front')),
                            ButtonSegment(value: CardSide.back, label: Text('Back')),
                          ],
                          selected: {_side},
                          onSelectionChanged: (s) => setState(() => _side = s.first),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: InteractiveViewer(
                            minScale: 0.3,
                            maxScale: 6,
                            child: _buildPreview(),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final result = _result!;
    final widthPx = result.cardWidthMm * pxPerMm;
    final heightPx = result.cardHeightMm * pxPerMm;
    final imageBase64 = _side == CardSide.front ? result.frontImageBase64 : result.backImageBase64;
    final layer = result.layers.firstWhere(
      (l) => l.side == _side,
      orElse: () => TemplateLayer(side: _side),
    );

    return Container(
      width: widthPx,
      height: heightPx,
      decoration: BoxDecoration(border: Border.all(color: Colors.black26), color: Colors.white),
      child: Stack(
        children: [
          if (imageBase64.isNotEmpty) Positioned.fill(child: Image.memory(base64Decode(imageBase64), fit: BoxFit.fill)),
          for (final group in layer.groups)
            Positioned(
              left: group.xMm * pxPerMm,
              top: group.yMm * pxPerMm,
              child: group.fieldType == LayerFieldType.image
                  ? SizedBox(
                      width: (group.widthMm ?? 20) * pxPerMm,
                      height: (group.heightMm ?? 20) * pxPerMm,
                      child: group.sources.isNotEmpty && (group.sources.first.value ?? '').isNotEmpty
                          ? Image.memory(base64Decode(group.sources.first.value!), fit: BoxFit.contain)
                          : const ColoredBox(color: Colors.black12),
                    )
                  : Text(
                      group.sources.map((s) => [s.key, s.value].where((v) => v != null && v.isNotEmpty).join(': ')).join('  '),
                      style: TextStyle(
                        fontSize: group.fontSizePt * ptToMm * pxPerMm,
                        fontWeight: group.bold ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

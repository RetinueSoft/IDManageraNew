import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/cards/generate_card_controller.dart';
import '../../core_engine/cards/domain/generated_card.dart';
import '../../core_engine/common/enums.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../../core_engine/templates/domain/template_layer.dart';

class GenerateCardScreen extends ConsumerStatefulWidget {
  const GenerateCardScreen({super.key});

  @override
  ConsumerState<GenerateCardScreen> createState() => _GenerateCardScreenState();
}

class _GenerateCardScreenState extends ConsumerState<GenerateCardScreen> {
  static const double pxPerMm = 4.0;
  static const double ptToMm = 25.4 / 72;

  CardSide _side = CardSide.front;
  PlatformFile? _pickedFile;

  Future<void> _pickPdf(GenerateCardController controller) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _pickedFile = result.files.first);
    controller.setPdfFile(UploadedFile(result.files.first.bytes!, result.files.first.name));
  }

  Future<void> _download(GenerateCardController controller) async {
    final bytes = await controller.downloadPdf();
    if (bytes == null) return;
    await FileSaver.instance.saveFile(name: 'card', bytes: bytes, ext: 'pdf', mimeType: MimeType.pdf);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card PDF saved.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = generateCardControllerProvider;
    final stateAsync = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate ID Card')),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load templates: $e')),
        data: (state) => Row(
          children: [
            SizedBox(
              width: 340,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: state.selectedTemplateId,
                    decoration: const InputDecoration(labelText: 'Template'),
                    items: [
                      for (final t in state.templateOptions)
                        DropdownMenuItem(value: t.id, child: Text(t.label)),
                    ],
                    onChanged: controller.selectTemplate,
                  ),
                  if (state.combinationOptions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: state.selectedCombinationId,
                      decoration: const InputDecoration(labelText: 'Combination'),
                      items: [
                        for (final c in state.combinationOptions)
                          DropdownMenuItem(value: c.id, child: Text(c.label)),
                      ],
                      onChanged: controller.selectCombination,
                    ),
                  ],
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _pickPdf(controller),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(_pickedFile?.name ?? 'Choose member PDF'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: state.isBusy ? null : controller.generate,
                    child: state.isBusy
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Preview card'),
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  if (state.result != null) ...[
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: state.isBusy ? null : () => _download(controller),
                      icon: const Icon(Icons.download),
                      label: const Text('Download print-ready PDF'),
                    ),
                  ],
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: state.result == null
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
                              child: _buildPreview(state.result!),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(GeneratedCard result) {
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
          if (imageBase64.isNotEmpty)
            Positioned.fill(child: Image.memory(base64Decode(imageBase64), fit: BoxFit.fill)),
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
                      group.sources
                          .map((s) => [s.key, s.value].where((v) => v != null && v.isNotEmpty).join(': '))
                          .join('  '),
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

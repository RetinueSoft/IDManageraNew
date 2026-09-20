import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/cards/generate_card_controller.dart';
import '../../core_engine/common/enums.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../templates/layout_workspace.dart';

class GenerateCardScreen extends ConsumerStatefulWidget {
  const GenerateCardScreen({super.key});

  @override
  ConsumerState<GenerateCardScreen> createState() => _GenerateCardScreenState();
}

class _GenerateCardScreenState extends ConsumerState<GenerateCardScreen> {
  PlatformFile? _pickedFile;

  Future<void> _pickPdf(GenerateCardController controller) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _pickedFile = result.files.first);
    controller.setPdfFile(
      UploadedFile(result.files.first.bytes!, result.files.first.name),
    );
  }

  Future<void> _pickQr(
    GenerateCardController controller,
    String slotKey,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null ||
        result.files.isEmpty ||
        result.files.first.bytes == null)
      return;
    controller.setQrFile(
      slotKey,
      UploadedFile(result.files.first.bytes!, result.files.first.name),
    );
  }

  Future<void> _download(GenerateCardController controller) async {
    final bytes = await controller.downloadPdf();
    if (bytes == null) return;
    await FileSaver.instance.saveFile(
      name: 'card',
      bytes: bytes,
      ext: 'pdf',
      mimeType: MimeType.pdf,
    );
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Card PDF saved.')));
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
                  if (state.selectedTemplateId != null &&
                      state.combinationOptions.isEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      "This template has no combinations, so its own front and back images are used.",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (state.combinationOptions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: state.selectedCombinationId,
                      decoration: const InputDecoration(
                        labelText: 'Combination',
                      ),
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
                  for (final slot in state.qrSlots) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _pickQr(controller, slot.key),
                      icon: const Icon(Icons.qr_code_2),
                      label: Text(
                        state.qrFiles[slot.key]?.name ??
                            'Choose QR image - ${slot.label}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: state.isBusy ? null : controller.generate,
                    child: state.isBusy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Preview card'),
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  if (state.result != null) ...[
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: state.isBusy
                          ? null
                          : () => _download(controller),
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
                  ? const Center(
                      child: Text(
                        'Preview will appear here after parsing the PDF.',
                      ),
                    )
                  // The same working area as the template designer; the layer name and the
                  // field keys are read-only and the template's structure cannot change.
                  : LayoutWorkspace(
                      designer: false,
                      layers: state.result!.layers,
                      cardWidthMm: state.result!.cardWidthMm,
                      cardHeightMm: state.result!.cardHeightMm,
                      frontImageBase64: state.result!.frontImageBase64,
                      backImageBase64: state.result!.backImageBase64,
                      side: state.side,
                      combined: state.combined,
                      selectedGroupId: state.selectedGroupId,
                      onSelectView: (view) => switch (view) {
                        EditorView.combined => controller.selectCombined(),
                        EditorView.front => controller.selectSide(
                          CardSide.front,
                        ),
                        EditorView.back => controller.selectSide(CardSide.back),
                      },
                      onSelectLayer: controller.selectLayer,
                      onMoveGroup: controller.moveGroup,
                      onChanged: controller.updateGroup,
                      onDelete: controller.deleteSelected,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

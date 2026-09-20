import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/cards/generate_card_controller.dart';
import '../../core_engine/common/enums.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../../foundation/files/pdf_download.dart';
import '../../application/cards/generate_card_state.dart';
import '../../application/security/session_controller.dart';
import '../../core_engine/templates/domain/card_background.dart';
import '../templates/collapsible_panel.dart';
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
    final pdf = await controller.downloadPdf();
    if (pdf == null) return;
    // Named from the template's file name pattern (e.g. the member's name). It goes into Downloads
    // without replacing a file that is already there ("Ravi.pdf", then "Ravi (1).pdf" ...).
    final savedAs = await savePdfDownload(name: pdf.name, bytes: pdf.bytes);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Saved $savedAs')));
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
            // Can be folded away to give the preview the whole width, like the designer's
            // Layers panel.
            CollapsiblePanel(
              title: 'Template',
              width: 340,
              edge: CollapseEdge.left,
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
                  if (state.template != null) ...[
                    const SizedBox(height: 12),
                    // The template's backgrounds. Picking another one takes effect on the next
                    // Preview.
                    DropdownButtonFormField<int>(
                      key: ValueKey('background-${state.selectedTemplateId}'),
                      initialValue: backgroundOrDefault(
                        state.template!.backgrounds,
                        state.selectedCombinationId,
                      ).id,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Background',
                      ),
                      items: [
                        for (final b in state.template!.backgrounds)
                          DropdownMenuItem(
                            value: b.id,
                            child: Text(
                              b.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
            Expanded(child: _buildRight(state, controller)),
          ],
        ),
      ),
    );
  }

  /// The working area: empty until the card is previewed, then the same workspace as the
  /// template designer, showing only the background the card was previewed with.
  Widget _buildRight(
    GenerateCardState state,
    GenerateCardController controller,
  ) {
    final result = state.result;
    if (result == null) {
      return const Center(
        child: Text('Preview will appear here after parsing the PDF.'),
      );
    }

    // The preview is marked with who is previewing and when, so a screenshot or a photo of it is
    // traceable and not the real card (the downloaded PDF has no watermark).
    final user = ref.watch(sessionControllerProvider).value;
    final watermark = previewWatermarkText(
      name: user?.name ?? '',
      phone: user?.phone ?? '',
      date: DateTime.now(),
    );

    // The layer name and the field keys are hidden or read-only and the template's structure
    // cannot change.
    return LayoutWorkspace(
      designer: false,
      watermark: watermark,
      layers: result.layers,
      cardWidthMm: result.cardWidthMm,
      cardHeightMm: result.cardHeightMm,
      frontImageBase64: result.frontImageBase64,
      backImageBase64: result.backImageBase64,
      side: state.side,
      combined: state.combined,
      selectedGroupId: state.selectedGroupId,
      onSelectView: (view) => switch (view) {
        EditorView.combined => controller.selectCombined(),
        EditorView.front => controller.selectSide(CardSide.front),
        EditorView.back => controller.selectSide(CardSide.back),
      },
      onSelectLayer: controller.selectLayer,
      onMoveGroup: controller.moveGroup,
      onChanged: controller.updateGroup,
      onDelete: controller.deleteSelected,
    );
  }
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// The words repeated across the preview: "PREVIEW", who is previewing and the date, e.g.
/// "PREVIEW  Ravi  9943135008  20 Sep 2026". Whatever of the name and phone is missing is left out.
String previewWatermarkText({
  required String name,
  required String phone,
  required DateTime date,
}) {
  final day = '${date.day} ${_months[date.month - 1]} ${date.year}';
  return [
    'PREVIEW',
    name.trim(),
    phone.trim(),
    day,
  ].where((part) => part.isNotEmpty).join('   ');
}

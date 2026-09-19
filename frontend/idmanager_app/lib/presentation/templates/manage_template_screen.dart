import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/templates/template_form_controller.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../routing/app_routes.dart';
import '../shared/master_template/manage_master_scaffold.dart';
import '../shared/master_template/master_form_section.dart';

/// Add/Edit screen for a Template's base fields (name, card size, point cost,
/// front/back images). Layer positions are edited separately on the designer
/// canvas once the template exists.
class ManageTemplateScreen extends ConsumerStatefulWidget {
  const ManageTemplateScreen({super.key, this.templateId});

  final int? templateId;

  @override
  ConsumerState<ManageTemplateScreen> createState() => _ManageTemplateScreenState();
}

class _ManageTemplateScreenState extends ConsumerState<ManageTemplateScreen> {
  final _name = TextEditingController();
  final _width = TextEditingController();
  final _height = TextEditingController();
  final _pointCost = TextEditingController();
  bool _initialized = false;

  bool get _isEditMode => widget.templateId != null;

  @override
  void dispose() {
    _name.dispose();
    _width.dispose();
    _height.dispose();
    _pointCost.dispose();
    super.dispose();
  }

  Future<void> _pickImage(TemplateFormController controller, bool isFront) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = UploadedFile(result.files.first.bytes!, result.files.first.name);
    controller.updateFields(
      (s) => isFront ? s.copyWith(frontFile: file) : s.copyWith(backFile: file),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = templateFormControllerProvider(widget.templateId);
    final formAsync = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    return formAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(_isEditMode ? 'Edit Template' : 'New Template')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Template')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (state) {
        if (!_initialized) {
          _name.text = state.name;
          _width.text = state.cardWidthMm.toStringAsFixed(1);
          _height.text = state.cardHeightMm.toStringAsFixed(1);
          _pointCost.text = state.pointCost.toString();
          _initialized = true;
        }

        return ManageMasterScaffold(
          title: _isEditMode ? 'Edit Template' : 'New Template',
          isSaving: state.isSaving,
          validationBanner: ManageMasterScaffold.validationBannerFor(
            state.errors,
            const {'name', 'frontImage', 'backImage'},
          ),
          onCancel: () => context.go(AppRoutes.templates),
          sections: [
            MasterFormSection(
              title: 'Details',
              children: [
                TextField(
                  controller: _name,
                  decoration: InputDecoration(labelText: 'Name', errorText: state.errors['name']),
                  onChanged: (v) => controller.updateFields((s) => s.copyWith(name: v)),
                ),
                if (!_isEditMode)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _width,
                          decoration: const InputDecoration(labelText: 'Width (mm)'),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => controller.updateFields(
                            (s) => s.copyWith(cardWidthMm: double.tryParse(v) ?? s.cardWidthMm),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _height,
                          decoration: const InputDecoration(labelText: 'Height (mm)'),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => controller.updateFields(
                            (s) => s.copyWith(cardHeightMm: double.tryParse(v) ?? s.cardHeightMm),
                          ),
                        ),
                      ),
                    ],
                  ),
                TextField(
                  controller: _pointCost,
                  decoration: const InputDecoration(labelText: 'Point cost'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => controller.updateFields(
                    (s) => s.copyWith(pointCost: int.tryParse(v) ?? s.pointCost),
                  ),
                ),
                if (_isEditMode)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    value: state.isActive,
                    onChanged: (v) => controller.updateFields((s) => s.copyWith(isActive: v)),
                  ),
              ],
            ),
            MasterFormSection(
              title: 'Card images',
              children: [
                _ImagePickerTile(
                  label: 'Front image',
                  errorText: state.errors['frontImage'],
                  file: state.frontFile,
                  existingBase64: state.existingFrontImageBase64,
                  onPick: () => _pickImage(controller, true),
                ),
                _ImagePickerTile(
                  label: 'Back image',
                  errorText: state.errors['backImage'],
                  file: state.backFile,
                  existingBase64: state.existingBackImageBase64,
                  onPick: () => _pickImage(controller, false),
                ),
              ],
            ),
          ],
          onSave: () async {
            final id = await controller.save();
            if (id == null) return false;
            if (context.mounted) {
              _isEditMode ? context.go(AppRoutes.templates) : context.go(AppRoutes.templateDesign(id));
            }
            return true;
          },
        );
      },
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  const _ImagePickerTile({
    required this.label,
    required this.onPick,
    this.errorText,
    this.file,
    this.existingBase64,
  });

  final String label;
  final VoidCallback onPick;
  final String? errorText;
  final UploadedFile? file;
  final String? existingBase64;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (file != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(file!.bytes, width: 56, height: 56, fit: BoxFit.cover),
          )
        else if (existingBase64 != null && existingBase64!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(base64Decode(existingBase64!), width: 56, height: 56, fit: BoxFit.cover),
          )
        else
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.image_outlined),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: onPick,
            child: Text(file?.name ?? 'Choose $label'),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(width: 8),
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 18),
        ],
      ],
    );
  }
}

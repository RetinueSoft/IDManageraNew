import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/template.dart';
import '../../core/network/template_api.dart';
import '../../core/state/providers.dart';
import 'template_editor_screen.dart';

class TemplatesListScreen extends ConsumerStatefulWidget {
  const TemplatesListScreen({super.key});

  @override
  ConsumerState<TemplatesListScreen> createState() => _TemplatesListScreenState();
}

class _TemplatesListScreenState extends ConsumerState<TemplatesListScreen> {
  late Future<List<TemplateSummary>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ref.read(templateApiProvider).getAll().then((r) => r.items);
  }

  Future<void> _openEditor(int templateId) async {
    final detail = await ref.read(templateApiProvider).getTemplate(templateId);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TemplateEditorScreen(template: detail)),
    );
    setState(_load);
  }

  Future<void> _createTemplate() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _CreateTemplateDialog(onCreated: () => setState(_load)),
    );
    if (result == true) setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Templates'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _createTemplate, tooltip: 'New template'),
        ],
      ),
      body: FutureBuilder<List<TemplateSummary>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load templates: ${snapshot.error}'));
          }
          final templates = snapshot.data ?? [];
          if (templates.isEmpty) {
            return const Center(child: Text('No templates yet. Tap + to create one.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final t = templates[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _openEditor(t.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: t.frontImageBase64.isNotEmpty
                            ? Image.memory(base64Decode(t.frontImageBase64), fit: BoxFit.cover)
                            : const ColoredBox(color: Colors.black12, child: Icon(Icons.credit_card)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.name, style: Theme.of(context).textTheme.titleSmall),
                            Text('${t.pointCost} pt · ${t.status ? "Active" : "Inactive"}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CreateTemplateDialog extends ConsumerStatefulWidget {
  final VoidCallback onCreated;
  const _CreateTemplateDialog({required this.onCreated});

  @override
  ConsumerState<_CreateTemplateDialog> createState() => _CreateTemplateDialogState();
}

class _CreateTemplateDialogState extends ConsumerState<_CreateTemplateDialog> {
  final _nameCtrl = TextEditingController();
  final _widthCtrl = TextEditingController(text: '85.6');
  final _heightCtrl = TextEditingController(text: '54');
  final _pointCtrl = TextEditingController(text: '1');
  PlatformFile? _front;
  PlatformFile? _back;
  bool _saving = false;
  String? _error;

  Future<void> _pick(bool isFront) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => isFront ? _front = result.files.first : _back = result.files.first);
    }
  }

  Future<void> _save() async {
    if (_front == null || _back == null || _nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name, front image and back image are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(templateApiProvider).create(
            name: _nameCtrl.text.trim(),
            cardWidthMm: double.tryParse(_widthCtrl.text) ?? 85.6,
            cardHeightMm: double.tryParse(_heightCtrl.text) ?? 54,
            pointCost: int.tryParse(_pointCtrl.text) ?? 1,
            frontFile: PickedFile(_front!.bytes!, _front!.name),
            backFile: PickedFile(_back!.bytes!, _back!.name),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Card Template'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _widthCtrl,
                      decoration: const InputDecoration(labelText: 'Width (mm)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _heightCtrl,
                      decoration: const InputDecoration(labelText: 'Height (mm)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pointCtrl,
                decoration: const InputDecoration(labelText: 'Point cost'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _pick(true),
                icon: const Icon(Icons.image),
                label: Text(_front?.name ?? 'Choose front image'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _pick(false),
                icon: const Icon(Icons.image),
                label: Text(_back?.name ?? 'Choose back image'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Create'),
        ),
      ],
    );
  }
}

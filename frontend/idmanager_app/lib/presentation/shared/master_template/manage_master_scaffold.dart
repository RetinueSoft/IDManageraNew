import 'package:flutter/material.dart';

/// Manage (Add/Edit) screen chrome: top bar with an optional Delete action, a
/// validation banner, a scrollable list of form sections, and a sticky
/// Cancel/Save row. Entity-specific screens supply only their [sections].
class ManageMasterScaffold extends StatelessWidget {
  const ManageMasterScaffold({
    super.key,
    required this.title,
    required this.sections,
    required this.onSave,
    this.onCancel,
    this.onDelete,
    this.isSaving = false,
    this.validationBanner,
  });

  final String title;
  final List<Widget> sections;
  final Future<bool> Function() onSave;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final bool isSaving;
  final String? validationBanner;

  static String? validationBannerFor(Map<String, String> errors, Set<String> knownFields) {
    if (errors.isEmpty) return null;
    final unmapped = errors.entries.where((e) => !knownFields.contains(e.key));
    if (unmapped.isNotEmpty) return unmapped.map((e) => e.value).join('\n');
    return 'Please correct the highlighted fields.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (onDelete != null)
            IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Delete', onPressed: onDelete),
        ],
      ),
      body: Column(
        children: [
          if (validationBanner != null)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.errorContainer,
              padding: const EdgeInsets.all(12),
              child: Text(
                validationBanner!,
                style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
              ),
            ),
          Expanded(
            child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: sections),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (onCancel != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isSaving ? null : onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: isSaving ? null : () => onSave(),
                    child: isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

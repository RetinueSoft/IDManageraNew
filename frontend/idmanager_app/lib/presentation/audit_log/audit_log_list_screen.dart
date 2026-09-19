import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/audit/audit_log_list_controller.dart';

class AuditLogListScreen extends ConsumerWidget {
  const AuditLogListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(auditLogListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Audit Log')),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (entries) => entries.isEmpty
            ? const Center(child: Text('No audit log entries yet.'))
            : ListView.separated(
                itemCount: entries.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    title: Text('${entry.action} · ${entry.entityName}'),
                    subtitle: Text(
                      'User #${entry.userId ?? '-'}  •  ${entry.createdAt.toLocal()}'.split('.').first,
                    ),
                    trailing: entry.entityId != null ? Text('#${entry.entityId}') : null,
                  );
                },
              ),
      ),
    );
  }
}

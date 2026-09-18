import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/audit_log.dart';
import '../../core/state/providers.dart';

class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  late Future<List<AuditLogEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(auditLogApiProvider).getAll().then((r) => r.items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Log')),
      body: FutureBuilder<List<AuditLogEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No audit log entries yet.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = items[index];
              return ListTile(
                title: Text('${entry.action} · ${entry.entityName}'),
                subtitle: Text('User #${entry.userId ?? '-'}  •  ${entry.createdAt.toLocal()}'.split('.').first),
                trailing: entry.entityId != null ? Text('#${entry.entityId}') : null,
              );
            },
          );
        },
      ),
    );
  }
}

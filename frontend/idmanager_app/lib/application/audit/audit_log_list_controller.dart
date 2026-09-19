import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/audit/domain/audit_log_entry.dart';

part 'audit_log_list_controller.g.dart';

@riverpod
class AuditLogListController extends _$AuditLogListController {
  @override
  Future<List<AuditLogEntry>> build() async {
    final page = await ref.watch(auditLogServiceProvider).getAll(pageSize: 100);
    return page.items;
  }
}

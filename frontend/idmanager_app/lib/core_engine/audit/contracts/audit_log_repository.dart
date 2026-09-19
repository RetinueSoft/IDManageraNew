import '../../common/paged_result.dart';
import '../domain/audit_log_entry.dart';

abstract interface class AuditLogRepository {
  Future<PagedResult<AuditLogEntry>> getAll({int pageIndex = 1, int pageSize = 20});
}

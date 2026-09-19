import '../../core_engine/audit/audit_engine.dart';
import '../../core_engine/audit/domain/audit_log_entry.dart';
import '../../core_engine/common/paged_result.dart';

class AuditLogService {
  AuditLogService(this._engine);

  final AuditLogEngineService _engine;

  Future<PagedResult<AuditLogEntry>> getAll({int pageIndex = 1, int pageSize = 20}) =>
      _engine.getAll(pageIndex: pageIndex, pageSize: pageSize);
}

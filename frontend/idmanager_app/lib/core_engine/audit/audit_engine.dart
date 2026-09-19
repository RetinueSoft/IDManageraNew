import '../common/paged_result.dart';
import 'contracts/audit_log_repository.dart';
import 'domain/audit_log_entry.dart';

class AuditLogEngineService {
  AuditLogEngineService(this._repository);

  final AuditLogRepository _repository;

  Future<PagedResult<AuditLogEntry>> getAll({int pageIndex = 1, int pageSize = 20}) =>
      _repository.getAll(pageIndex: pageIndex, pageSize: pageSize);
}

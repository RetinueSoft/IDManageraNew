import '../models/audit_log.dart';
import '../models/paged_result.dart';
import 'api_client.dart';

class AuditLogApi {
  final ApiClient _client;
  AuditLogApi(this._client);

  Future<PagedResult<AuditLogEntry>> getAll({int pageIndex = 1, int pageSize = 20}) => _client.postJson(
        '/AuditLog/GetAll',
        {'pageIndex': pageIndex, 'pageSize': pageSize},
        (data) => PagedResult.fromJson(
            data as Map<String, dynamic>, (e) => AuditLogEntry.fromJson(e)),
      );
}

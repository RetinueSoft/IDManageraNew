import '../../core_engine/audit/contracts/audit_log_repository.dart';
import '../../core_engine/audit/domain/audit_log_entry.dart';
import '../../core_engine/common/paged_result.dart';
import '../../foundation/network/api_client.dart';

AuditLogEntry _fromJson(Map<String, dynamic> json) => AuditLogEntry(
  id: json['id'] as int,
  userId: json['userId'] as int?,
  action: json['action'] as String? ?? '',
  entityName: json['entityName'] as String? ?? '',
  entityId: json['entityId'] as String?,
  detailsJson: json['detailsJson'] as String?,
  createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
);

class ApiAuditLogRepository implements AuditLogRepository {
  ApiAuditLogRepository(this._client);

  final ApiClient _client;

  @override
  Future<PagedResult<AuditLogEntry>> getAll({int pageIndex = 1, int pageSize = 20}) =>
      _client.guard(() async {
        final response = await _client.dio.post(
          '/audit-log/list',
          data: {'pageIndex': pageIndex, 'pageSize': pageSize},
        );
        return PagedResult.fromJson(response.data as Map<String, dynamic>, _fromJson);
      });
}

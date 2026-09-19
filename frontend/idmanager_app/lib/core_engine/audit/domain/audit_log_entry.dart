import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log_entry.freezed.dart';

@freezed
sealed class AuditLogEntry with _$AuditLogEntry {
  const factory AuditLogEntry({
    required int id,
    int? userId,
    required String action,
    required String entityName,
    String? entityId,
    String? detailsJson,
    required DateTime createdAt,
  }) = _AuditLogEntry;
}

class AuditLogEntry {
  final int id;
  final int? userId;
  final String action;
  final String entityName;
  final String? entityId;
  final String? detailsJson;
  final DateTime createdAt;

  AuditLogEntry({
    required this.id,
    this.userId,
    required this.action,
    required this.entityName,
    this.entityId,
    this.detailsJson,
    required this.createdAt,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) => AuditLogEntry(
        id: json['id'] as int,
        userId: json['userId'] as int?,
        action: json['action'] as String? ?? '',
        entityName: json['entityName'] as String? ?? '',
        entityId: json['entityId'] as String?,
        detailsJson: json['detailsJson'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

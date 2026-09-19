import '../../core_engine/common/enums.dart';
import '../../core_engine/security/domain/user.dart';

/// [User] (Core Engine domain) deliberately has no JSON methods of its own -
/// serialization is an edge concern. This one lives in business_service because
/// AuthService (not any Infrastructure repository) is what persists the session
/// snapshot to local storage.
Map<String, dynamic> userToJson(User u) => {
  'id': u.id,
  'name': u.name,
  'phone': u.phone,
  'role': u.role.toInt(),
  'isActive': u.isActive,
  'points': u.points,
  'createdAt': u.createdAt.toIso8601String(),
};

User userFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as int,
  name: json['name'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  role: UserRole.fromInt(json['role'] as int? ?? 0),
  isActive: json['isActive'] as bool? ?? false,
  points: json['points'] as int? ?? 0,
  createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
);

import '../../core_engine/common/enums.dart';
import '../../core_engine/security/domain/user.dart';
import '../../core_engine/security/domain/user_profile.dart';

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
  ...userProfileToJson(u.profile),
  'hasIdFront': u.hasIdFront,
  'hasIdBack': u.hasIdBack,
};

/// The optional shop / identity fields as the API names them.
Map<String, dynamic> userProfileToJson(UserProfile p) => {
  'shopName': p.shopName,
  'shopAddress': p.shopAddress,
  'city': p.city,
  'pincode': p.pincode,
  'idType': p.idType,
  'idNumber': p.idNumber,
};

UserProfile userProfileFromJson(Map<String, dynamic> json) => UserProfile(
  shopName: json['shopName'] as String? ?? '',
  shopAddress: json['shopAddress'] as String? ?? '',
  city: json['city'] as String? ?? '',
  pincode: json['pincode'] as String? ?? '',
  idType: json['idType'] as String? ?? '',
  idNumber: json['idNumber'] as String? ?? '',
);

User userFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as int,
  name: json['name'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  role: UserRole.fromInt(json['role'] as int? ?? 0),
  isActive: json['isActive'] as bool? ?? false,
  points: json['points'] as int? ?? 0,
  createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  profile: userProfileFromJson(json),
  hasIdFront: json['hasIdFront'] as bool? ?? false,
  hasIdBack: json['hasIdBack'] as bool? ?? false,
);

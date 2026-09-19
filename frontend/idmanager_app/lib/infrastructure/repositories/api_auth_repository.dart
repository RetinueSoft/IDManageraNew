import '../../core_engine/common/enums.dart';
import '../../core_engine/security/contracts/auth_repository.dart';
import '../../core_engine/security/domain/user.dart';
import '../../foundation/network/api_client.dart';

User userFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as int,
  name: json['name'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  role: UserRole.fromInt(json['role'] as int? ?? 0),
  parentId: json['parentId'] as int?,
  parentName: json['parentName'] as String?,
  parentRole: json['parentRole'] == null ? null : UserRole.fromInt(json['parentRole'] as int),
  isActive: json['isActive'] as bool? ?? false,
  points: json['points'] as int? ?? 0,
  createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
);

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client);

  final ApiClient _client;

  @override
  Future<(String token, User user)> login(String phone, String password) =>
      _client.guard(() async {
        final response = await _client.dio.post(
          '/auth/login',
          data: {'phone': phone, 'password': password},
        );
        final body = response.data as Map<String, dynamic>;
        return (
          body['accessToken'] as String,
          userFromJson(body['user'] as Map<String, dynamic>),
        );
      });
}

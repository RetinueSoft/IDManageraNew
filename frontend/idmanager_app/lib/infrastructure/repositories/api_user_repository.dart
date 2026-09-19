import '../../core_engine/common/enums.dart';
import '../../core_engine/common/paged_result.dart';
import '../../core_engine/security/contracts/user_repository.dart';
import '../../core_engine/security/domain/user.dart';
import '../../foundation/network/api_client.dart';
import 'api_auth_repository.dart' show userFromJson;

class ApiUserRepository implements UserRepository {
  ApiUserRepository(this._client);

  final ApiClient _client;

  @override
  Future<PagedResult<User>> getAll({int pageIndex = 1, int pageSize = 20, String? searchBy}) =>
      _client.guard(() async {
        final response = await _client.dio.post(
          '/users/list',
          data: {'pageIndex': pageIndex, 'pageSize': pageSize, 'searchBy': searchBy},
        );
        return PagedResult.fromJson(response.data as Map<String, dynamic>, userFromJson);
      });

  @override
  Future<User?> getById(int id) => _client.guard(() async {
    final response = await _client.dio.get('/users/$id');
    return userFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<User> create({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  }) => _client.guard(() async {
    final response = await _client.dio.post(
      '/users/',
      data: {'name': name, 'phone': phone, 'password': password, 'role': role.toInt()},
    );
    return userFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<User> update({
    required int id,
    required String name,
    required bool isActive,
    String? password,
  }) => _client.guard(() async {
    final response = await _client.dio.put(
      '/users/',
      data: {'id': id, 'name': name, 'isActive': isActive, 'password': password},
    );
    return userFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> deactivate(int id) =>
      _client.guard(() => _client.dio.post('/users/$id/deactivate'));
}

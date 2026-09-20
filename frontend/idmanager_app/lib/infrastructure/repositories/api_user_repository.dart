import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../core_engine/common/enums.dart';
import '../../core_engine/common/paged_result.dart';
import '../../core_engine/security/contracts/user_repository.dart';
import '../../core_engine/security/domain/user.dart';
import '../../foundation/network/api_client.dart';
import '../../business_service/security/user_json.dart' show userProfileToJson;
import '../../core_engine/common/uploaded_file.dart';
import '../../core_engine/security/domain/user_profile.dart';
import '../../foundation/network/api_exception.dart';
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
    UserProfile profile = const UserProfile(),
  }) => _client.guard(() async {
    final response = await _client.dio.post(
      '/users/',
      data: {'name': name, 'phone': phone, 'password': password, 'role': role.toInt(), ...userProfileToJson(profile)},
    );
    return userFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<User> update({
    required int id,
    required String name,
    required bool isActive,
    String? password,
    UserProfile? profile,
  }) => _client.guard(() async {
    final response = await _client.dio.put(
      '/users/',
      data: {
        'id': id,
        'name': name,
        'isActive': isActive,
        'password': password,
        // Sent only when given: a missing detail is left as it is on the server.
        if (profile != null) ...userProfileToJson(profile),
      },
    );
    return userFromJson(response.data as Map<String, dynamic>);
  });

  @override
  Future<void> deactivate(int id) =>
      _client.guard(() => _client.dio.post('/users/$id/deactivate'));

  @override
  Future<Uint8List?> getIdentityImage(int userId, IdentitySide side) async {
    try {
      return await _client.guard(() async {
        final response = await _client.dio.get<List<int>>(
          '/users/$userId/identity/${side.wireName}',
          options: Options(responseType: ResponseType.bytes),
        );
        return Uint8List.fromList(response.data ?? []);
      });
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null; // no image on that side
      rethrow;
    }
  }

  @override
  Future<void> setIdentityImage(int userId, IdentitySide side, UploadedFile file) => _client.guard(
    () => _client.dio.put(
      '/users/$userId/identity/${side.wireName}',
      data: FormData.fromMap({'file': MultipartFile.fromBytes(file.bytes, filename: file.name)}),
    ),
  );

  @override
  Future<void> deleteIdentityImage(int userId, IdentitySide side) =>
      _client.guard(() => _client.dio.delete('/users/$userId/identity/${side.wireName}'));
}

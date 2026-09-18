import '../models/enums.dart';
import '../models/paged_result.dart';
import '../models/user.dart';
import 'api_client.dart';

class UserApi {
  final ApiClient _client;
  UserApi(this._client);

  Future<PagedResult<UserDto>> getAll({int pageIndex = 1, int pageSize = 20, String? searchBy}) =>
      _client.postJson(
        '/Users/GetAll',
        {'pageIndex': pageIndex, 'pageSize': pageSize, 'searchBy': searchBy},
        (data) => PagedResult.fromJson(
            data as Map<String, dynamic>, (e) => UserDto.fromJson(e)),
      );

  Future<UserDto> create({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  }) =>
      _client.postJson(
        '/Users/Create',
        {'name': name, 'phone': phone, 'password': password, 'role': role.toInt()},
        (data) => UserDto.fromJson(data as Map<String, dynamic>),
      );

  Future<void> deactivate(int userId) => _client.postJson(
        '/Users/Deactivate',
        userId,
        (_) {},
      );
}

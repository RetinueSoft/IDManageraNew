import '../models/user.dart';
import 'api_client.dart';

class AuthApi {
  final ApiClient _client;
  AuthApi(this._client);

  Future<LoginResponse> login(String phone, String password) => _client.postJson(
        '/Auth/login',
        {'phone': phone, 'password': password},
        (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
      );
}

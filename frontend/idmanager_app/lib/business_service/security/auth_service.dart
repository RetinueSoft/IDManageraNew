import 'dart:convert';

import '../../core_engine/security/domain/user.dart';
import '../../core_engine/security/security_engine.dart';
import '../../foundation/network/api_client.dart';
import '../../foundation/storage/token_storage.dart';
import 'user_json.dart';

/// Coordinates the Security Engine's login with session persistence (Foundation's
/// Local Storage) and attaching the token to every future API call (Foundation's
/// API client) - the Engine itself only knows how to call the login endpoint.
class AuthService {
  AuthService(this._engine, this._apiClient, this._tokenStorage);

  final AuthEngineService _engine;
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<User> login(String phone, String password) async {
    final (token, user) = await _engine.login(phone, password);
    _apiClient.setToken(token);
    await _tokenStorage.save(token, jsonEncode(userToJson(user)));
    return user;
  }

  /// Re-attaches a previously saved session's token/user on app start, or null if
  /// there is no saved session.
  Future<User?> restoreSession() async {
    final token = await _tokenStorage.readToken();
    final userJson = await _tokenStorage.readUserJson();
    if (token == null || userJson == null) return null;

    _apiClient.setToken(token);
    return userFromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  Future<void> logout() async {
    _apiClient.setToken(null);
    await _tokenStorage.clear();
  }
}

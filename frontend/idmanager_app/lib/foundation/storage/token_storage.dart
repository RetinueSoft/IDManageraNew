import 'package:shared_preferences/shared_preferences.dart';

/// Persists the current session's JWT + user snapshot across app restarts
/// (Foundation Engine responsibility - Local Storage). This app being fully
/// online, this is the only thing ever persisted on-device; no business data is
/// cached locally.
class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _userJsonKey = 'auth_user';

  Future<String?> readToken() async =>
      (await SharedPreferences.getInstance()).getString(_tokenKey);

  Future<String?> readUserJson() async =>
      (await SharedPreferences.getInstance()).getString(_userJsonKey);

  Future<void> save(String token, String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userJsonKey, userJson);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userJsonKey);
  }
}

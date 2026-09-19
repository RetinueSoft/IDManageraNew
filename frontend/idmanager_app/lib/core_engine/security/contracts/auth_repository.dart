import '../domain/user.dart';

abstract interface class AuthRepository {
  /// Throws [ValidationException]/the underlying network error on failure.
  Future<(String token, User user)> login(String phone, String password);
}

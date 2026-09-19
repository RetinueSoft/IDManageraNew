import '../../core_engine/common/enums.dart';
import '../../core_engine/common/paged_result.dart';
import '../../core_engine/common/validation_exception.dart';
import '../../core_engine/security/domain/user.dart';
import '../../core_engine/security/security_engine.dart';

class UserService {
  UserService(this._engine);

  final UserEngineService _engine;

  Future<PagedResult<User>> getAll({int pageIndex = 1, int pageSize = 20, String? searchBy}) =>
      _engine.getAll(pageIndex: pageIndex, pageSize: pageSize, searchBy: searchBy);

  Future<User?> getUser(int id) => _engine.getById(id);

  Future<User> createUser({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  }) => _engine.create(name: name, phone: phone, password: password, role: role);

  /// A user is never allowed to deactivate their own account - the acting user's
  /// id is passed in so this business rule can be enforced independent of
  /// whatever the UI happens to show.
  Future<User> updateUser({
    required int actingUserId,
    required int id,
    required String name,
    required bool isActive,
    String? password,
  }) {
    if (id == actingUserId && !isActive) {
      throw ValidationException({'isActive': 'You cannot deactivate your own account.'});
    }
    return _engine.update(id: id, name: name, isActive: isActive, password: password);
  }

  Future<void> deactivate(int actingUserId, int id) {
    if (id == actingUserId) {
      throw ValidationException({'isActive': 'You cannot deactivate your own account.'});
    }
    return _engine.deactivate(id);
  }
}

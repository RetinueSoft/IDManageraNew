import '../../foundation/network/api_exception.dart';
import '../common/enums.dart';
import '../common/paged_result.dart';
import '../common/validation_exception.dart';
import 'contracts/auth_repository.dart';
import 'contracts/user_repository.dart';
import 'domain/user.dart';

class AuthEngineService {
  AuthEngineService(this._repository);

  final AuthRepository _repository;

  Future<(String token, User user)> login(String phone, String password) =>
      _repository.login(phone, password);
}

class UserEngineService {
  UserEngineService(this._repository);

  final UserRepository _repository;

  Future<PagedResult<User>> getAll({int pageIndex = 1, int pageSize = 20, String? searchBy}) =>
      _repository.getAll(pageIndex: pageIndex, pageSize: pageSize, searchBy: searchBy);

  Future<User?> getById(int id) => _repository.getById(id);

  Future<User> create({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    final errors = <String, String>{};
    if (name.trim().isEmpty) errors['name'] = 'Name is required.';
    if (phone.trim().isEmpty) errors['phone'] = 'Phone is required.';
    if (password.isEmpty) errors['password'] = 'Password is required.';
    if (errors.isNotEmpty) throw ValidationException(errors);

    try {
      return await _repository.create(name: name, phone: phone, password: password, role: role);
    } on ApiException catch (e) {
      if (e.fieldErrors != null) throw ValidationException(e.fieldErrors!);
      rethrow;
    }
  }

  Future<User> update({
    required int id,
    required String name,
    required bool isActive,
    String? password,
  }) async {
    if (name.trim().isEmpty) {
      throw ValidationException({'name': 'Name is required.'});
    }
    try {
      return await _repository.update(id: id, name: name, isActive: isActive, password: password);
    } on ApiException catch (e) {
      if (e.fieldErrors != null) throw ValidationException(e.fieldErrors!);
      rethrow;
    }
  }

  Future<void> deactivate(int id) => _repository.deactivate(id);
}

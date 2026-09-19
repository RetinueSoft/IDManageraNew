import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/common/enums.dart';
import 'package:idmanager_app/core_engine/common/paged_result.dart';
import 'package:idmanager_app/core_engine/common/validation_exception.dart';
import 'package:idmanager_app/core_engine/security/contracts/auth_repository.dart';
import 'package:idmanager_app/core_engine/security/contracts/user_repository.dart';
import 'package:idmanager_app/core_engine/security/domain/user.dart';
import 'package:idmanager_app/core_engine/security/security_engine.dart';
import 'package:idmanager_app/foundation/network/api_exception.dart';

User _user({int id = 1, String name = 'Alice', UserRole role = UserRole.user}) => User(
  id: id,
  name: name,
  phone: '9000000000',
  role: role,
  isActive: true,
  points: 0,
  createdAt: DateTime(2026, 1, 1),
);

class _FakeAuthRepository implements AuthRepository {
  (String, User)? loginResult;
  Object? loginError;

  @override
  Future<(String token, User user)> login(String phone, String password) async {
    if (loginError != null) throw loginError!;
    return loginResult!;
  }
}

class _FakeUserRepository implements UserRepository {
  Object? createError;
  Object? updateError;
  User? createReturns;
  User? updateReturns;
  CreateUserRequestCapture? capturedCreate;

  @override
  Future<PagedResult<User>> getAll({int pageIndex = 1, int pageSize = 20, String? searchBy}) async =>
      PagedResult(items: const [], totalCount: 0, pageIndex: pageIndex, pageSize: pageSize);

  @override
  Future<User?> getById(int id) async => null;

  @override
  Future<User> create({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    capturedCreate = CreateUserRequestCapture(name, phone, password, role);
    if (createError != null) throw createError!;
    return createReturns!;
  }

  @override
  Future<User> update({
    required int id,
    required String name,
    required bool isActive,
    String? password,
  }) async {
    if (updateError != null) throw updateError!;
    return updateReturns!;
  }

  @override
  Future<void> deactivate(int id) async {}
}

class CreateUserRequestCapture {
  CreateUserRequestCapture(this.name, this.phone, this.password, this.role);
  final String name;
  final String phone;
  final String password;
  final UserRole role;
}

void main() {
  group('AuthEngineService', () {
    test('login delegates to the repository and returns its result', () async {
      final repo = _FakeAuthRepository()..loginResult = ('token-123', _user());
      final engine = AuthEngineService(repo);

      final (token, user) = await engine.login('9000000000', 'secret');

      expect(token, 'token-123');
      expect(user.name, 'Alice');
    });
  });

  group('UserEngineService.create', () {
    test('throws ValidationException locally when required fields are blank', () async {
      final repo = _FakeUserRepository();
      final engine = UserEngineService(repo);

      await expectLater(
        () => engine.create(name: '', phone: '', password: '', role: UserRole.user),
        throwsA(isA<ValidationException>()),
      );
      // The repository must never be called once local validation already failed.
      expect(repo.capturedCreate, isNull);
    });

    test('passes through to the repository when fields are valid', () async {
      final repo = _FakeUserRepository()..createReturns = _user(name: 'New Guy');
      final engine = UserEngineService(repo);

      final result = await engine.create(
        name: 'New Guy',
        phone: '9111111111',
        password: 'Pass@123',
        role: UserRole.distributor,
      );

      expect(result.name, 'New Guy');
      expect(repo.capturedCreate!.role, UserRole.distributor);
    });

    test('converts an ApiException.fieldErrors into a ValidationException', () async {
      final repo = _FakeUserRepository()
        ..createError = ApiException('bad', fieldErrors: {'phone': 'Phone already taken.'});
      final engine = UserEngineService(repo);

      try {
        await engine.create(name: 'X', phone: '9000000000', password: 'x', role: UserRole.user);
        fail('expected a ValidationException');
      } on ValidationException catch (e) {
        expect(e.errors['phone'], 'Phone already taken.');
      }
    });

    test('rethrows a plain ApiException with no field errors', () async {
      final repo = _FakeUserRepository()..createError = ApiException('Network error.');
      final engine = UserEngineService(repo);

      await expectLater(
        () => engine.create(name: 'X', phone: '9000000000', password: 'x', role: UserRole.user),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('UserEngineService.update', () {
    test('throws locally when name is blank', () async {
      final repo = _FakeUserRepository();
      final engine = UserEngineService(repo);

      await expectLater(
        () => engine.update(id: 1, name: '  ', isActive: true),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}

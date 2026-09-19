import '../../common/enums.dart';
import '../../common/paged_result.dart';
import '../domain/user.dart';

abstract interface class UserRepository {
  Future<PagedResult<User>> getAll({int pageIndex = 1, int pageSize = 20, String? searchBy});
  Future<User?> getById(int id);
  Future<User> create({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  });
  Future<User> update({
    required int id,
    required String name,
    required bool isActive,
    String? password,
  });
  Future<void> deactivate(int id);
}

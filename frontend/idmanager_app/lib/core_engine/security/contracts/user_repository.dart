import 'dart:typed_data';

import '../../common/enums.dart';
import '../../common/paged_result.dart';
import '../../common/uploaded_file.dart';
import '../domain/user.dart';
import '../domain/user_profile.dart';

abstract interface class UserRepository {
  Future<PagedResult<User>> getAll({int pageIndex = 1, int pageSize = 20, String? searchBy});
  Future<User?> getById(int id);
  Future<User> create({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
    UserProfile profile = const UserProfile(),
  });
  Future<User> update({
    required int id,
    required String name,
    required bool isActive,
    String? password,
    UserProfile? profile,
  });
  Future<void> deactivate(int id);

  /// A member's identity card image, or null when they have none.
  Future<Uint8List?> getIdentityImage(int userId, IdentitySide side);
  Future<void> setIdentityImage(int userId, IdentitySide side, UploadedFile file);
  Future<void> deleteIdentityImage(int userId, IdentitySide side);
}

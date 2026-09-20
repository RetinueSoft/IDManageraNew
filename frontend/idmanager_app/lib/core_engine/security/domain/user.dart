import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/enums.dart';
import 'user_profile.dart';

part 'user.freezed.dart';

@freezed
sealed class User with _$User {
  const factory User({
    required int id,
    required String name,
    required String phone,
    required UserRole role,
    required bool isActive,
    required int points,
    required DateTime createdAt,

    /// The member who created this one - only when the viewer may see them (a viewer
    /// never sees their own upline, see docs/member-hierarchy.md).
    int? parentId,
    String? parentName,
    UserRole? parentRole,

    /// The member's shop and identity proof details (all optional).
    @Default(UserProfile()) UserProfile profile,

    /// Whether their identity card images exist. The images are fetched separately.
    @Default(false) bool hasIdFront,
    @Default(false) bool hasIdBack,
  }) = _User;
}

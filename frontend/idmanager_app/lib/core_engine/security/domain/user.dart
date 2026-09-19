import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/enums.dart';

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
  }) = _User;
}

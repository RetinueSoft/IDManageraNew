import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core_engine/common/enums.dart';

part 'user_form_state.freezed.dart';

@freezed
sealed class UserFormState with _$UserFormState {
  const factory UserFormState({
    @Default('') String name,
    @Default('') String phone,
    @Default('') String password,
    @Default(true) bool isActive,
    @Default(UserRole.user) UserRole role,
    @Default(<String, String>{}) Map<String, String> errors,
    @Default(false) bool isSaving,
    @Default(false) bool isDirty,
  }) = _UserFormState;
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/common/validation_exception.dart';
import 'session_controller.dart';
import 'user_form_state.dart';
import 'user_list_controller.dart';

part 'user_form_controller.g.dart';

/// Backs the Add/Edit User screen. [userId] is null in Add mode.
@riverpod
class UserFormController extends _$UserFormController {
  @override
  Future<UserFormState> build(int? userId) async {
    if (userId == null) return const UserFormState();

    final user = await ref.watch(userServiceProvider).getUser(userId);
    if (user == null) return const UserFormState();

    return UserFormState(
      name: user.name,
      phone: user.phone,
      isActive: user.isActive,
      role: user.role,
    );
  }

  void updateFields(UserFormState Function(UserFormState current) update) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(update(current).copyWith(isDirty: true));
  }

  /// Returns true when the save succeeded.
  Future<bool> save() async {
    final current = state.value;
    if (current == null) return false;

    state = AsyncData(current.copyWith(isSaving: true, errors: const {}));
    final service = ref.read(userServiceProvider);
    final actingUserId = ref.read(sessionControllerProvider).value?.id ?? 0;

    try {
      if (userId == null) {
        await service.createUser(
          name: current.name,
          phone: current.phone,
          password: current.password,
          role: current.role,
        );
      } else {
        await service.updateUser(
          actingUserId: actingUserId,
          id: userId!,
          name: current.name,
          isActive: current.isActive,
          password: current.password.isEmpty ? null : current.password,
        );
      }

      state = AsyncData(current.copyWith(isSaving: false, isDirty: false));
      ref.invalidate(userListControllerProvider);
      return true;
    } on ValidationException catch (e) {
      state = AsyncData(current.copyWith(isSaving: false, errors: e.errors));
      return false;
    }
  }
}

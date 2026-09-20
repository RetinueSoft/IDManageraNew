import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../../core_engine/security/domain/user_profile.dart';
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

    final service = ref.watch(userServiceProvider);
    final user = await service.getUser(userId);
    if (user == null) return const UserFormState();

    // The identity pictures are fetched on their own (a member never carries them).
    Future<IdentityImageEdit> load(bool has, IdentitySide side) async =>
        IdentityImageEdit(
          existing: has ? await service.getIdentityImage(userId, side) : null,
        );

    return UserFormState(
      name: user.name,
      phone: user.phone,
      isActive: user.isActive,
      role: user.role,
      profile: user.profile,
      idFront: await load(user.hasIdFront, IdentitySide.front),
      idBack: await load(user.hasIdBack, IdentitySide.back),
    );
  }

  void updateFields(UserFormState Function(UserFormState current) update) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(update(current).copyWith(isDirty: true));
  }

  /// Chooses a picture for one side of the identity card; it is uploaded when the form is saved.
  void chooseImage(IdentitySide side, UploadedFile file) => updateFields(
    (s) => side == IdentitySide.front
        ? s.copyWith(idFront: s.idFront.copyWith(chosen: file, removed: false))
        : s.copyWith(idBack: s.idBack.copyWith(chosen: file, removed: false)),
  );

  /// Drops a side's picture: a newly chosen one is forgotten, a stored one is removed on Save.
  void removeImage(IdentitySide side) => updateFields(
    (s) => side == IdentitySide.front
        ? s.copyWith(
            idFront: IdentityImageEdit(
              existing: s.idFront.existing,
              removed: s.idFront.existing != null,
            ),
          )
        : s.copyWith(
            idBack: IdentityImageEdit(
              existing: s.idBack.existing,
              removed: s.idBack.existing != null,
            ),
          ),
  );

  /// Returns true when the save succeeded. A picture that then fails to upload does not undo the
  /// member (they are already saved): the save still counts and [UserFormState.warning] says which.
  Future<bool> save() async {
    final current = state.value;
    if (current == null) return false;

    state = AsyncData(
      current.copyWith(isSaving: true, errors: const {}, warning: null),
    );
    final service = ref.read(userServiceProvider);
    final actingUserId = ref.read(sessionControllerProvider).value?.id ?? 0;

    try {
      final int savedId;
      if (userId == null) {
        final created = await service.createUser(
          name: current.name,
          phone: current.phone,
          password: current.password,
          role: current.role,
          profile: current.profile,
        );
        savedId = created.id;
      } else {
        await service.updateUser(
          actingUserId: actingUserId,
          id: userId!,
          name: current.name,
          isActive: current.isActive,
          password: current.password.isEmpty ? null : current.password,
          profile: current.profile,
        );
        savedId = userId!;
      }

      final failed = <String>[];
      for (final (side, edit, label) in [
        (IdentitySide.front, current.idFront, 'front'),
        (IdentitySide.back, current.idBack, 'back'),
      ]) {
        try {
          if (edit.chosen != null) {
            await service.setIdentityImage(savedId, side, edit.chosen!);
          } else if (edit.removed) {
            await service.deleteIdentityImage(savedId, side);
          }
        } catch (_) {
          failed.add(label);
        }
      }

      state = AsyncData(
        current.copyWith(
          isSaving: false,
          isDirty: false,
          warning: failed.isEmpty
              ? null
              : 'Saved, but the ${failed.join(' and ')} ID picture could not be uploaded. Open the member to add it again.',
        ),
      );
      ref.invalidate(userListControllerProvider);
      return true;
    } on ValidationException catch (e) {
      state = AsyncData(current.copyWith(isSaving: false, errors: e.errors));
      return false;
    }
  }
}

import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core_engine/common/enums.dart';
import '../../core_engine/common/uploaded_file.dart';
import '../../core_engine/security/domain/user_profile.dart';

part 'user_form_state.freezed.dart';

/// One side of the identity card while the form is open: the picture that exists on the server
/// (if any), a new one chosen to be uploaded on Save, or a removal to be made on Save.
@freezed
sealed class IdentityImageEdit with _$IdentityImageEdit {
  const IdentityImageEdit._();

  const factory IdentityImageEdit({
    /// The picture already stored for the member (loaded when the form opens).
    Uint8List? existing,

    /// A newly chosen picture, uploaded when the form is saved.
    UploadedFile? chosen,

    /// The stored picture is to be removed when the form is saved.
    @Default(false) bool removed,
  }) = _IdentityImageEdit;

  /// What the form shows now.
  Uint8List? get shown => chosen?.bytes ?? (removed ? null : existing);
}

@freezed
sealed class UserFormState with _$UserFormState {
  const factory UserFormState({
    @Default('') String name,
    @Default('') String phone,
    @Default('') String password,
    @Default(true) bool isActive,
    @Default(UserRole.user) UserRole role,

    /// The optional shop and identity details.
    @Default(UserProfile()) UserProfile profile,
    @Default(IdentityImageEdit()) IdentityImageEdit idFront,
    @Default(IdentityImageEdit()) IdentityImageEdit idBack,
    @Default(<String, String>{}) Map<String, String> errors,
    @Default(false) bool isSaving,
    @Default(false) bool isDirty,

    /// Set after a save that worked except for a picture that could not be uploaded.
    String? warning,
  }) = _UserFormState;
}

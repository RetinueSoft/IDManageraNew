// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Backs the Add/Edit User screen. [userId] is null in Add mode.

@ProviderFor(UserFormController)
final userFormControllerProvider = UserFormControllerFamily._();

/// Backs the Add/Edit User screen. [userId] is null in Add mode.
final class UserFormControllerProvider
    extends $AsyncNotifierProvider<UserFormController, UserFormState> {
  /// Backs the Add/Edit User screen. [userId] is null in Add mode.
  UserFormControllerProvider._({
    required UserFormControllerFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'userFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userFormControllerHash();

  @override
  String toString() {
    return r'userFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UserFormController create() => UserFormController();

  @override
  bool operator ==(Object other) {
    return other is UserFormControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userFormControllerHash() =>
    r'9e57585f68d35ac50952860d8adb13a123535d5d';

/// Backs the Add/Edit User screen. [userId] is null in Add mode.

final class UserFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          UserFormController,
          AsyncValue<UserFormState>,
          UserFormState,
          FutureOr<UserFormState>,
          int?
        > {
  UserFormControllerFamily._()
    : super(
        retry: null,
        name: r'userFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Backs the Add/Edit User screen. [userId] is null in Add mode.

  UserFormControllerProvider call(int? userId) =>
      UserFormControllerProvider._(argument: userId, from: this);

  @override
  String toString() => r'userFormControllerProvider';
}

/// Backs the Add/Edit User screen. [userId] is null in Add mode.

abstract class _$UserFormController extends $AsyncNotifier<UserFormState> {
  late final _$args = ref.$arg as int?;
  int? get userId => _$args;

  FutureOr<UserFormState> build(int? userId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserFormState>, UserFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserFormState>, UserFormState>,
              AsyncValue<UserFormState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

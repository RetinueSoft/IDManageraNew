// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserListController)
final userListControllerProvider = UserListControllerProvider._();

final class UserListControllerProvider
    extends $AsyncNotifierProvider<UserListController, List<User>> {
  UserListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userListControllerHash();

  @$internal
  @override
  UserListController create() => UserListController();
}

String _$userListControllerHash() =>
    r'3ec7e581bd84e90141a7d51efcecb6d7f5c856cd';

abstract class _$UserListController extends $AsyncNotifier<List<User>> {
  FutureOr<List<User>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<User>>, List<User>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<User>>, List<User>>,
              AsyncValue<List<User>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

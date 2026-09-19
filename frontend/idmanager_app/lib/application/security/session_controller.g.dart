// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Who's currently logged in. Unlike a memory-only session, this app persists the
/// session (AuthService.restoreSession) so a returning user isn't dropped back to
/// the Login screen on every page refresh/app restart. `main.dart` gates the whole
/// app on this: loading means "still restoring", null means show the Login screen,
/// non-null means show the app shell.

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// Who's currently logged in. Unlike a memory-only session, this app persists the
/// session (AuthService.restoreSession) so a returning user isn't dropped back to
/// the Login screen on every page refresh/app restart. `main.dart` gates the whole
/// app on this: loading means "still restoring", null means show the Login screen,
/// non-null means show the app shell.
final class SessionControllerProvider
    extends $AsyncNotifierProvider<SessionController, User?> {
  /// Who's currently logged in. Unlike a memory-only session, this app persists the
  /// session (AuthService.restoreSession) so a returning user isn't dropped back to
  /// the Login screen on every page refresh/app restart. `main.dart` gates the whole
  /// app on this: loading means "still restoring", null means show the Login screen,
  /// non-null means show the app shell.
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();
}

String _$sessionControllerHash() => r'ad6e3f9985da61e88ff57e253bc54d6a327ba7b2';

/// Who's currently logged in. Unlike a memory-only session, this app persists the
/// session (AuthService.restoreSession) so a returning user isn't dropped back to
/// the Login screen on every page refresh/app restart. `main.dart` gates the whole
/// app on this: loading means "still restoring", null means show the Login screen,
/// non-null means show the app shell.

abstract class _$SessionController extends $AsyncNotifier<User?> {
  FutureOr<User?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<User?>, User?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<User?>, User?>,
              AsyncValue<User?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../business_service/providers.dart';
import '../../core_engine/security/domain/user.dart';

part 'session_controller.g.dart';

/// Who's currently logged in. Unlike a memory-only session, this app persists the
/// session (AuthService.restoreSession) so a returning user isn't dropped back to
/// the Login screen on every page refresh/app restart. `main.dart` gates the whole
/// app on this: loading means "still restoring", null means show the Login screen,
/// non-null means show the app shell.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  Future<User?> build() {
    final auth = ref.watch(authServiceProvider);
    // An expired/invalid saved token must send the user back to the login screen
    // instead of leaving every screen stuck on a 401 error.
    auth.onSessionExpired(() => state = const AsyncData(null));
    return auth.restoreSession();
  }

  Future<void> login(String phone, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(authServiceProvider).login(phone, password));
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = const AsyncData(null);
  }
}

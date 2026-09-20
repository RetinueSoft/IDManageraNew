import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/application/security/session_controller.dart';
import 'package:idmanager_app/core_engine/common/enums.dart';
import 'package:idmanager_app/core_engine/security/domain/user.dart';
import 'package:idmanager_app/presentation/routing/app_router.dart';
import 'package:idmanager_app/presentation/routing/app_routes.dart';

final _user = User(
  id: 1,
  name: 'Retailer',
  phone: '9000000000',
  role: UserRole.retailer,
  isActive: true,
  points: 10,
  createdAt: DateTime(2024),
);

class _FakeSession extends SessionController {
  @override
  Future<User?> build() async => _user;
}

String locationOf(ProviderContainer container) =>
    container.read(appRouterProvider).routeInformationProvider.value.uri.path;

void main() {
  test('a user who has just logged in lands on Generate Card, not the dashboard', () async {
    final container = ProviderContainer(overrides: [sessionControllerProvider.overrideWith(_FakeSession.new)]);
    addTearDown(container.dispose);
    await container.read(sessionControllerProvider.future);

    expect(locationOf(container), AppRoutes.generateCard);
    expect(AppRoutes.home, AppRoutes.generateCard);
  });

  test('each new login starts on Generate Card again, wherever the last session ended', () async {
    final container = ProviderContainer(overrides: [sessionControllerProvider.overrideWith(_FakeSession.new)]);
    addTearDown(container.dispose);
    await container.read(sessionControllerProvider.future);

    // Keep the router alive like the running app does, and move somewhere else.
    container.listen(appRouterProvider, (_, _) {});
    container.read(appRouterProvider).go(AppRoutes.points);
    expect(locationOf(container), AppRoutes.points);

    final session = container.read(sessionControllerProvider.notifier);
    session.state = const AsyncData(null);
    await Future<void>.delayed(Duration.zero);
    session.state = AsyncData(_user);
    await Future<void>.delayed(Duration.zero);

    expect(locationOf(container), AppRoutes.generateCard);
  });

  test('a change to the signed-in session that is not a login or logout does not reset the page', () async {
    final container = ProviderContainer(overrides: [sessionControllerProvider.overrideWith(_FakeSession.new)]);
    addTearDown(container.dispose);
    await container.read(sessionControllerProvider.future);
    container.listen(appRouterProvider, (_, _) {});
    container.read(appRouterProvider).go(AppRoutes.points);

    // e.g. the user's points balance being refreshed
    container.read(sessionControllerProvider.notifier).state = AsyncData(_user.copyWith(points: 99));
    await Future<void>.delayed(Duration.zero);

    expect(locationOf(container), AppRoutes.points);
  });
}

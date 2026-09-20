import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/application/security/session_controller.dart';
import 'package:idmanager_app/application/security/user_form_controller.dart';
import 'package:idmanager_app/business_service/providers.dart';
import 'package:idmanager_app/business_service/security/user_service.dart';
import 'package:idmanager_app/core_engine/common/enums.dart';
import 'package:idmanager_app/core_engine/security/domain/user.dart';
import 'package:idmanager_app/core_engine/security/domain/user_profile.dart';
import 'package:idmanager_app/presentation/users/manage_user_screen.dart';

final _me = User(
  id: 1,
  name: 'Admin',
  phone: '9999999999',
  role: UserRole.superAdmin,
  isActive: true,
  points: 0,
  createdAt: DateTime(2024),
);

class _FakeSession extends SessionController {
  @override
  Future<User?> build() async => _me;
}

class _FakeUsers implements UserService {
  _FakeUsers([this.existing]);

  final User? existing;

  @override
  Future<User?> getUser(int id) async => existing;

  @override
  Future<Uint8List?> getIdentityImage(int userId, IdentitySide side) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<ProviderContainer> pump(WidgetTester tester, {int? userId, User? existing}) async {
  tester.view.physicalSize = const Size(1200, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userServiceProvider.overrideWithValue(_FakeUsers(existing)),
        sessionControllerProvider.overrideWith(_FakeSession.new),
      ],
      child: MaterialApp(home: ManageUserScreen(userId: userId)),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(ManageUserScreen)));
}

void main() {
  testWidgets('adding a member offers the shop and identity details, all marked optional', (tester) async {
    await pump(tester);

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Shop details (optional)'), findsOneWidget);
    expect(find.text('Identity proof (optional)'), findsOneWidget);
    for (final label in ['Shop name', 'Shop address', 'City', 'Pincode', 'ID type', 'ID number']) {
      expect(find.widgetWithText(InputDecorator, label), findsOneWidget, reason: label);
    }
    expect(find.text('Front of the ID card'), findsOneWidget);
    expect(find.text('Back of the ID card'), findsOneWidget);
    expect(find.text('Choose Front'), findsOneWidget);
    expect(find.text('Choose Back'), findsOneWidget);
  });

  testWidgets('typing the details fills the form', (tester) async {
    final container = await pump(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Shop name'), 'Sri Murugan Stores');
    await tester.enterText(find.widgetWithText(TextField, 'Shop address'), '12 Main Road');
    await tester.enterText(find.widgetWithText(TextField, 'City'), 'Coimbatore');
    await tester.enterText(find.widgetWithText(TextField, 'Pincode'), '641001');
    await tester.enterText(find.widgetWithText(TextField, 'ID number'), '1234 5678');

    final profile = container.read(userFormControllerProvider(null)).value!.profile;
    expect(profile.shopName, 'Sri Murugan Stores');
    expect(profile.shopAddress, '12 Main Road');
    expect(profile.city, 'Coimbatore');
    expect(profile.pincode, '641001');
    expect(profile.idNumber, '1234 5678');
  });

  testWidgets('the ID type is chosen from a list', (tester) async {
    final container = await pump(tester);

    await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'ID type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voter ID').last);
    await tester.pumpAndSettle();

    expect(container.read(userFormControllerProvider(null)).value!.profile.idType, 'Voter ID');
  });

  testWidgets('editing a member shows the details they already have', (tester) async {
    final member = User(
      id: 7,
      name: 'Meena',
      phone: '9000000007',
      role: UserRole.retailer,
      isActive: true,
      points: 0,
      createdAt: DateTime(2024),
      profile: const UserProfile(shopName: 'Old shop', shopAddress: '5 Lake View', city: 'Salem', pincode: '636001', idType: 'PAN', idNumber: 'ABCDE1234F'),
    );
    await pump(tester, userId: 7, existing: member);

    expect(find.widgetWithText(TextField, 'Old shop'), findsOneWidget);
    expect(find.widgetWithText(TextField, '5 Lake View'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Salem'), findsOneWidget);
    expect(find.widgetWithText(TextField, '636001'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'ABCDE1234F'), findsOneWidget);
    expect(find.text('PAN'), findsWidgets);
  });

  testWidgets('a saved ID type that is not in the list still shows', (tester) async {
    final member = User(
      id: 7,
      name: 'Meena',
      phone: '9000000007',
      role: UserRole.retailer,
      isActive: true,
      points: 0,
      createdAt: DateTime(2024),
      profile: const UserProfile(idType: 'Senior citizen card'),
    );
    await pump(tester, userId: 7, existing: member);

    expect(find.text('Senior citizen card'), findsWidgets);
  });
}

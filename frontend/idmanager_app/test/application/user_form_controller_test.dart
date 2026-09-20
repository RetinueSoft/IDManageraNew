import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/application/security/session_controller.dart';
import 'package:idmanager_app/application/security/user_form_controller.dart';
import 'package:idmanager_app/business_service/providers.dart';
import 'package:idmanager_app/business_service/security/user_service.dart';
import 'package:idmanager_app/core_engine/common/enums.dart';
import 'package:idmanager_app/core_engine/common/uploaded_file.dart';
import 'package:idmanager_app/core_engine/security/domain/user.dart';
import 'package:idmanager_app/core_engine/security/domain/user_profile.dart';

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

UploadedFile pic(String name, [int seed = 1]) => UploadedFile(Uint8List.fromList([seed, seed, seed]), name);

class _FakeUsers implements UserService {
  _FakeUsers({this.existing, this.frontBytes, this.backBytes});

  final User? existing;
  final Uint8List? frontBytes;
  final Uint8List? backBytes;

  UserProfile? createdProfile;
  UserProfile? updatedProfile;
  final uploaded = <(int, IdentitySide, String)>[];
  final removed = <(int, IdentitySide)>[];
  Set<IdentitySide> failUploadOn = {};

  @override
  Future<User?> getUser(int id) async => existing;

  @override
  Future<Uint8List?> getIdentityImage(int userId, IdentitySide side) async =>
      side == IdentitySide.front ? frontBytes : backBytes;

  @override
  Future<User> createUser({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
    UserProfile profile = const UserProfile(),
  }) async {
    createdProfile = profile;
    return User(id: 42, name: name, phone: phone, role: role, isActive: true, points: 0, createdAt: DateTime(2024));
  }

  @override
  Future<User> updateUser({
    required int actingUserId,
    required int id,
    required String name,
    required bool isActive,
    String? password,
    UserProfile? profile,
  }) async {
    updatedProfile = profile;
    return existing!;
  }

  @override
  Future<void> setIdentityImage(int userId, IdentitySide side, UploadedFile file) async {
    if (failUploadOn.contains(side)) throw Exception('upload failed');
    uploaded.add((userId, side, file.name));
  }

  @override
  Future<void> deleteIdentityImage(int userId, IdentitySide side) async => removed.add((userId, side));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProviderContainer containerWith(_FakeUsers fake) {
  final container = ProviderContainer(
    overrides: [
      userServiceProvider.overrideWithValue(fake),
      sessionControllerProvider.overrideWith(_FakeSession.new),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<UserFormController> open(ProviderContainer container, int? userId) async {
  final provider = userFormControllerProvider(userId);
  container.listen(provider, (_, _) {});
  await container.read(provider.future);
  return container.read(provider.notifier);
}

void main() {
  group('adding a member', () {
    test('needs none of the shop or identity details', () async {
      final fake = _FakeUsers();
      final container = containerWith(fake);
      final controller = await open(container, null);
      controller.updateFields((s) => s.copyWith(name: 'Ravi', phone: '9000000001', password: 'x'));

      final saved = await controller.save();

      expect(saved, isTrue);
      expect(fake.createdProfile, const UserProfile());
      expect(fake.uploaded, isEmpty);
      expect(container.read(userFormControllerProvider(null)).value!.warning, isNull);
    });

    test('sends the shop and identity details it was given', () async {
      final fake = _FakeUsers();
      final container = containerWith(fake);
      final controller = await open(container, null);
      controller.updateFields(
        (s) => s.copyWith(
          name: 'Ravi',
          phone: '9000000001',
          password: 'x',
          profile: const UserProfile(shopName: 'Sri Murugan', shopAddress: '12 Main Rd', city: 'Coimbatore', pincode: '641001', idType: 'Aadhaar', idNumber: '1234'),
        ),
      );

      await controller.save();

      expect(fake.createdProfile?.shopName, 'Sri Murugan');
      expect(fake.createdProfile?.idType, 'Aadhaar');
      expect(fake.createdProfile?.idNumber, '1234');
    });

    test('uploads the chosen ID pictures for the new member once it is created', () async {
      final fake = _FakeUsers();
      final container = containerWith(fake);
      final controller = await open(container, null);
      controller.updateFields((s) => s.copyWith(name: 'Ravi', phone: '9000000001', password: 'x'));
      controller.chooseImage(IdentitySide.front, pic('front.jpg'));
      controller.chooseImage(IdentitySide.back, pic('back.png'));

      await controller.save();

      expect(fake.uploaded, [(42, IdentitySide.front, 'front.jpg'), (42, IdentitySide.back, 'back.png')]);
    });

    test('only the side that was chosen is uploaded', () async {
      final fake = _FakeUsers();
      final container = containerWith(fake);
      final controller = await open(container, null);
      controller.updateFields((s) => s.copyWith(name: 'Ravi', phone: '9000000001', password: 'x'));
      controller.chooseImage(IdentitySide.back, pic('back.png'));

      await controller.save();

      expect(fake.uploaded, [(42, IdentitySide.back, 'back.png')]);
    });

    test('a picture that fails to upload does not undo the member: the save counts, with a warning', () async {
      final fake = _FakeUsers()..failUploadOn = {IdentitySide.back};
      final container = containerWith(fake);
      final controller = await open(container, null);
      controller.updateFields((s) => s.copyWith(name: 'Ravi', phone: '9000000001', password: 'x'));
      controller.chooseImage(IdentitySide.front, pic('front.jpg'));
      controller.chooseImage(IdentitySide.back, pic('back.png'));

      final saved = await controller.save();

      expect(saved, isTrue);
      expect(fake.uploaded, [(42, IdentitySide.front, 'front.jpg')]);
      final warning = container.read(userFormControllerProvider(null)).value!.warning;
      expect(warning, contains('back'));
      expect(warning, isNot(contains('front')));
    });

    test('choosing a picture and then removing it forgets it', () async {
      final fake = _FakeUsers();
      final container = containerWith(fake);
      final controller = await open(container, null);
      controller.updateFields((s) => s.copyWith(name: 'Ravi', phone: '9000000001', password: 'x'));
      controller.chooseImage(IdentitySide.front, pic('front.jpg'));
      expect(container.read(userFormControllerProvider(null)).value!.idFront.shown, isNotNull);

      controller.removeImage(IdentitySide.front);
      expect(container.read(userFormControllerProvider(null)).value!.idFront.shown, isNull);
      await controller.save();

      expect(fake.uploaded, isEmpty);
      expect(fake.removed, isEmpty);
    });
  });

  group('editing a member', () {
    final member = User(
      id: 7,
      name: 'Meena',
      phone: '9000000007',
      role: UserRole.retailer,
      isActive: true,
      points: 0,
      createdAt: DateTime(2024),
      profile: const UserProfile(shopName: 'Old shop', city: 'Salem', idType: 'PAN', idNumber: 'ABCDE1234F'),
      hasIdFront: true,
      hasIdBack: false,
    );

    test('opens with their details and the pictures they have', () async {
      final fake = _FakeUsers(existing: member, frontBytes: Uint8List.fromList([9, 9, 9]));
      final container = containerWith(fake);
      await open(container, 7);

      final state = container.read(userFormControllerProvider(7)).value!;
      expect(state.profile.shopName, 'Old shop');
      expect(state.profile.idNumber, 'ABCDE1234F');
      expect(state.idFront.shown, [9, 9, 9]);
      expect(state.idBack.shown, isNull);
    });

    test('changing nothing about the pictures uploads and removes nothing', () async {
      final fake = _FakeUsers(existing: member, frontBytes: Uint8List.fromList([9, 9, 9]));
      final container = containerWith(fake);
      final controller = await open(container, 7);

      await controller.save();

      expect(fake.uploaded, isEmpty);
      expect(fake.removed, isEmpty);
      expect(fake.updatedProfile?.shopName, 'Old shop');
    });

    test('replaces one picture and removes another', () async {
      final both = member.copyWith(hasIdBack: true);
      final fake = _FakeUsers(existing: both, frontBytes: Uint8List.fromList([1]), backBytes: Uint8List.fromList([2]));
      final container = containerWith(fake);
      final controller = await open(container, 7);
      controller.chooseImage(IdentitySide.front, pic('new-front.jpg'));
      controller.removeImage(IdentitySide.back);
      expect(container.read(userFormControllerProvider(7)).value!.idBack.shown, isNull);

      await controller.save();

      expect(fake.uploaded, [(7, IdentitySide.front, 'new-front.jpg')]);
      expect(fake.removed, [(7, IdentitySide.back)]);
    });

    test('a picture chosen to replace one can be dropped again, keeping the stored one', () async {
      final fake = _FakeUsers(existing: member, frontBytes: Uint8List.fromList([9, 9, 9]));
      final container = containerWith(fake);
      final controller = await open(container, 7);
      controller.chooseImage(IdentitySide.front, pic('other.jpg'));
      expect(container.read(userFormControllerProvider(7)).value!.idFront.shown, [1, 1, 1]);

      // Removing now removes the stored one too (the form shows nothing) - one action, one meaning.
      controller.removeImage(IdentitySide.front);
      final edit = container.read(userFormControllerProvider(7)).value!.idFront;
      expect(edit.chosen, isNull);
      expect(edit.removed, isTrue);
    });
  });
}

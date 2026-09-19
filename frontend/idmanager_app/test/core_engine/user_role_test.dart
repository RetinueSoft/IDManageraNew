import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/core_engine/common/enums.dart';

/// docs/member-hierarchy.md, sections 1 and 2.
void main() {
  group('UserRole wire values match the backend', () {
    test('round-trips every role (2 was the removed Admin role)', () {
      for (final role in UserRole.values) {
        expect(UserRole.fromInt(role.toInt()), role);
      }
      expect(UserRole.superAdmin.toInt(), 1);
      expect(UserRole.distributor.toInt(), 3);
      expect(UserRole.user.toInt(), 4);
      expect(UserRole.retailer.toInt(), 5);
      expect(UserRole.fromInt(2), UserRole.unknown);
    });
  });

  group('creatableRoles', () {
    test('SuperAdmin and Distributor can add Distributor, Retailer and User', () {
      const expected = [UserRole.distributor, UserRole.retailer, UserRole.user];
      expect(UserRole.superAdmin.creatableRoles, expected);
      expect(UserRole.distributor.creatableRoles, expected);
    });

    test('a Retailer can add only Retailer and User', () {
      expect(UserRole.retailer.creatableRoles, [UserRole.retailer, UserRole.user]);
    });

    test('a User cannot add anyone, so has no member screens', () {
      expect(UserRole.user.creatableRoles, isEmpty);
      expect(UserRole.user.canManageMembers, isFalse);
      expect(UserRole.unknown.canManageMembers, isFalse);
    });

    test('nobody can add a SuperAdmin', () {
      for (final role in UserRole.values) {
        expect(role.creatableRoles, isNot(contains(UserRole.superAdmin)));
      }
    });
  });
}

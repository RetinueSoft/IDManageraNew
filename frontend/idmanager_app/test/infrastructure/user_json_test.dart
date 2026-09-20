import 'package:flutter_test/flutter_test.dart';
import 'package:idmanager_app/business_service/security/user_json.dart' as session;
import 'package:idmanager_app/core_engine/common/enums.dart';
import 'package:idmanager_app/core_engine/security/domain/user_profile.dart';
import 'package:idmanager_app/infrastructure/repositories/api_auth_repository.dart' show userFromJson;

Map<String, dynamic> base() => {
  'id': 5,
  'name': 'Meena',
  'phone': '9000000005',
  'role': 5,
  'isActive': true,
  'points': 3,
  'createdAt': '2024-05-01T10:00:00Z',
};

void main() {
  test('a member without any details has empty ones and no pictures', () {
    final user = userFromJson(base());

    expect(user.profile, const UserProfile());
    expect(user.hasIdFront, isFalse);
    expect(user.hasIdBack, isFalse);
  });

  test('the shop and identity details are read, and null ones become empty', () {
    final user = userFromJson({
      ...base(),
      'shopName': 'Sri Murugan',
      'shopAddress': '12 Main Rd\nCoimbatore',
      'city': null,
      'pincode': '641001',
      'idType': 'Aadhaar',
      'idNumber': '1234',
      'hasIdFront': true,
    });

    expect(user.profile.shopName, 'Sri Murugan');
    expect(user.profile.shopAddress, '12 Main Rd\nCoimbatore');
    expect(user.profile.city, '');
    expect(user.profile.pincode, '641001');
    expect(user.profile.idType, 'Aadhaar');
    expect(user.profile.idNumber, '1234');
    expect(user.hasIdFront, isTrue);
    expect(user.hasIdBack, isFalse);
    expect(user.role, UserRole.retailer);
  });

  test('the saved session keeps the details (round trip)', () {
    final user = userFromJson({...base(), 'shopName': 'Sri Murugan', 'idType': 'PAN', 'hasIdBack': true});

    final again = session.userFromJson(session.userToJson(user));

    expect(again.profile, user.profile);
    expect(again.hasIdBack, isTrue);
    expect(again.hasIdFront, isFalse);
  });

  test('the profile is sent with the API field names', () {
    final json = session.userProfileToJson(const UserProfile(shopName: 'A', shopAddress: 'B', city: 'C', pincode: 'D', idType: 'E', idNumber: 'F'));

    expect(json, {'shopName': 'A', 'shopAddress': 'B', 'city': 'C', 'pincode': 'D', 'idType': 'E', 'idNumber': 'F'});
  });

  test('identity types offered include the common Indian ones', () {
    expect(identityTypes, containsAll(['Aadhaar', 'Voter ID', 'PAN', 'Driving licence']));
  });
}

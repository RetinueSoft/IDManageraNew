import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

/// The optional details of a member: their shop and their identity proof. Every field is optional -
/// an empty string means "not given".
@freezed
sealed class UserProfile with _$UserProfile {
  const factory UserProfile({
    @Default('') String shopName,
    @Default('') String shopAddress,
    @Default('') String city,
    @Default('') String pincode,

    /// What kind of identity card it is (see [identityTypes]) and its number.
    @Default('') String idType,
    @Default('') String idNumber,
  }) = _UserProfile;
}

/// The kinds of identity card offered when picking an ID type.
const identityTypes = ['Aadhaar', 'Voter ID', 'PAN', 'Driving licence', 'Passport', 'Ration card', 'Other'];

/// Which side of the identity card an image is.
enum IdentitySide {
  front,
  back;

  /// How the backend names it in a URL.
  String get wireName => name;
}

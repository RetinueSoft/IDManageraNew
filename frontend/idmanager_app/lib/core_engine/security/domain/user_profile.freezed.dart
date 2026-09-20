// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserProfile {

 String get shopName; String get shopAddress; String get city; String get pincode;/// What kind of identity card it is (see [identityTypes]) and its number.
 String get idType; String get idNumber;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.shopName, _this.shopName) || other.shopName == _this.shopName)&&(identical(other.shopAddress, _this.shopAddress) || other.shopAddress == _this.shopAddress)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.pincode, _this.pincode) || other.pincode == _this.pincode)&&(identical(other.idType, _this.idType) || other.idType == _this.idType)&&(identical(other.idNumber, _this.idNumber) || other.idNumber == _this.idNumber));
}


@override
int get hashCode {
  final _this = this as UserProfile;
  return Object.hash(runtimeType,_this.shopName,_this.shopAddress,_this.city,_this.pincode,_this.idType,_this.idNumber);
}

@override
String toString() {
  final _this = this as UserProfile;
  return 'UserProfile(shopName: ${_this.shopName}, shopAddress: ${_this.shopAddress}, city: ${_this.city}, pincode: ${_this.pincode}, idType: ${_this.idType}, idNumber: ${_this.idNumber})';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String shopName, String shopAddress, String city, String pincode, String idType, String idNumber
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shopName = null,Object? shopAddress = null,Object? city = null,Object? pincode = null,Object? idType = null,Object? idNumber = null,}) {
  return _then(UserProfile(
shopName: null == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String,shopAddress: null == shopAddress ? _self.shopAddress : shopAddress // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,pincode: null == pincode ? _self.pincode : pincode // ignore: cast_nullable_to_non_nullable
as String,idType: null == idType ? _self.idType : idType // ignore: cast_nullable_to_non_nullable
as String,idNumber: null == idNumber ? _self.idNumber : idNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String shopName,  String shopAddress,  String city,  String pincode,  String idType,  String idNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.shopName,_that.shopAddress,_that.city,_that.pincode,_that.idType,_that.idNumber);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String shopName,  String shopAddress,  String city,  String pincode,  String idType,  String idNumber)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.shopName,_that.shopAddress,_that.city,_that.pincode,_that.idType,_that.idNumber);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String shopName,  String shopAddress,  String city,  String pincode,  String idType,  String idNumber)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.shopName,_that.shopAddress,_that.city,_that.pincode,_that.idType,_that.idNumber);case _:
  return null;

}
}

}

/// @nodoc


class _UserProfile implements UserProfile {
  const _UserProfile({this.shopName = '', this.shopAddress = '', this.city = '', this.pincode = '', this.idType = '', this.idNumber = ''});
  

@override@JsonKey() final  String shopName;
@override@JsonKey() final  String shopAddress;
@override@JsonKey() final  String city;
@override@JsonKey() final  String pincode;
/// What kind of identity card it is (see [identityTypes]) and its number.
@override@JsonKey() final  String idType;
@override@JsonKey() final  String idNumber;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.shopName, shopName) || other.shopName == shopName)&&(identical(other.shopAddress, shopAddress) || other.shopAddress == shopAddress)&&(identical(other.city, city) || other.city == city)&&(identical(other.pincode, pincode) || other.pincode == pincode)&&(identical(other.idType, idType) || other.idType == idType)&&(identical(other.idNumber, idNumber) || other.idNumber == idNumber));
}


@override
int get hashCode {
    return Object.hash(runtimeType,shopName,shopAddress,city,pincode,idType,idNumber);
}

@override
String toString() {
    return 'UserProfile(shopName: $shopName, shopAddress: $shopAddress, city: $city, pincode: $pincode, idType: $idType, idNumber: $idNumber)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String shopName, String shopAddress, String city, String pincode, String idType, String idNumber
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shopName = null,Object? shopAddress = null,Object? city = null,Object? pincode = null,Object? idType = null,Object? idNumber = null,}) {
  return _then(_UserProfile(
shopName: null == shopName ? _self.shopName : shopName // ignore: cast_nullable_to_non_nullable
as String,shopAddress: null == shopAddress ? _self.shopAddress : shopAddress // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,pincode: null == pincode ? _self.pincode : pincode // ignore: cast_nullable_to_non_nullable
as String,idType: null == idType ? _self.idType : idType // ignore: cast_nullable_to_non_nullable
as String,idNumber: null == idNumber ? _self.idNumber : idNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

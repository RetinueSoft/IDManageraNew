// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserFormState {

 String get name; String get phone; String get password; bool get isActive; UserRole get role; Map<String, String> get errors; bool get isSaving; bool get isDirty;
/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFormStateCopyWith<UserFormState> get copyWith => _$UserFormStateCopyWithImpl<UserFormState>(this as UserFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFormState&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.role, _this.role) || other.role == _this.role)&&const DeepCollectionEquality().equals(other.errors, _this.errors)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving)&&(identical(other.isDirty, _this.isDirty) || other.isDirty == _this.isDirty));
}


@override
int get hashCode {
  final _this = this as UserFormState;
  return Object.hash(runtimeType,_this.name,_this.phone,_this.password,_this.isActive,_this.role,const DeepCollectionEquality().hash(_this.errors),_this.isSaving,_this.isDirty);
}

@override
String toString() {
  final _this = this as UserFormState;
  return 'UserFormState(name: ${_this.name}, phone: ${_this.phone}, password: ${_this.password}, isActive: ${_this.isActive}, role: ${_this.role}, errors: ${_this.errors}, isSaving: ${_this.isSaving}, isDirty: ${_this.isDirty})';
}


}

/// @nodoc
abstract mixin class $UserFormStateCopyWith<$Res>  {
  factory $UserFormStateCopyWith(UserFormState value, $Res Function(UserFormState) _then) = _$UserFormStateCopyWithImpl;
@useResult
$Res call({
 String name, String phone, String password, bool isActive, UserRole role, Map<String, String> errors, bool isSaving, bool isDirty
});




}
/// @nodoc
class _$UserFormStateCopyWithImpl<$Res>
    implements $UserFormStateCopyWith<$Res> {
  _$UserFormStateCopyWithImpl(this._self, this._then);

  final UserFormState _self;
  final $Res Function(UserFormState) _then;

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? phone = null,Object? password = null,Object? isActive = null,Object? role = null,Object? errors = null,Object? isSaving = null,Object? isDirty = null,}) {
  return _then(UserFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserFormState].
extension UserFormStatePatterns on UserFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserFormState value)  $default,){
final _that = this;
switch (_that) {
case _UserFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserFormState value)?  $default,){
final _that = this;
switch (_that) {
case _UserFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String phone,  String password,  bool isActive,  UserRole role,  Map<String, String> errors,  bool isSaving,  bool isDirty)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserFormState() when $default != null:
return $default(_that.name,_that.phone,_that.password,_that.isActive,_that.role,_that.errors,_that.isSaving,_that.isDirty);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String phone,  String password,  bool isActive,  UserRole role,  Map<String, String> errors,  bool isSaving,  bool isDirty)  $default,) {final _that = this;
switch (_that) {
case _UserFormState():
return $default(_that.name,_that.phone,_that.password,_that.isActive,_that.role,_that.errors,_that.isSaving,_that.isDirty);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String phone,  String password,  bool isActive,  UserRole role,  Map<String, String> errors,  bool isSaving,  bool isDirty)?  $default,) {final _that = this;
switch (_that) {
case _UserFormState() when $default != null:
return $default(_that.name,_that.phone,_that.password,_that.isActive,_that.role,_that.errors,_that.isSaving,_that.isDirty);case _:
  return null;

}
}

}

/// @nodoc


class _UserFormState implements UserFormState {
  const _UserFormState({this.name = '', this.phone = '', this.password = '', this.isActive = true, this.role = UserRole.user,  Map<String, String> errors = const <String, String>{}, this.isSaving = false, this.isDirty = false}): _errors = errors;
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String password;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  UserRole role;
 final  Map<String, String> _errors;
@override@JsonKey() Map<String, String> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}

@override@JsonKey() final  bool isSaving;
@override@JsonKey() final  bool isDirty;

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFormStateCopyWith<_UserFormState> get copyWith => __$UserFormStateCopyWithImpl<_UserFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.password, password) || other.password == password)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other.errors, _errors)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,phone,password,isActive,role,const DeepCollectionEquality().hash(_errors),isSaving,isDirty);
}

@override
String toString() {
    return 'UserFormState(name: $name, phone: $phone, password: $password, isActive: $isActive, role: $role, errors: $errors, isSaving: $isSaving, isDirty: $isDirty)';
}


}

/// @nodoc
abstract mixin class _$UserFormStateCopyWith<$Res> implements $UserFormStateCopyWith<$Res> {
  factory _$UserFormStateCopyWith(_UserFormState value, $Res Function(_UserFormState) _then) = __$UserFormStateCopyWithImpl;
@override @useResult
$Res call({
 String name, String phone, String password, bool isActive, UserRole role, Map<String, String> errors, bool isSaving, bool isDirty
});




}
/// @nodoc
class __$UserFormStateCopyWithImpl<$Res>
    implements _$UserFormStateCopyWith<$Res> {
  __$UserFormStateCopyWithImpl(this._self, this._then);

  final _UserFormState _self;
  final $Res Function(_UserFormState) _then;

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? phone = null,Object? password = null,Object? isActive = null,Object? role = null,Object? errors = null,Object? isSaving = null,Object? isDirty = null,}) {
  return _then(_UserFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

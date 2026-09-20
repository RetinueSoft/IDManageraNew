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
mixin _$IdentityImageEdit {

/// The picture already stored for the member (loaded when the form opens).
 Uint8List? get existing;/// A newly chosen picture, uploaded when the form is saved.
 UploadedFile? get chosen;/// The stored picture is to be removed when the form is saved.
 bool get removed;
/// Create a copy of IdentityImageEdit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdentityImageEditCopyWith<IdentityImageEdit> get copyWith => _$IdentityImageEditCopyWithImpl<IdentityImageEdit>(this as IdentityImageEdit, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as IdentityImageEdit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdentityImageEdit&&const DeepCollectionEquality().equals(other.existing, _this.existing)&&(identical(other.chosen, _this.chosen) || other.chosen == _this.chosen)&&(identical(other.removed, _this.removed) || other.removed == _this.removed));
}


@override
int get hashCode {
  final _this = this as IdentityImageEdit;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.existing),_this.chosen,_this.removed);
}

@override
String toString() {
  final _this = this as IdentityImageEdit;
  return 'IdentityImageEdit(existing: ${_this.existing}, chosen: ${_this.chosen}, removed: ${_this.removed})';
}


}

/// @nodoc
abstract mixin class $IdentityImageEditCopyWith<$Res>  {
  factory $IdentityImageEditCopyWith(IdentityImageEdit value, $Res Function(IdentityImageEdit) _then) = _$IdentityImageEditCopyWithImpl;
@useResult
$Res call({
 Uint8List? existing, UploadedFile? chosen, bool removed
});




}
/// @nodoc
class _$IdentityImageEditCopyWithImpl<$Res>
    implements $IdentityImageEditCopyWith<$Res> {
  _$IdentityImageEditCopyWithImpl(this._self, this._then);

  final IdentityImageEdit _self;
  final $Res Function(IdentityImageEdit) _then;

/// Create a copy of IdentityImageEdit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? existing = freezed,Object? chosen = freezed,Object? removed = null,}) {
  return _then(IdentityImageEdit(
existing: freezed == existing ? _self.existing : existing // ignore: cast_nullable_to_non_nullable
as Uint8List?,chosen: freezed == chosen ? _self.chosen : chosen // ignore: cast_nullable_to_non_nullable
as UploadedFile?,removed: null == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [IdentityImageEdit].
extension IdentityImageEditPatterns on IdentityImageEdit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdentityImageEdit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdentityImageEdit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdentityImageEdit value)  $default,){
final _that = this;
switch (_that) {
case _IdentityImageEdit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdentityImageEdit value)?  $default,){
final _that = this;
switch (_that) {
case _IdentityImageEdit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Uint8List? existing,  UploadedFile? chosen,  bool removed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdentityImageEdit() when $default != null:
return $default(_that.existing,_that.chosen,_that.removed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Uint8List? existing,  UploadedFile? chosen,  bool removed)  $default,) {final _that = this;
switch (_that) {
case _IdentityImageEdit():
return $default(_that.existing,_that.chosen,_that.removed);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Uint8List? existing,  UploadedFile? chosen,  bool removed)?  $default,) {final _that = this;
switch (_that) {
case _IdentityImageEdit() when $default != null:
return $default(_that.existing,_that.chosen,_that.removed);case _:
  return null;

}
}

}

/// @nodoc


class _IdentityImageEdit extends IdentityImageEdit {
  const _IdentityImageEdit({this.existing, this.chosen, this.removed = false}): super._();
  

/// The picture already stored for the member (loaded when the form opens).
@override final  Uint8List? existing;
/// A newly chosen picture, uploaded when the form is saved.
@override final  UploadedFile? chosen;
/// The stored picture is to be removed when the form is saved.
@override@JsonKey() final  bool removed;

/// Create a copy of IdentityImageEdit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdentityImageEditCopyWith<_IdentityImageEdit> get copyWith => __$IdentityImageEditCopyWithImpl<_IdentityImageEdit>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdentityImageEdit&&const DeepCollectionEquality().equals(other.existing, existing)&&(identical(other.chosen, chosen) || other.chosen == chosen)&&(identical(other.removed, removed) || other.removed == removed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(existing),chosen,removed);
}

@override
String toString() {
    return 'IdentityImageEdit(existing: $existing, chosen: $chosen, removed: $removed)';
}


}

/// @nodoc
abstract mixin class _$IdentityImageEditCopyWith<$Res> implements $IdentityImageEditCopyWith<$Res> {
  factory _$IdentityImageEditCopyWith(_IdentityImageEdit value, $Res Function(_IdentityImageEdit) _then) = __$IdentityImageEditCopyWithImpl;
@override @useResult
$Res call({
 Uint8List? existing, UploadedFile? chosen, bool removed
});




}
/// @nodoc
class __$IdentityImageEditCopyWithImpl<$Res>
    implements _$IdentityImageEditCopyWith<$Res> {
  __$IdentityImageEditCopyWithImpl(this._self, this._then);

  final _IdentityImageEdit _self;
  final $Res Function(_IdentityImageEdit) _then;

/// Create a copy of IdentityImageEdit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? existing = freezed,Object? chosen = freezed,Object? removed = null,}) {
  return _then(_IdentityImageEdit(
existing: freezed == existing ? _self.existing : existing // ignore: cast_nullable_to_non_nullable
as Uint8List?,chosen: freezed == chosen ? _self.chosen : chosen // ignore: cast_nullable_to_non_nullable
as UploadedFile?,removed: null == removed ? _self.removed : removed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$UserFormState {

 String get name; String get phone; String get password; bool get isActive; UserRole get role;/// The optional shop and identity details.
 UserProfile get profile; IdentityImageEdit get idFront; IdentityImageEdit get idBack; Map<String, String> get errors; bool get isSaving; bool get isDirty;/// Set after a save that worked except for a picture that could not be uploaded.
 String? get warning;
/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserFormStateCopyWith<UserFormState> get copyWith => _$UserFormStateCopyWithImpl<UserFormState>(this as UserFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UserFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserFormState&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.profile, _this.profile) || other.profile == _this.profile)&&(identical(other.idFront, _this.idFront) || other.idFront == _this.idFront)&&(identical(other.idBack, _this.idBack) || other.idBack == _this.idBack)&&const DeepCollectionEquality().equals(other.errors, _this.errors)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving)&&(identical(other.isDirty, _this.isDirty) || other.isDirty == _this.isDirty)&&(identical(other.warning, _this.warning) || other.warning == _this.warning));
}


@override
int get hashCode {
  final _this = this as UserFormState;
  return Object.hash(runtimeType,_this.name,_this.phone,_this.password,_this.isActive,_this.role,_this.profile,_this.idFront,_this.idBack,const DeepCollectionEquality().hash(_this.errors),_this.isSaving,_this.isDirty,_this.warning);
}

@override
String toString() {
  final _this = this as UserFormState;
  return 'UserFormState(name: ${_this.name}, phone: ${_this.phone}, password: ${_this.password}, isActive: ${_this.isActive}, role: ${_this.role}, profile: ${_this.profile}, idFront: ${_this.idFront}, idBack: ${_this.idBack}, errors: ${_this.errors}, isSaving: ${_this.isSaving}, isDirty: ${_this.isDirty}, warning: ${_this.warning})';
}


}

/// @nodoc
abstract mixin class $UserFormStateCopyWith<$Res>  {
  factory $UserFormStateCopyWith(UserFormState value, $Res Function(UserFormState) _then) = _$UserFormStateCopyWithImpl;
@useResult
$Res call({
 String name, String phone, String password, bool isActive, UserRole role, UserProfile profile, IdentityImageEdit idFront, IdentityImageEdit idBack, Map<String, String> errors, bool isSaving, bool isDirty, String? warning
});


$UserProfileCopyWith<$Res> get profile;$IdentityImageEditCopyWith<$Res> get idFront;$IdentityImageEditCopyWith<$Res> get idBack;

}
/// @nodoc
class _$UserFormStateCopyWithImpl<$Res>
    implements $UserFormStateCopyWith<$Res> {
  _$UserFormStateCopyWithImpl(this._self, this._then);

  final UserFormState _self;
  final $Res Function(UserFormState) _then;

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? phone = null,Object? password = null,Object? isActive = null,Object? role = null,Object? profile = null,Object? idFront = null,Object? idBack = null,Object? errors = null,Object? isSaving = null,Object? isDirty = null,Object? warning = freezed,}) {
  return _then(UserFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile,idFront: null == idFront ? _self.idFront : idFront // ignore: cast_nullable_to_non_nullable
as IdentityImageEdit,idBack: null == idBack ? _self.idBack : idBack // ignore: cast_nullable_to_non_nullable
as IdentityImageEdit,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res> get profile {
  
  return $UserProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdentityImageEditCopyWith<$Res> get idFront {
  
  return $IdentityImageEditCopyWith<$Res>(_self.idFront, (value) {
    return _then(_self.copyWith(idFront: value));
  });
}/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdentityImageEditCopyWith<$Res> get idBack {
  
  return $IdentityImageEditCopyWith<$Res>(_self.idBack, (value) {
    return _then(_self.copyWith(idBack: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String phone,  String password,  bool isActive,  UserRole role,  UserProfile profile,  IdentityImageEdit idFront,  IdentityImageEdit idBack,  Map<String, String> errors,  bool isSaving,  bool isDirty,  String? warning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserFormState() when $default != null:
return $default(_that.name,_that.phone,_that.password,_that.isActive,_that.role,_that.profile,_that.idFront,_that.idBack,_that.errors,_that.isSaving,_that.isDirty,_that.warning);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String phone,  String password,  bool isActive,  UserRole role,  UserProfile profile,  IdentityImageEdit idFront,  IdentityImageEdit idBack,  Map<String, String> errors,  bool isSaving,  bool isDirty,  String? warning)  $default,) {final _that = this;
switch (_that) {
case _UserFormState():
return $default(_that.name,_that.phone,_that.password,_that.isActive,_that.role,_that.profile,_that.idFront,_that.idBack,_that.errors,_that.isSaving,_that.isDirty,_that.warning);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String phone,  String password,  bool isActive,  UserRole role,  UserProfile profile,  IdentityImageEdit idFront,  IdentityImageEdit idBack,  Map<String, String> errors,  bool isSaving,  bool isDirty,  String? warning)?  $default,) {final _that = this;
switch (_that) {
case _UserFormState() when $default != null:
return $default(_that.name,_that.phone,_that.password,_that.isActive,_that.role,_that.profile,_that.idFront,_that.idBack,_that.errors,_that.isSaving,_that.isDirty,_that.warning);case _:
  return null;

}
}

}

/// @nodoc


class _UserFormState implements UserFormState {
  const _UserFormState({this.name = '', this.phone = '', this.password = '', this.isActive = true, this.role = UserRole.user, this.profile = const UserProfile(), this.idFront = const IdentityImageEdit(), this.idBack = const IdentityImageEdit(),  Map<String, String> errors = const <String, String>{}, this.isSaving = false, this.isDirty = false, this.warning}): _errors = errors;
  

@override@JsonKey() final  String name;
@override@JsonKey() final  String phone;
@override@JsonKey() final  String password;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  UserRole role;
/// The optional shop and identity details.
@override@JsonKey() final  UserProfile profile;
@override@JsonKey() final  IdentityImageEdit idFront;
@override@JsonKey() final  IdentityImageEdit idBack;
 final  Map<String, String> _errors;
@override@JsonKey() Map<String, String> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}

@override@JsonKey() final  bool isSaving;
@override@JsonKey() final  bool isDirty;
/// Set after a save that worked except for a picture that could not be uploaded.
@override final  String? warning;

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserFormStateCopyWith<_UserFormState> get copyWith => __$UserFormStateCopyWithImpl<_UserFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.password, password) || other.password == password)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.role, role) || other.role == role)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.idFront, idFront) || other.idFront == idFront)&&(identical(other.idBack, idBack) || other.idBack == idBack)&&const DeepCollectionEquality().equals(other.errors, _errors)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isDirty, isDirty) || other.isDirty == isDirty)&&(identical(other.warning, warning) || other.warning == warning));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,phone,password,isActive,role,profile,idFront,idBack,const DeepCollectionEquality().hash(_errors),isSaving,isDirty,warning);
}

@override
String toString() {
    return 'UserFormState(name: $name, phone: $phone, password: $password, isActive: $isActive, role: $role, profile: $profile, idFront: $idFront, idBack: $idBack, errors: $errors, isSaving: $isSaving, isDirty: $isDirty, warning: $warning)';
}


}

/// @nodoc
abstract mixin class _$UserFormStateCopyWith<$Res> implements $UserFormStateCopyWith<$Res> {
  factory _$UserFormStateCopyWith(_UserFormState value, $Res Function(_UserFormState) _then) = __$UserFormStateCopyWithImpl;
@override @useResult
$Res call({
 String name, String phone, String password, bool isActive, UserRole role, UserProfile profile, IdentityImageEdit idFront, IdentityImageEdit idBack, Map<String, String> errors, bool isSaving, bool isDirty, String? warning
});


@override $UserProfileCopyWith<$Res> get profile;@override $IdentityImageEditCopyWith<$Res> get idFront;@override $IdentityImageEditCopyWith<$Res> get idBack;

}
/// @nodoc
class __$UserFormStateCopyWithImpl<$Res>
    implements _$UserFormStateCopyWith<$Res> {
  __$UserFormStateCopyWithImpl(this._self, this._then);

  final _UserFormState _self;
  final $Res Function(_UserFormState) _then;

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? phone = null,Object? password = null,Object? isActive = null,Object? role = null,Object? profile = null,Object? idFront = null,Object? idBack = null,Object? errors = null,Object? isSaving = null,Object? isDirty = null,Object? warning = freezed,}) {
  return _then(_UserFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile,idFront: null == idFront ? _self.idFront : idFront // ignore: cast_nullable_to_non_nullable
as IdentityImageEdit,idBack: null == idBack ? _self.idBack : idBack // ignore: cast_nullable_to_non_nullable
as IdentityImageEdit,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isDirty: null == isDirty ? _self.isDirty : isDirty // ignore: cast_nullable_to_non_nullable
as bool,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res> get profile {
  
  return $UserProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdentityImageEditCopyWith<$Res> get idFront {
  
  return $IdentityImageEditCopyWith<$Res>(_self.idFront, (value) {
    return _then(_self.copyWith(idFront: value));
  });
}/// Create a copy of UserFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IdentityImageEditCopyWith<$Res> get idBack {
  
  return $IdentityImageEditCopyWith<$Res>(_self.idBack, (value) {
    return _then(_self.copyWith(idBack: value));
  });
}
}

// dart format on

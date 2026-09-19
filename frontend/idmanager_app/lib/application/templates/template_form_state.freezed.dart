// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TemplateFormState {

 String get name; double get cardWidthMm; double get cardHeightMm; int get pointCost; bool get isActive; UploadedFile? get frontFile; UploadedFile? get backFile; String? get existingFrontImageBase64; String? get existingBackImageBase64; Map<String, String> get errors; bool get isSaving;
/// Create a copy of TemplateFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateFormStateCopyWith<TemplateFormState> get copyWith => _$TemplateFormStateCopyWithImpl<TemplateFormState>(this as TemplateFormState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TemplateFormState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateFormState&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.cardWidthMm, _this.cardWidthMm) || other.cardWidthMm == _this.cardWidthMm)&&(identical(other.cardHeightMm, _this.cardHeightMm) || other.cardHeightMm == _this.cardHeightMm)&&(identical(other.pointCost, _this.pointCost) || other.pointCost == _this.pointCost)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.frontFile, _this.frontFile) || other.frontFile == _this.frontFile)&&(identical(other.backFile, _this.backFile) || other.backFile == _this.backFile)&&(identical(other.existingFrontImageBase64, _this.existingFrontImageBase64) || other.existingFrontImageBase64 == _this.existingFrontImageBase64)&&(identical(other.existingBackImageBase64, _this.existingBackImageBase64) || other.existingBackImageBase64 == _this.existingBackImageBase64)&&const DeepCollectionEquality().equals(other.errors, _this.errors)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving));
}


@override
int get hashCode {
  final _this = this as TemplateFormState;
  return Object.hash(runtimeType,_this.name,_this.cardWidthMm,_this.cardHeightMm,_this.pointCost,_this.isActive,_this.frontFile,_this.backFile,_this.existingFrontImageBase64,_this.existingBackImageBase64,const DeepCollectionEquality().hash(_this.errors),_this.isSaving);
}

@override
String toString() {
  final _this = this as TemplateFormState;
  return 'TemplateFormState(name: ${_this.name}, cardWidthMm: ${_this.cardWidthMm}, cardHeightMm: ${_this.cardHeightMm}, pointCost: ${_this.pointCost}, isActive: ${_this.isActive}, frontFile: ${_this.frontFile}, backFile: ${_this.backFile}, existingFrontImageBase64: ${_this.existingFrontImageBase64}, existingBackImageBase64: ${_this.existingBackImageBase64}, errors: ${_this.errors}, isSaving: ${_this.isSaving})';
}


}

/// @nodoc
abstract mixin class $TemplateFormStateCopyWith<$Res>  {
  factory $TemplateFormStateCopyWith(TemplateFormState value, $Res Function(TemplateFormState) _then) = _$TemplateFormStateCopyWithImpl;
@useResult
$Res call({
 String name, double cardWidthMm, double cardHeightMm, int pointCost, bool isActive, UploadedFile? frontFile, UploadedFile? backFile, String? existingFrontImageBase64, String? existingBackImageBase64, Map<String, String> errors, bool isSaving
});




}
/// @nodoc
class _$TemplateFormStateCopyWithImpl<$Res>
    implements $TemplateFormStateCopyWith<$Res> {
  _$TemplateFormStateCopyWithImpl(this._self, this._then);

  final TemplateFormState _self;
  final $Res Function(TemplateFormState) _then;

/// Create a copy of TemplateFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? cardWidthMm = null,Object? cardHeightMm = null,Object? pointCost = null,Object? isActive = null,Object? frontFile = freezed,Object? backFile = freezed,Object? existingFrontImageBase64 = freezed,Object? existingBackImageBase64 = freezed,Object? errors = null,Object? isSaving = null,}) {
  return _then(TemplateFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cardWidthMm: null == cardWidthMm ? _self.cardWidthMm : cardWidthMm // ignore: cast_nullable_to_non_nullable
as double,cardHeightMm: null == cardHeightMm ? _self.cardHeightMm : cardHeightMm // ignore: cast_nullable_to_non_nullable
as double,pointCost: null == pointCost ? _self.pointCost : pointCost // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,frontFile: freezed == frontFile ? _self.frontFile : frontFile // ignore: cast_nullable_to_non_nullable
as UploadedFile?,backFile: freezed == backFile ? _self.backFile : backFile // ignore: cast_nullable_to_non_nullable
as UploadedFile?,existingFrontImageBase64: freezed == existingFrontImageBase64 ? _self.existingFrontImageBase64 : existingFrontImageBase64 // ignore: cast_nullable_to_non_nullable
as String?,existingBackImageBase64: freezed == existingBackImageBase64 ? _self.existingBackImageBase64 : existingBackImageBase64 // ignore: cast_nullable_to_non_nullable
as String?,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateFormState].
extension TemplateFormStatePatterns on TemplateFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateFormState value)  $default,){
final _that = this;
switch (_that) {
case _TemplateFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateFormState value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double cardWidthMm,  double cardHeightMm,  int pointCost,  bool isActive,  UploadedFile? frontFile,  UploadedFile? backFile,  String? existingFrontImageBase64,  String? existingBackImageBase64,  Map<String, String> errors,  bool isSaving)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateFormState() when $default != null:
return $default(_that.name,_that.cardWidthMm,_that.cardHeightMm,_that.pointCost,_that.isActive,_that.frontFile,_that.backFile,_that.existingFrontImageBase64,_that.existingBackImageBase64,_that.errors,_that.isSaving);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double cardWidthMm,  double cardHeightMm,  int pointCost,  bool isActive,  UploadedFile? frontFile,  UploadedFile? backFile,  String? existingFrontImageBase64,  String? existingBackImageBase64,  Map<String, String> errors,  bool isSaving)  $default,) {final _that = this;
switch (_that) {
case _TemplateFormState():
return $default(_that.name,_that.cardWidthMm,_that.cardHeightMm,_that.pointCost,_that.isActive,_that.frontFile,_that.backFile,_that.existingFrontImageBase64,_that.existingBackImageBase64,_that.errors,_that.isSaving);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double cardWidthMm,  double cardHeightMm,  int pointCost,  bool isActive,  UploadedFile? frontFile,  UploadedFile? backFile,  String? existingFrontImageBase64,  String? existingBackImageBase64,  Map<String, String> errors,  bool isSaving)?  $default,) {final _that = this;
switch (_that) {
case _TemplateFormState() when $default != null:
return $default(_that.name,_that.cardWidthMm,_that.cardHeightMm,_that.pointCost,_that.isActive,_that.frontFile,_that.backFile,_that.existingFrontImageBase64,_that.existingBackImageBase64,_that.errors,_that.isSaving);case _:
  return null;

}
}

}

/// @nodoc


class _TemplateFormState implements TemplateFormState {
  const _TemplateFormState({this.name = '', this.cardWidthMm = 85.6, this.cardHeightMm = 54.0, this.pointCost = 1, this.isActive = true, this.frontFile, this.backFile, this.existingFrontImageBase64, this.existingBackImageBase64,  Map<String, String> errors = const <String, String>{}, this.isSaving = false}): _errors = errors;
  

@override@JsonKey() final  String name;
@override@JsonKey() final  double cardWidthMm;
@override@JsonKey() final  double cardHeightMm;
@override@JsonKey() final  int pointCost;
@override@JsonKey() final  bool isActive;
@override final  UploadedFile? frontFile;
@override final  UploadedFile? backFile;
@override final  String? existingFrontImageBase64;
@override final  String? existingBackImageBase64;
 final  Map<String, String> _errors;
@override@JsonKey() Map<String, String> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}

@override@JsonKey() final  bool isSaving;

/// Create a copy of TemplateFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateFormStateCopyWith<_TemplateFormState> get copyWith => __$TemplateFormStateCopyWithImpl<_TemplateFormState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateFormState&&(identical(other.name, name) || other.name == name)&&(identical(other.cardWidthMm, cardWidthMm) || other.cardWidthMm == cardWidthMm)&&(identical(other.cardHeightMm, cardHeightMm) || other.cardHeightMm == cardHeightMm)&&(identical(other.pointCost, pointCost) || other.pointCost == pointCost)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.frontFile, frontFile) || other.frontFile == frontFile)&&(identical(other.backFile, backFile) || other.backFile == backFile)&&(identical(other.existingFrontImageBase64, existingFrontImageBase64) || other.existingFrontImageBase64 == existingFrontImageBase64)&&(identical(other.existingBackImageBase64, existingBackImageBase64) || other.existingBackImageBase64 == existingBackImageBase64)&&const DeepCollectionEquality().equals(other.errors, _errors)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,cardWidthMm,cardHeightMm,pointCost,isActive,frontFile,backFile,existingFrontImageBase64,existingBackImageBase64,const DeepCollectionEquality().hash(_errors),isSaving);
}

@override
String toString() {
    return 'TemplateFormState(name: $name, cardWidthMm: $cardWidthMm, cardHeightMm: $cardHeightMm, pointCost: $pointCost, isActive: $isActive, frontFile: $frontFile, backFile: $backFile, existingFrontImageBase64: $existingFrontImageBase64, existingBackImageBase64: $existingBackImageBase64, errors: $errors, isSaving: $isSaving)';
}


}

/// @nodoc
abstract mixin class _$TemplateFormStateCopyWith<$Res> implements $TemplateFormStateCopyWith<$Res> {
  factory _$TemplateFormStateCopyWith(_TemplateFormState value, $Res Function(_TemplateFormState) _then) = __$TemplateFormStateCopyWithImpl;
@override @useResult
$Res call({
 String name, double cardWidthMm, double cardHeightMm, int pointCost, bool isActive, UploadedFile? frontFile, UploadedFile? backFile, String? existingFrontImageBase64, String? existingBackImageBase64, Map<String, String> errors, bool isSaving
});




}
/// @nodoc
class __$TemplateFormStateCopyWithImpl<$Res>
    implements _$TemplateFormStateCopyWith<$Res> {
  __$TemplateFormStateCopyWithImpl(this._self, this._then);

  final _TemplateFormState _self;
  final $Res Function(_TemplateFormState) _then;

/// Create a copy of TemplateFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? cardWidthMm = null,Object? cardHeightMm = null,Object? pointCost = null,Object? isActive = null,Object? frontFile = freezed,Object? backFile = freezed,Object? existingFrontImageBase64 = freezed,Object? existingBackImageBase64 = freezed,Object? errors = null,Object? isSaving = null,}) {
  return _then(_TemplateFormState(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cardWidthMm: null == cardWidthMm ? _self.cardWidthMm : cardWidthMm // ignore: cast_nullable_to_non_nullable
as double,cardHeightMm: null == cardHeightMm ? _self.cardHeightMm : cardHeightMm // ignore: cast_nullable_to_non_nullable
as double,pointCost: null == pointCost ? _self.pointCost : pointCost // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,frontFile: freezed == frontFile ? _self.frontFile : frontFile // ignore: cast_nullable_to_non_nullable
as UploadedFile?,backFile: freezed == backFile ? _self.backFile : backFile // ignore: cast_nullable_to_non_nullable
as UploadedFile?,existingFrontImageBase64: freezed == existingFrontImageBase64 ? _self.existingFrontImageBase64 : existingFrontImageBase64 // ignore: cast_nullable_to_non_nullable
as String?,existingBackImageBase64: freezed == existingBackImageBase64 ? _self.existingBackImageBase64 : existingBackImageBase64 // ignore: cast_nullable_to_non_nullable
as String?,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

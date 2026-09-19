// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adjust_points_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AdjustPointsState {

 int get points; String get reason; bool get isSaving; Map<String, String> get errors;
/// Create a copy of AdjustPointsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdjustPointsStateCopyWith<AdjustPointsState> get copyWith => _$AdjustPointsStateCopyWithImpl<AdjustPointsState>(this as AdjustPointsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AdjustPointsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdjustPointsState&&(identical(other.points, _this.points) || other.points == _this.points)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving)&&const DeepCollectionEquality().equals(other.errors, _this.errors));
}


@override
int get hashCode {
  final _this = this as AdjustPointsState;
  return Object.hash(runtimeType,_this.points,_this.reason,_this.isSaving,const DeepCollectionEquality().hash(_this.errors));
}

@override
String toString() {
  final _this = this as AdjustPointsState;
  return 'AdjustPointsState(points: ${_this.points}, reason: ${_this.reason}, isSaving: ${_this.isSaving}, errors: ${_this.errors})';
}


}

/// @nodoc
abstract mixin class $AdjustPointsStateCopyWith<$Res>  {
  factory $AdjustPointsStateCopyWith(AdjustPointsState value, $Res Function(AdjustPointsState) _then) = _$AdjustPointsStateCopyWithImpl;
@useResult
$Res call({
 int points, String reason, bool isSaving, Map<String, String> errors
});




}
/// @nodoc
class _$AdjustPointsStateCopyWithImpl<$Res>
    implements $AdjustPointsStateCopyWith<$Res> {
  _$AdjustPointsStateCopyWithImpl(this._self, this._then);

  final AdjustPointsState _self;
  final $Res Function(AdjustPointsState) _then;

/// Create a copy of AdjustPointsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? points = null,Object? reason = null,Object? isSaving = null,Object? errors = null,}) {
  return _then(AdjustPointsState(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AdjustPointsState].
extension AdjustPointsStatePatterns on AdjustPointsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdjustPointsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdjustPointsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdjustPointsState value)  $default,){
final _that = this;
switch (_that) {
case _AdjustPointsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdjustPointsState value)?  $default,){
final _that = this;
switch (_that) {
case _AdjustPointsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int points,  String reason,  bool isSaving,  Map<String, String> errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdjustPointsState() when $default != null:
return $default(_that.points,_that.reason,_that.isSaving,_that.errors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int points,  String reason,  bool isSaving,  Map<String, String> errors)  $default,) {final _that = this;
switch (_that) {
case _AdjustPointsState():
return $default(_that.points,_that.reason,_that.isSaving,_that.errors);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int points,  String reason,  bool isSaving,  Map<String, String> errors)?  $default,) {final _that = this;
switch (_that) {
case _AdjustPointsState() when $default != null:
return $default(_that.points,_that.reason,_that.isSaving,_that.errors);case _:
  return null;

}
}

}

/// @nodoc


class _AdjustPointsState implements AdjustPointsState {
  const _AdjustPointsState({this.points = 0, this.reason = '', this.isSaving = false,  Map<String, String> errors = const <String, String>{}}): _errors = errors;
  

@override@JsonKey() final  int points;
@override@JsonKey() final  String reason;
@override@JsonKey() final  bool isSaving;
 final  Map<String, String> _errors;
@override@JsonKey() Map<String, String> get errors {
  if (_errors is EqualUnmodifiableMapView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_errors);
}


/// Create a copy of AdjustPointsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdjustPointsStateCopyWith<_AdjustPointsState> get copyWith => __$AdjustPointsStateCopyWithImpl<_AdjustPointsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdjustPointsState&&(identical(other.points, points) || other.points == points)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&const DeepCollectionEquality().equals(other.errors, _errors));
}


@override
int get hashCode {
    return Object.hash(runtimeType,points,reason,isSaving,const DeepCollectionEquality().hash(_errors));
}

@override
String toString() {
    return 'AdjustPointsState(points: $points, reason: $reason, isSaving: $isSaving, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$AdjustPointsStateCopyWith<$Res> implements $AdjustPointsStateCopyWith<$Res> {
  factory _$AdjustPointsStateCopyWith(_AdjustPointsState value, $Res Function(_AdjustPointsState) _then) = __$AdjustPointsStateCopyWithImpl;
@override @useResult
$Res call({
 int points, String reason, bool isSaving, Map<String, String> errors
});




}
/// @nodoc
class __$AdjustPointsStateCopyWithImpl<$Res>
    implements _$AdjustPointsStateCopyWith<$Res> {
  __$AdjustPointsStateCopyWithImpl(this._self, this._then);

  final _AdjustPointsState _self;
  final $Res Function(_AdjustPointsState) _then;

/// Create a copy of AdjustPointsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? points = null,Object? reason = null,Object? isSaving = null,Object? errors = null,}) {
  return _then(_AdjustPointsState(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on

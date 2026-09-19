// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'point_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PointTransaction {

 DateTime get date; String get description; int get points; PointTransType get type; PointStatus get status;
/// Create a copy of PointTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PointTransactionCopyWith<PointTransaction> get copyWith => _$PointTransactionCopyWithImpl<PointTransaction>(this as PointTransaction, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PointTransaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PointTransaction&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.points, _this.points) || other.points == _this.points)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as PointTransaction;
  return Object.hash(runtimeType,_this.date,_this.description,_this.points,_this.type,_this.status);
}

@override
String toString() {
  final _this = this as PointTransaction;
  return 'PointTransaction(date: ${_this.date}, description: ${_this.description}, points: ${_this.points}, type: ${_this.type}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $PointTransactionCopyWith<$Res>  {
  factory $PointTransactionCopyWith(PointTransaction value, $Res Function(PointTransaction) _then) = _$PointTransactionCopyWithImpl;
@useResult
$Res call({
 DateTime date, String description, int points, PointTransType type, PointStatus status
});




}
/// @nodoc
class _$PointTransactionCopyWithImpl<$Res>
    implements $PointTransactionCopyWith<$Res> {
  _$PointTransactionCopyWithImpl(this._self, this._then);

  final PointTransaction _self;
  final $Res Function(PointTransaction) _then;

/// Create a copy of PointTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? description = null,Object? points = null,Object? type = null,Object? status = null,}) {
  return _then(PointTransaction(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PointTransType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PointStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [PointTransaction].
extension PointTransactionPatterns on PointTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PointTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PointTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PointTransaction value)  $default,){
final _that = this;
switch (_that) {
case _PointTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PointTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _PointTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  String description,  int points,  PointTransType type,  PointStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PointTransaction() when $default != null:
return $default(_that.date,_that.description,_that.points,_that.type,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  String description,  int points,  PointTransType type,  PointStatus status)  $default,) {final _that = this;
switch (_that) {
case _PointTransaction():
return $default(_that.date,_that.description,_that.points,_that.type,_that.status);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  String description,  int points,  PointTransType type,  PointStatus status)?  $default,) {final _that = this;
switch (_that) {
case _PointTransaction() when $default != null:
return $default(_that.date,_that.description,_that.points,_that.type,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _PointTransaction implements PointTransaction {
  const _PointTransaction({required this.date, required this.description, required this.points, required this.type, required this.status});
  

@override final  DateTime date;
@override final  String description;
@override final  int points;
@override final  PointTransType type;
@override final  PointStatus status;

/// Create a copy of PointTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PointTransactionCopyWith<_PointTransaction> get copyWith => __$PointTransactionCopyWithImpl<_PointTransaction>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PointTransaction&&(identical(other.date, date) || other.date == date)&&(identical(other.description, description) || other.description == description)&&(identical(other.points, points) || other.points == points)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,date,description,points,type,status);
}

@override
String toString() {
    return 'PointTransaction(date: $date, description: $description, points: $points, type: $type, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PointTransactionCopyWith<$Res> implements $PointTransactionCopyWith<$Res> {
  factory _$PointTransactionCopyWith(_PointTransaction value, $Res Function(_PointTransaction) _then) = __$PointTransactionCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, String description, int points, PointTransType type, PointStatus status
});




}
/// @nodoc
class __$PointTransactionCopyWithImpl<$Res>
    implements _$PointTransactionCopyWith<$Res> {
  __$PointTransactionCopyWithImpl(this._self, this._then);

  final _PointTransaction _self;
  final $Res Function(_PointTransaction) _then;

/// Create a copy of PointTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? description = null,Object? points = null,Object? type = null,Object? status = null,}) {
  return _then(_PointTransaction(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PointTransType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PointStatus,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuditLogEntry {

 int get id; int? get userId; String get action; String get entityName; String? get entityId; String? get detailsJson; DateTime get createdAt;
/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogEntryCopyWith<AuditLogEntry> get copyWith => _$AuditLogEntryCopyWithImpl<AuditLogEntry>(this as AuditLogEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AuditLogEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLogEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.action, _this.action) || other.action == _this.action)&&(identical(other.entityName, _this.entityName) || other.entityName == _this.entityName)&&(identical(other.entityId, _this.entityId) || other.entityId == _this.entityId)&&(identical(other.detailsJson, _this.detailsJson) || other.detailsJson == _this.detailsJson)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as AuditLogEntry;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.action,_this.entityName,_this.entityId,_this.detailsJson,_this.createdAt);
}

@override
String toString() {
  final _this = this as AuditLogEntry;
  return 'AuditLogEntry(id: ${_this.id}, userId: ${_this.userId}, action: ${_this.action}, entityName: ${_this.entityName}, entityId: ${_this.entityId}, detailsJson: ${_this.detailsJson}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $AuditLogEntryCopyWith<$Res>  {
  factory $AuditLogEntryCopyWith(AuditLogEntry value, $Res Function(AuditLogEntry) _then) = _$AuditLogEntryCopyWithImpl;
@useResult
$Res call({
 int id, int? userId, String action, String entityName, String? entityId, String? detailsJson, DateTime createdAt
});




}
/// @nodoc
class _$AuditLogEntryCopyWithImpl<$Res>
    implements $AuditLogEntryCopyWith<$Res> {
  _$AuditLogEntryCopyWithImpl(this._self, this._then);

  final AuditLogEntry _self;
  final $Res Function(AuditLogEntry) _then;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = freezed,Object? action = null,Object? entityName = null,Object? entityId = freezed,Object? detailsJson = freezed,Object? createdAt = null,}) {
  return _then(AuditLogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,entityName: null == entityName ? _self.entityName : entityName // ignore: cast_nullable_to_non_nullable
as String,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String?,detailsJson: freezed == detailsJson ? _self.detailsJson : detailsJson // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLogEntry].
extension AuditLogEntryPatterns on AuditLogEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLogEntry value)  $default,){
final _that = this;
switch (_that) {
case _AuditLogEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int? userId,  String action,  String entityName,  String? entityId,  String? detailsJson,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
return $default(_that.id,_that.userId,_that.action,_that.entityName,_that.entityId,_that.detailsJson,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int? userId,  String action,  String entityName,  String? entityId,  String? detailsJson,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AuditLogEntry():
return $default(_that.id,_that.userId,_that.action,_that.entityName,_that.entityId,_that.detailsJson,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int? userId,  String action,  String entityName,  String? entityId,  String? detailsJson,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
return $default(_that.id,_that.userId,_that.action,_that.entityName,_that.entityId,_that.detailsJson,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _AuditLogEntry implements AuditLogEntry {
  const _AuditLogEntry({required this.id, this.userId, required this.action, required this.entityName, this.entityId, this.detailsJson, required this.createdAt});
  

@override final  int id;
@override final  int? userId;
@override final  String action;
@override final  String entityName;
@override final  String? entityId;
@override final  String? detailsJson;
@override final  DateTime createdAt;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogEntryCopyWith<_AuditLogEntry> get copyWith => __$AuditLogEntryCopyWithImpl<_AuditLogEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.action, action) || other.action == action)&&(identical(other.entityName, entityName) || other.entityName == entityName)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.detailsJson, detailsJson) || other.detailsJson == detailsJson)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,action,entityName,entityId,detailsJson,createdAt);
}

@override
String toString() {
    return 'AuditLogEntry(id: $id, userId: $userId, action: $action, entityName: $entityName, entityId: $entityId, detailsJson: $detailsJson, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AuditLogEntryCopyWith<$Res> implements $AuditLogEntryCopyWith<$Res> {
  factory _$AuditLogEntryCopyWith(_AuditLogEntry value, $Res Function(_AuditLogEntry) _then) = __$AuditLogEntryCopyWithImpl;
@override @useResult
$Res call({
 int id, int? userId, String action, String entityName, String? entityId, String? detailsJson, DateTime createdAt
});




}
/// @nodoc
class __$AuditLogEntryCopyWithImpl<$Res>
    implements _$AuditLogEntryCopyWith<$Res> {
  __$AuditLogEntryCopyWithImpl(this._self, this._then);

  final _AuditLogEntry _self;
  final $Res Function(_AuditLogEntry) _then;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = freezed,Object? action = null,Object? entityName = null,Object? entityId = freezed,Object? detailsJson = freezed,Object? createdAt = null,}) {
  return _then(_AuditLogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,entityName: null == entityName ? _self.entityName : entityName // ignore: cast_nullable_to_non_nullable
as String,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String?,detailsJson: freezed == detailsJson ? _self.detailsJson : detailsJson // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

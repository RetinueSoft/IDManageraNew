// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'field_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExtractedField {

 String? get key; String? get value; LayerFieldType get type;
/// Create a copy of ExtractedField
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtractedFieldCopyWith<ExtractedField> get copyWith => _$ExtractedFieldCopyWithImpl<ExtractedField>(this as ExtractedField, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExtractedField;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtractedField&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.type, _this.type) || other.type == _this.type));
}


@override
int get hashCode {
  final _this = this as ExtractedField;
  return Object.hash(runtimeType,_this.key,_this.value,_this.type);
}

@override
String toString() {
  final _this = this as ExtractedField;
  return 'ExtractedField(key: ${_this.key}, value: ${_this.value}, type: ${_this.type})';
}


}

/// @nodoc
abstract mixin class $ExtractedFieldCopyWith<$Res>  {
  factory $ExtractedFieldCopyWith(ExtractedField value, $Res Function(ExtractedField) _then) = _$ExtractedFieldCopyWithImpl;
@useResult
$Res call({
 String? key, String? value, LayerFieldType type
});




}
/// @nodoc
class _$ExtractedFieldCopyWithImpl<$Res>
    implements $ExtractedFieldCopyWith<$Res> {
  _$ExtractedFieldCopyWithImpl(this._self, this._then);

  final ExtractedField _self;
  final $Res Function(ExtractedField) _then;

/// Create a copy of ExtractedField
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = freezed,Object? value = freezed,Object? type = null,}) {
  return _then(ExtractedField(
key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LayerFieldType,
  ));
}

}


/// Adds pattern-matching-related methods to [ExtractedField].
extension ExtractedFieldPatterns on ExtractedField {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExtractedField value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExtractedField() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExtractedField value)  $default,){
final _that = this;
switch (_that) {
case _ExtractedField():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExtractedField value)?  $default,){
final _that = this;
switch (_that) {
case _ExtractedField() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? key,  String? value,  LayerFieldType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExtractedField() when $default != null:
return $default(_that.key,_that.value,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? key,  String? value,  LayerFieldType type)  $default,) {final _that = this;
switch (_that) {
case _ExtractedField():
return $default(_that.key,_that.value,_that.type);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? key,  String? value,  LayerFieldType type)?  $default,) {final _that = this;
switch (_that) {
case _ExtractedField() when $default != null:
return $default(_that.key,_that.value,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _ExtractedField implements ExtractedField {
  const _ExtractedField({this.key, this.value, this.type = LayerFieldType.text});
  

@override final  String? key;
@override final  String? value;
@override@JsonKey() final  LayerFieldType type;

/// Create a copy of ExtractedField
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExtractedFieldCopyWith<_ExtractedField> get copyWith => __$ExtractedFieldCopyWithImpl<_ExtractedField>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExtractedField&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,value,type);
}

@override
String toString() {
    return 'ExtractedField(key: $key, value: $value, type: $type)';
}


}

/// @nodoc
abstract mixin class _$ExtractedFieldCopyWith<$Res> implements $ExtractedFieldCopyWith<$Res> {
  factory _$ExtractedFieldCopyWith(_ExtractedField value, $Res Function(_ExtractedField) _then) = __$ExtractedFieldCopyWithImpl;
@override @useResult
$Res call({
 String? key, String? value, LayerFieldType type
});




}
/// @nodoc
class __$ExtractedFieldCopyWithImpl<$Res>
    implements _$ExtractedFieldCopyWith<$Res> {
  __$ExtractedFieldCopyWithImpl(this._self, this._then);

  final _ExtractedField _self;
  final $Res Function(_ExtractedField) _then;

/// Create a copy of ExtractedField
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = freezed,Object? value = freezed,Object? type = null,}) {
  return _then(_ExtractedField(
key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LayerFieldType,
  ));
}


}

/// @nodoc
mixin _$FieldGroup {

 String get name; int get index; List<ExtractedField> get items;
/// Create a copy of FieldGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldGroupCopyWith<FieldGroup> get copyWith => _$FieldGroupCopyWithImpl<FieldGroup>(this as FieldGroup, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FieldGroup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldGroup&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.index, _this.index) || other.index == _this.index)&&const DeepCollectionEquality().equals(other.items, _this.items));
}


@override
int get hashCode {
  final _this = this as FieldGroup;
  return Object.hash(runtimeType,_this.name,_this.index,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as FieldGroup;
  return 'FieldGroup(name: ${_this.name}, index: ${_this.index}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $FieldGroupCopyWith<$Res>  {
  factory $FieldGroupCopyWith(FieldGroup value, $Res Function(FieldGroup) _then) = _$FieldGroupCopyWithImpl;
@useResult
$Res call({
 String name, int index, List<ExtractedField> items
});




}
/// @nodoc
class _$FieldGroupCopyWithImpl<$Res>
    implements $FieldGroupCopyWith<$Res> {
  _$FieldGroupCopyWithImpl(this._self, this._then);

  final FieldGroup _self;
  final $Res Function(FieldGroup) _then;

/// Create a copy of FieldGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? index = null,Object? items = null,}) {
  return _then(FieldGroup(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<ExtractedField>,
  ));
}

}


/// Adds pattern-matching-related methods to [FieldGroup].
extension FieldGroupPatterns on FieldGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FieldGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FieldGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FieldGroup value)  $default,){
final _that = this;
switch (_that) {
case _FieldGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FieldGroup value)?  $default,){
final _that = this;
switch (_that) {
case _FieldGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int index,  List<ExtractedField> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FieldGroup() when $default != null:
return $default(_that.name,_that.index,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int index,  List<ExtractedField> items)  $default,) {final _that = this;
switch (_that) {
case _FieldGroup():
return $default(_that.name,_that.index,_that.items);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int index,  List<ExtractedField> items)?  $default,) {final _that = this;
switch (_that) {
case _FieldGroup() when $default != null:
return $default(_that.name,_that.index,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _FieldGroup implements FieldGroup {
  const _FieldGroup({required this.name, this.index = 0,  List<ExtractedField> items = const <ExtractedField>[]}): _items = items;
  

@override final  String name;
@override@JsonKey() final  int index;
 final  List<ExtractedField> _items;
@override@JsonKey() List<ExtractedField> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of FieldGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldGroupCopyWith<_FieldGroup> get copyWith => __$FieldGroupCopyWithImpl<_FieldGroup>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FieldGroup&&(identical(other.name, name) || other.name == name)&&(identical(other.index, index) || other.index == index)&&const DeepCollectionEquality().equals(other.items, _items));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,index,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'FieldGroup(name: $name, index: $index, items: $items)';
}


}

/// @nodoc
abstract mixin class _$FieldGroupCopyWith<$Res> implements $FieldGroupCopyWith<$Res> {
  factory _$FieldGroupCopyWith(_FieldGroup value, $Res Function(_FieldGroup) _then) = __$FieldGroupCopyWithImpl;
@override @useResult
$Res call({
 String name, int index, List<ExtractedField> items
});




}
/// @nodoc
class __$FieldGroupCopyWithImpl<$Res>
    implements _$FieldGroupCopyWith<$Res> {
  __$FieldGroupCopyWithImpl(this._self, this._then);

  final _FieldGroup _self;
  final $Res Function(_FieldGroup) _then;

/// Create a copy of FieldGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? index = null,Object? items = null,}) {
  return _then(_FieldGroup(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<ExtractedField>,
  ));
}


}

// dart format on

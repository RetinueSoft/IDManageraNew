// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Combination {

 int get id; String get name; String get frontImageBase64; String get backImageBase64;
/// Create a copy of Combination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CombinationCopyWith<Combination> get copyWith => _$CombinationCopyWithImpl<Combination>(this as Combination, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Combination;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Combination&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.frontImageBase64, _this.frontImageBase64) || other.frontImageBase64 == _this.frontImageBase64)&&(identical(other.backImageBase64, _this.backImageBase64) || other.backImageBase64 == _this.backImageBase64));
}


@override
int get hashCode {
  final _this = this as Combination;
  return Object.hash(runtimeType,_this.id,_this.name,_this.frontImageBase64,_this.backImageBase64);
}

@override
String toString() {
  final _this = this as Combination;
  return 'Combination(id: ${_this.id}, name: ${_this.name}, frontImageBase64: ${_this.frontImageBase64}, backImageBase64: ${_this.backImageBase64})';
}


}

/// @nodoc
abstract mixin class $CombinationCopyWith<$Res>  {
  factory $CombinationCopyWith(Combination value, $Res Function(Combination) _then) = _$CombinationCopyWithImpl;
@useResult
$Res call({
 int id, String name, String frontImageBase64, String backImageBase64
});




}
/// @nodoc
class _$CombinationCopyWithImpl<$Res>
    implements $CombinationCopyWith<$Res> {
  _$CombinationCopyWithImpl(this._self, this._then);

  final Combination _self;
  final $Res Function(Combination) _then;

/// Create a copy of Combination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? frontImageBase64 = null,Object? backImageBase64 = null,}) {
  return _then(Combination(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,frontImageBase64: null == frontImageBase64 ? _self.frontImageBase64 : frontImageBase64 // ignore: cast_nullable_to_non_nullable
as String,backImageBase64: null == backImageBase64 ? _self.backImageBase64 : backImageBase64 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Combination].
extension CombinationPatterns on Combination {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Combination value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Combination() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Combination value)  $default,){
final _that = this;
switch (_that) {
case _Combination():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Combination value)?  $default,){
final _that = this;
switch (_that) {
case _Combination() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String frontImageBase64,  String backImageBase64)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Combination() when $default != null:
return $default(_that.id,_that.name,_that.frontImageBase64,_that.backImageBase64);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String frontImageBase64,  String backImageBase64)  $default,) {final _that = this;
switch (_that) {
case _Combination():
return $default(_that.id,_that.name,_that.frontImageBase64,_that.backImageBase64);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String frontImageBase64,  String backImageBase64)?  $default,) {final _that = this;
switch (_that) {
case _Combination() when $default != null:
return $default(_that.id,_that.name,_that.frontImageBase64,_that.backImageBase64);case _:
  return null;

}
}

}

/// @nodoc


class _Combination implements Combination {
  const _Combination({required this.id, required this.name, required this.frontImageBase64, required this.backImageBase64});
  

@override final  int id;
@override final  String name;
@override final  String frontImageBase64;
@override final  String backImageBase64;

/// Create a copy of Combination
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CombinationCopyWith<_Combination> get copyWith => __$CombinationCopyWithImpl<_Combination>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Combination&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.frontImageBase64, frontImageBase64) || other.frontImageBase64 == frontImageBase64)&&(identical(other.backImageBase64, backImageBase64) || other.backImageBase64 == backImageBase64));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,frontImageBase64,backImageBase64);
}

@override
String toString() {
    return 'Combination(id: $id, name: $name, frontImageBase64: $frontImageBase64, backImageBase64: $backImageBase64)';
}


}

/// @nodoc
abstract mixin class _$CombinationCopyWith<$Res> implements $CombinationCopyWith<$Res> {
  factory _$CombinationCopyWith(_Combination value, $Res Function(_Combination) _then) = __$CombinationCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String frontImageBase64, String backImageBase64
});




}
/// @nodoc
class __$CombinationCopyWithImpl<$Res>
    implements _$CombinationCopyWith<$Res> {
  __$CombinationCopyWithImpl(this._self, this._then);

  final _Combination _self;
  final $Res Function(_Combination) _then;

/// Create a copy of Combination
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? frontImageBase64 = null,Object? backImageBase64 = null,}) {
  return _then(_Combination(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,frontImageBase64: null == frontImageBase64 ? _self.frontImageBase64 : frontImageBase64 // ignore: cast_nullable_to_non_nullable
as String,backImageBase64: null == backImageBase64 ? _self.backImageBase64 : backImageBase64 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$CardTemplate {

 int get id; String get name; double get cardWidthMm; double get cardHeightMm; int get pointCost; bool get isActive;/// What a downloaded card PDF is called - the member's PDF fields as {Field}, e.g.
/// '{Name} - {Card No}'. Null means "card-<id>".
 String? get fileNamePattern; String get frontImageBase64; String get backImageBase64; DateTime get createdAt;
/// Create a copy of CardTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardTemplateCopyWith<CardTemplate> get copyWith => _$CardTemplateCopyWithImpl<CardTemplate>(this as CardTemplate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CardTemplate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardTemplate&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.cardWidthMm, _this.cardWidthMm) || other.cardWidthMm == _this.cardWidthMm)&&(identical(other.cardHeightMm, _this.cardHeightMm) || other.cardHeightMm == _this.cardHeightMm)&&(identical(other.pointCost, _this.pointCost) || other.pointCost == _this.pointCost)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.fileNamePattern, _this.fileNamePattern) || other.fileNamePattern == _this.fileNamePattern)&&(identical(other.frontImageBase64, _this.frontImageBase64) || other.frontImageBase64 == _this.frontImageBase64)&&(identical(other.backImageBase64, _this.backImageBase64) || other.backImageBase64 == _this.backImageBase64)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as CardTemplate;
  return Object.hash(runtimeType,_this.id,_this.name,_this.cardWidthMm,_this.cardHeightMm,_this.pointCost,_this.isActive,_this.fileNamePattern,_this.frontImageBase64,_this.backImageBase64,_this.createdAt);
}

@override
String toString() {
  final _this = this as CardTemplate;
  return 'CardTemplate(id: ${_this.id}, name: ${_this.name}, cardWidthMm: ${_this.cardWidthMm}, cardHeightMm: ${_this.cardHeightMm}, pointCost: ${_this.pointCost}, isActive: ${_this.isActive}, fileNamePattern: ${_this.fileNamePattern}, frontImageBase64: ${_this.frontImageBase64}, backImageBase64: ${_this.backImageBase64}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $CardTemplateCopyWith<$Res>  {
  factory $CardTemplateCopyWith(CardTemplate value, $Res Function(CardTemplate) _then) = _$CardTemplateCopyWithImpl;
@useResult
$Res call({
 int id, String name, double cardWidthMm, double cardHeightMm, int pointCost, bool isActive, String? fileNamePattern, String frontImageBase64, String backImageBase64, DateTime createdAt
});




}
/// @nodoc
class _$CardTemplateCopyWithImpl<$Res>
    implements $CardTemplateCopyWith<$Res> {
  _$CardTemplateCopyWithImpl(this._self, this._then);

  final CardTemplate _self;
  final $Res Function(CardTemplate) _then;

/// Create a copy of CardTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? cardWidthMm = null,Object? cardHeightMm = null,Object? pointCost = null,Object? isActive = null,Object? fileNamePattern = freezed,Object? frontImageBase64 = null,Object? backImageBase64 = null,Object? createdAt = null,}) {
  return _then(CardTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cardWidthMm: null == cardWidthMm ? _self.cardWidthMm : cardWidthMm // ignore: cast_nullable_to_non_nullable
as double,cardHeightMm: null == cardHeightMm ? _self.cardHeightMm : cardHeightMm // ignore: cast_nullable_to_non_nullable
as double,pointCost: null == pointCost ? _self.pointCost : pointCost // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,fileNamePattern: freezed == fileNamePattern ? _self.fileNamePattern : fileNamePattern // ignore: cast_nullable_to_non_nullable
as String?,frontImageBase64: null == frontImageBase64 ? _self.frontImageBase64 : frontImageBase64 // ignore: cast_nullable_to_non_nullable
as String,backImageBase64: null == backImageBase64 ? _self.backImageBase64 : backImageBase64 // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CardTemplate].
extension CardTemplatePatterns on CardTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardTemplate value)  $default,){
final _that = this;
switch (_that) {
case _CardTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _CardTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  double cardWidthMm,  double cardHeightMm,  int pointCost,  bool isActive,  String? fileNamePattern,  String frontImageBase64,  String backImageBase64,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardTemplate() when $default != null:
return $default(_that.id,_that.name,_that.cardWidthMm,_that.cardHeightMm,_that.pointCost,_that.isActive,_that.fileNamePattern,_that.frontImageBase64,_that.backImageBase64,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  double cardWidthMm,  double cardHeightMm,  int pointCost,  bool isActive,  String? fileNamePattern,  String frontImageBase64,  String backImageBase64,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _CardTemplate():
return $default(_that.id,_that.name,_that.cardWidthMm,_that.cardHeightMm,_that.pointCost,_that.isActive,_that.fileNamePattern,_that.frontImageBase64,_that.backImageBase64,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  double cardWidthMm,  double cardHeightMm,  int pointCost,  bool isActive,  String? fileNamePattern,  String frontImageBase64,  String backImageBase64,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CardTemplate() when $default != null:
return $default(_that.id,_that.name,_that.cardWidthMm,_that.cardHeightMm,_that.pointCost,_that.isActive,_that.fileNamePattern,_that.frontImageBase64,_that.backImageBase64,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _CardTemplate implements CardTemplate {
  const _CardTemplate({required this.id, required this.name, required this.cardWidthMm, required this.cardHeightMm, required this.pointCost, required this.isActive, this.fileNamePattern, required this.frontImageBase64, required this.backImageBase64, required this.createdAt});
  

@override final  int id;
@override final  String name;
@override final  double cardWidthMm;
@override final  double cardHeightMm;
@override final  int pointCost;
@override final  bool isActive;
/// What a downloaded card PDF is called - the member's PDF fields as {Field}, e.g.
/// '{Name} - {Card No}'. Null means "card-<id>".
@override final  String? fileNamePattern;
@override final  String frontImageBase64;
@override final  String backImageBase64;
@override final  DateTime createdAt;

/// Create a copy of CardTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardTemplateCopyWith<_CardTemplate> get copyWith => __$CardTemplateCopyWithImpl<_CardTemplate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cardWidthMm, cardWidthMm) || other.cardWidthMm == cardWidthMm)&&(identical(other.cardHeightMm, cardHeightMm) || other.cardHeightMm == cardHeightMm)&&(identical(other.pointCost, pointCost) || other.pointCost == pointCost)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.fileNamePattern, fileNamePattern) || other.fileNamePattern == fileNamePattern)&&(identical(other.frontImageBase64, frontImageBase64) || other.frontImageBase64 == frontImageBase64)&&(identical(other.backImageBase64, backImageBase64) || other.backImageBase64 == backImageBase64)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,cardWidthMm,cardHeightMm,pointCost,isActive,fileNamePattern,frontImageBase64,backImageBase64,createdAt);
}

@override
String toString() {
    return 'CardTemplate(id: $id, name: $name, cardWidthMm: $cardWidthMm, cardHeightMm: $cardHeightMm, pointCost: $pointCost, isActive: $isActive, fileNamePattern: $fileNamePattern, frontImageBase64: $frontImageBase64, backImageBase64: $backImageBase64, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CardTemplateCopyWith<$Res> implements $CardTemplateCopyWith<$Res> {
  factory _$CardTemplateCopyWith(_CardTemplate value, $Res Function(_CardTemplate) _then) = __$CardTemplateCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, double cardWidthMm, double cardHeightMm, int pointCost, bool isActive, String? fileNamePattern, String frontImageBase64, String backImageBase64, DateTime createdAt
});




}
/// @nodoc
class __$CardTemplateCopyWithImpl<$Res>
    implements _$CardTemplateCopyWith<$Res> {
  __$CardTemplateCopyWithImpl(this._self, this._then);

  final _CardTemplate _self;
  final $Res Function(_CardTemplate) _then;

/// Create a copy of CardTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? cardWidthMm = null,Object? cardHeightMm = null,Object? pointCost = null,Object? isActive = null,Object? fileNamePattern = freezed,Object? frontImageBase64 = null,Object? backImageBase64 = null,Object? createdAt = null,}) {
  return _then(_CardTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cardWidthMm: null == cardWidthMm ? _self.cardWidthMm : cardWidthMm // ignore: cast_nullable_to_non_nullable
as double,cardHeightMm: null == cardHeightMm ? _self.cardHeightMm : cardHeightMm // ignore: cast_nullable_to_non_nullable
as double,pointCost: null == pointCost ? _self.pointCost : pointCost // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,fileNamePattern: freezed == fileNamePattern ? _self.fileNamePattern : fileNamePattern // ignore: cast_nullable_to_non_nullable
as String?,frontImageBase64: null == frontImageBase64 ? _self.frontImageBase64 : frontImageBase64 // ignore: cast_nullable_to_non_nullable
as String,backImageBase64: null == backImageBase64 ? _self.backImageBase64 : backImageBase64 // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$CardTemplateDetail {

 CardTemplate get template; List<FieldGroup> get groups; List<TemplateLayer> get layers; List<Combination> get combinations;
/// Create a copy of CardTemplateDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardTemplateDetailCopyWith<CardTemplateDetail> get copyWith => _$CardTemplateDetailCopyWithImpl<CardTemplateDetail>(this as CardTemplateDetail, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CardTemplateDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardTemplateDetail&&(identical(other.template, _this.template) || other.template == _this.template)&&const DeepCollectionEquality().equals(other.groups, _this.groups)&&const DeepCollectionEquality().equals(other.layers, _this.layers)&&const DeepCollectionEquality().equals(other.combinations, _this.combinations));
}


@override
int get hashCode {
  final _this = this as CardTemplateDetail;
  return Object.hash(runtimeType,_this.template,const DeepCollectionEquality().hash(_this.groups),const DeepCollectionEquality().hash(_this.layers),const DeepCollectionEquality().hash(_this.combinations));
}

@override
String toString() {
  final _this = this as CardTemplateDetail;
  return 'CardTemplateDetail(template: ${_this.template}, groups: ${_this.groups}, layers: ${_this.layers}, combinations: ${_this.combinations})';
}


}

/// @nodoc
abstract mixin class $CardTemplateDetailCopyWith<$Res>  {
  factory $CardTemplateDetailCopyWith(CardTemplateDetail value, $Res Function(CardTemplateDetail) _then) = _$CardTemplateDetailCopyWithImpl;
@useResult
$Res call({
 CardTemplate template, List<FieldGroup> groups, List<TemplateLayer> layers, List<Combination> combinations
});


$CardTemplateCopyWith<$Res> get template;

}
/// @nodoc
class _$CardTemplateDetailCopyWithImpl<$Res>
    implements $CardTemplateDetailCopyWith<$Res> {
  _$CardTemplateDetailCopyWithImpl(this._self, this._then);

  final CardTemplateDetail _self;
  final $Res Function(CardTemplateDetail) _then;

/// Create a copy of CardTemplateDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? template = null,Object? groups = null,Object? layers = null,Object? combinations = null,}) {
  return _then(CardTemplateDetail(
template: null == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as CardTemplate,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<FieldGroup>,layers: null == layers ? _self.layers : layers // ignore: cast_nullable_to_non_nullable
as List<TemplateLayer>,combinations: null == combinations ? _self.combinations : combinations // ignore: cast_nullable_to_non_nullable
as List<Combination>,
  ));
}
/// Create a copy of CardTemplateDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardTemplateCopyWith<$Res> get template {
  
  return $CardTemplateCopyWith<$Res>(_self.template, (value) {
    return _then(_self.copyWith(template: value));
  });
}
}


/// Adds pattern-matching-related methods to [CardTemplateDetail].
extension CardTemplateDetailPatterns on CardTemplateDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardTemplateDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardTemplateDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardTemplateDetail value)  $default,){
final _that = this;
switch (_that) {
case _CardTemplateDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardTemplateDetail value)?  $default,){
final _that = this;
switch (_that) {
case _CardTemplateDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CardTemplate template,  List<FieldGroup> groups,  List<TemplateLayer> layers,  List<Combination> combinations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardTemplateDetail() when $default != null:
return $default(_that.template,_that.groups,_that.layers,_that.combinations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CardTemplate template,  List<FieldGroup> groups,  List<TemplateLayer> layers,  List<Combination> combinations)  $default,) {final _that = this;
switch (_that) {
case _CardTemplateDetail():
return $default(_that.template,_that.groups,_that.layers,_that.combinations);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CardTemplate template,  List<FieldGroup> groups,  List<TemplateLayer> layers,  List<Combination> combinations)?  $default,) {final _that = this;
switch (_that) {
case _CardTemplateDetail() when $default != null:
return $default(_that.template,_that.groups,_that.layers,_that.combinations);case _:
  return null;

}
}

}

/// @nodoc


class _CardTemplateDetail implements CardTemplateDetail {
  const _CardTemplateDetail({required this.template,  List<FieldGroup> groups = const <FieldGroup>[],  List<TemplateLayer> layers = const <TemplateLayer>[],  List<Combination> combinations = const <Combination>[]}): _groups = groups,_layers = layers,_combinations = combinations;
  

@override final  CardTemplate template;
 final  List<FieldGroup> _groups;
@override@JsonKey() List<FieldGroup> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}

 final  List<TemplateLayer> _layers;
@override@JsonKey() List<TemplateLayer> get layers {
  if (_layers is EqualUnmodifiableListView) return _layers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_layers);
}

 final  List<Combination> _combinations;
@override@JsonKey() List<Combination> get combinations {
  if (_combinations is EqualUnmodifiableListView) return _combinations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_combinations);
}


/// Create a copy of CardTemplateDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardTemplateDetailCopyWith<_CardTemplateDetail> get copyWith => __$CardTemplateDetailCopyWithImpl<_CardTemplateDetail>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardTemplateDetail&&(identical(other.template, template) || other.template == template)&&const DeepCollectionEquality().equals(other.groups, _groups)&&const DeepCollectionEquality().equals(other.layers, _layers)&&const DeepCollectionEquality().equals(other.combinations, _combinations));
}


@override
int get hashCode {
    return Object.hash(runtimeType,template,const DeepCollectionEquality().hash(_groups),const DeepCollectionEquality().hash(_layers),const DeepCollectionEquality().hash(_combinations));
}

@override
String toString() {
    return 'CardTemplateDetail(template: $template, groups: $groups, layers: $layers, combinations: $combinations)';
}


}

/// @nodoc
abstract mixin class _$CardTemplateDetailCopyWith<$Res> implements $CardTemplateDetailCopyWith<$Res> {
  factory _$CardTemplateDetailCopyWith(_CardTemplateDetail value, $Res Function(_CardTemplateDetail) _then) = __$CardTemplateDetailCopyWithImpl;
@override @useResult
$Res call({
 CardTemplate template, List<FieldGroup> groups, List<TemplateLayer> layers, List<Combination> combinations
});


@override $CardTemplateCopyWith<$Res> get template;

}
/// @nodoc
class __$CardTemplateDetailCopyWithImpl<$Res>
    implements _$CardTemplateDetailCopyWith<$Res> {
  __$CardTemplateDetailCopyWithImpl(this._self, this._then);

  final _CardTemplateDetail _self;
  final $Res Function(_CardTemplateDetail) _then;

/// Create a copy of CardTemplateDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? template = null,Object? groups = null,Object? layers = null,Object? combinations = null,}) {
  return _then(_CardTemplateDetail(
template: null == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as CardTemplate,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<FieldGroup>,layers: null == layers ? _self._layers : layers // ignore: cast_nullable_to_non_nullable
as List<TemplateLayer>,combinations: null == combinations ? _self._combinations : combinations // ignore: cast_nullable_to_non_nullable
as List<Combination>,
  ));
}

/// Create a copy of CardTemplateDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardTemplateCopyWith<$Res> get template {
  
  return $CardTemplateCopyWith<$Res>(_self.template, (value) {
    return _then(_self.copyWith(template: value));
  });
}
}

// dart format on

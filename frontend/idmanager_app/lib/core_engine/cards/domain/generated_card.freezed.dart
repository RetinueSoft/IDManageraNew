// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generated_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GeneratedCard {

 int get idCardId; List<TemplateLayer> get layers; double get cardWidthMm; double get cardHeightMm; String get frontImageBase64; String get backImageBase64;
/// Create a copy of GeneratedCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeneratedCardCopyWith<GeneratedCard> get copyWith => _$GeneratedCardCopyWithImpl<GeneratedCard>(this as GeneratedCard, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GeneratedCard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeneratedCard&&(identical(other.idCardId, _this.idCardId) || other.idCardId == _this.idCardId)&&const DeepCollectionEquality().equals(other.layers, _this.layers)&&(identical(other.cardWidthMm, _this.cardWidthMm) || other.cardWidthMm == _this.cardWidthMm)&&(identical(other.cardHeightMm, _this.cardHeightMm) || other.cardHeightMm == _this.cardHeightMm)&&(identical(other.frontImageBase64, _this.frontImageBase64) || other.frontImageBase64 == _this.frontImageBase64)&&(identical(other.backImageBase64, _this.backImageBase64) || other.backImageBase64 == _this.backImageBase64));
}


@override
int get hashCode {
  final _this = this as GeneratedCard;
  return Object.hash(runtimeType,_this.idCardId,const DeepCollectionEquality().hash(_this.layers),_this.cardWidthMm,_this.cardHeightMm,_this.frontImageBase64,_this.backImageBase64);
}

@override
String toString() {
  final _this = this as GeneratedCard;
  return 'GeneratedCard(idCardId: ${_this.idCardId}, layers: ${_this.layers}, cardWidthMm: ${_this.cardWidthMm}, cardHeightMm: ${_this.cardHeightMm}, frontImageBase64: ${_this.frontImageBase64}, backImageBase64: ${_this.backImageBase64})';
}


}

/// @nodoc
abstract mixin class $GeneratedCardCopyWith<$Res>  {
  factory $GeneratedCardCopyWith(GeneratedCard value, $Res Function(GeneratedCard) _then) = _$GeneratedCardCopyWithImpl;
@useResult
$Res call({
 int idCardId, List<TemplateLayer> layers, double cardWidthMm, double cardHeightMm, String frontImageBase64, String backImageBase64
});




}
/// @nodoc
class _$GeneratedCardCopyWithImpl<$Res>
    implements $GeneratedCardCopyWith<$Res> {
  _$GeneratedCardCopyWithImpl(this._self, this._then);

  final GeneratedCard _self;
  final $Res Function(GeneratedCard) _then;

/// Create a copy of GeneratedCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idCardId = null,Object? layers = null,Object? cardWidthMm = null,Object? cardHeightMm = null,Object? frontImageBase64 = null,Object? backImageBase64 = null,}) {
  return _then(GeneratedCard(
idCardId: null == idCardId ? _self.idCardId : idCardId // ignore: cast_nullable_to_non_nullable
as int,layers: null == layers ? _self.layers : layers // ignore: cast_nullable_to_non_nullable
as List<TemplateLayer>,cardWidthMm: null == cardWidthMm ? _self.cardWidthMm : cardWidthMm // ignore: cast_nullable_to_non_nullable
as double,cardHeightMm: null == cardHeightMm ? _self.cardHeightMm : cardHeightMm // ignore: cast_nullable_to_non_nullable
as double,frontImageBase64: null == frontImageBase64 ? _self.frontImageBase64 : frontImageBase64 // ignore: cast_nullable_to_non_nullable
as String,backImageBase64: null == backImageBase64 ? _self.backImageBase64 : backImageBase64 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GeneratedCard].
extension GeneratedCardPatterns on GeneratedCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeneratedCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeneratedCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeneratedCard value)  $default,){
final _that = this;
switch (_that) {
case _GeneratedCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeneratedCard value)?  $default,){
final _that = this;
switch (_that) {
case _GeneratedCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int idCardId,  List<TemplateLayer> layers,  double cardWidthMm,  double cardHeightMm,  String frontImageBase64,  String backImageBase64)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeneratedCard() when $default != null:
return $default(_that.idCardId,_that.layers,_that.cardWidthMm,_that.cardHeightMm,_that.frontImageBase64,_that.backImageBase64);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int idCardId,  List<TemplateLayer> layers,  double cardWidthMm,  double cardHeightMm,  String frontImageBase64,  String backImageBase64)  $default,) {final _that = this;
switch (_that) {
case _GeneratedCard():
return $default(_that.idCardId,_that.layers,_that.cardWidthMm,_that.cardHeightMm,_that.frontImageBase64,_that.backImageBase64);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int idCardId,  List<TemplateLayer> layers,  double cardWidthMm,  double cardHeightMm,  String frontImageBase64,  String backImageBase64)?  $default,) {final _that = this;
switch (_that) {
case _GeneratedCard() when $default != null:
return $default(_that.idCardId,_that.layers,_that.cardWidthMm,_that.cardHeightMm,_that.frontImageBase64,_that.backImageBase64);case _:
  return null;

}
}

}

/// @nodoc


class _GeneratedCard implements GeneratedCard {
  const _GeneratedCard({required this.idCardId,  List<TemplateLayer> layers = const <TemplateLayer>[], required this.cardWidthMm, required this.cardHeightMm, required this.frontImageBase64, required this.backImageBase64}): _layers = layers;
  

@override final  int idCardId;
 final  List<TemplateLayer> _layers;
@override@JsonKey() List<TemplateLayer> get layers {
  if (_layers is EqualUnmodifiableListView) return _layers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_layers);
}

@override final  double cardWidthMm;
@override final  double cardHeightMm;
@override final  String frontImageBase64;
@override final  String backImageBase64;

/// Create a copy of GeneratedCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeneratedCardCopyWith<_GeneratedCard> get copyWith => __$GeneratedCardCopyWithImpl<_GeneratedCard>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeneratedCard&&(identical(other.idCardId, idCardId) || other.idCardId == idCardId)&&const DeepCollectionEquality().equals(other.layers, _layers)&&(identical(other.cardWidthMm, cardWidthMm) || other.cardWidthMm == cardWidthMm)&&(identical(other.cardHeightMm, cardHeightMm) || other.cardHeightMm == cardHeightMm)&&(identical(other.frontImageBase64, frontImageBase64) || other.frontImageBase64 == frontImageBase64)&&(identical(other.backImageBase64, backImageBase64) || other.backImageBase64 == backImageBase64));
}


@override
int get hashCode {
    return Object.hash(runtimeType,idCardId,const DeepCollectionEquality().hash(_layers),cardWidthMm,cardHeightMm,frontImageBase64,backImageBase64);
}

@override
String toString() {
    return 'GeneratedCard(idCardId: $idCardId, layers: $layers, cardWidthMm: $cardWidthMm, cardHeightMm: $cardHeightMm, frontImageBase64: $frontImageBase64, backImageBase64: $backImageBase64)';
}


}

/// @nodoc
abstract mixin class _$GeneratedCardCopyWith<$Res> implements $GeneratedCardCopyWith<$Res> {
  factory _$GeneratedCardCopyWith(_GeneratedCard value, $Res Function(_GeneratedCard) _then) = __$GeneratedCardCopyWithImpl;
@override @useResult
$Res call({
 int idCardId, List<TemplateLayer> layers, double cardWidthMm, double cardHeightMm, String frontImageBase64, String backImageBase64
});




}
/// @nodoc
class __$GeneratedCardCopyWithImpl<$Res>
    implements _$GeneratedCardCopyWith<$Res> {
  __$GeneratedCardCopyWithImpl(this._self, this._then);

  final _GeneratedCard _self;
  final $Res Function(_GeneratedCard) _then;

/// Create a copy of GeneratedCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idCardId = null,Object? layers = null,Object? cardWidthMm = null,Object? cardHeightMm = null,Object? frontImageBase64 = null,Object? backImageBase64 = null,}) {
  return _then(_GeneratedCard(
idCardId: null == idCardId ? _self.idCardId : idCardId // ignore: cast_nullable_to_non_nullable
as int,layers: null == layers ? _self._layers : layers // ignore: cast_nullable_to_non_nullable
as List<TemplateLayer>,cardWidthMm: null == cardWidthMm ? _self.cardWidthMm : cardWidthMm // ignore: cast_nullable_to_non_nullable
as double,cardHeightMm: null == cardHeightMm ? _self.cardHeightMm : cardHeightMm // ignore: cast_nullable_to_non_nullable
as double,frontImageBase64: null == frontImageBase64 ? _self.frontImageBase64 : frontImageBase64 // ignore: cast_nullable_to_non_nullable
as String,backImageBase64: null == backImageBase64 ? _self.backImageBase64 : backImageBase64 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

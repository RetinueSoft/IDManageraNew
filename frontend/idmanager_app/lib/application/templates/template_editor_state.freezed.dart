// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_editor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TemplateEditorState {

 CardTemplateDetail get template; List<TemplateLayer> get layers; CardSide get side; String? get selectedGroupId; bool get isSaving;
/// Create a copy of TemplateEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateEditorStateCopyWith<TemplateEditorState> get copyWith => _$TemplateEditorStateCopyWithImpl<TemplateEditorState>(this as TemplateEditorState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TemplateEditorState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateEditorState&&(identical(other.template, _this.template) || other.template == _this.template)&&const DeepCollectionEquality().equals(other.layers, _this.layers)&&(identical(other.side, _this.side) || other.side == _this.side)&&(identical(other.selectedGroupId, _this.selectedGroupId) || other.selectedGroupId == _this.selectedGroupId)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving));
}


@override
int get hashCode {
  final _this = this as TemplateEditorState;
  return Object.hash(runtimeType,_this.template,const DeepCollectionEquality().hash(_this.layers),_this.side,_this.selectedGroupId,_this.isSaving);
}

@override
String toString() {
  final _this = this as TemplateEditorState;
  return 'TemplateEditorState(template: ${_this.template}, layers: ${_this.layers}, side: ${_this.side}, selectedGroupId: ${_this.selectedGroupId}, isSaving: ${_this.isSaving})';
}


}

/// @nodoc
abstract mixin class $TemplateEditorStateCopyWith<$Res>  {
  factory $TemplateEditorStateCopyWith(TemplateEditorState value, $Res Function(TemplateEditorState) _then) = _$TemplateEditorStateCopyWithImpl;
@useResult
$Res call({
 CardTemplateDetail template, List<TemplateLayer> layers, CardSide side, String? selectedGroupId, bool isSaving
});


$CardTemplateDetailCopyWith<$Res> get template;

}
/// @nodoc
class _$TemplateEditorStateCopyWithImpl<$Res>
    implements $TemplateEditorStateCopyWith<$Res> {
  _$TemplateEditorStateCopyWithImpl(this._self, this._then);

  final TemplateEditorState _self;
  final $Res Function(TemplateEditorState) _then;

/// Create a copy of TemplateEditorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? template = null,Object? layers = null,Object? side = null,Object? selectedGroupId = freezed,Object? isSaving = null,}) {
  return _then(TemplateEditorState(
template: null == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as CardTemplateDetail,layers: null == layers ? _self.layers : layers // ignore: cast_nullable_to_non_nullable
as List<TemplateLayer>,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as CardSide,selectedGroupId: freezed == selectedGroupId ? _self.selectedGroupId : selectedGroupId // ignore: cast_nullable_to_non_nullable
as String?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of TemplateEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardTemplateDetailCopyWith<$Res> get template {
  
  return $CardTemplateDetailCopyWith<$Res>(_self.template, (value) {
    return _then(_self.copyWith(template: value));
  });
}
}


/// Adds pattern-matching-related methods to [TemplateEditorState].
extension TemplateEditorStatePatterns on TemplateEditorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateEditorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateEditorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateEditorState value)  $default,){
final _that = this;
switch (_that) {
case _TemplateEditorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateEditorState value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateEditorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CardTemplateDetail template,  List<TemplateLayer> layers,  CardSide side,  String? selectedGroupId,  bool isSaving)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateEditorState() when $default != null:
return $default(_that.template,_that.layers,_that.side,_that.selectedGroupId,_that.isSaving);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CardTemplateDetail template,  List<TemplateLayer> layers,  CardSide side,  String? selectedGroupId,  bool isSaving)  $default,) {final _that = this;
switch (_that) {
case _TemplateEditorState():
return $default(_that.template,_that.layers,_that.side,_that.selectedGroupId,_that.isSaving);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CardTemplateDetail template,  List<TemplateLayer> layers,  CardSide side,  String? selectedGroupId,  bool isSaving)?  $default,) {final _that = this;
switch (_that) {
case _TemplateEditorState() when $default != null:
return $default(_that.template,_that.layers,_that.side,_that.selectedGroupId,_that.isSaving);case _:
  return null;

}
}

}

/// @nodoc


class _TemplateEditorState implements TemplateEditorState {
  const _TemplateEditorState({required this.template, required  List<TemplateLayer> layers, this.side = CardSide.front, this.selectedGroupId, this.isSaving = false}): _layers = layers;
  

@override final  CardTemplateDetail template;
 final  List<TemplateLayer> _layers;
@override List<TemplateLayer> get layers {
  if (_layers is EqualUnmodifiableListView) return _layers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_layers);
}

@override@JsonKey() final  CardSide side;
@override final  String? selectedGroupId;
@override@JsonKey() final  bool isSaving;

/// Create a copy of TemplateEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateEditorStateCopyWith<_TemplateEditorState> get copyWith => __$TemplateEditorStateCopyWithImpl<_TemplateEditorState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateEditorState&&(identical(other.template, template) || other.template == template)&&const DeepCollectionEquality().equals(other.layers, _layers)&&(identical(other.side, side) || other.side == side)&&(identical(other.selectedGroupId, selectedGroupId) || other.selectedGroupId == selectedGroupId)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving));
}


@override
int get hashCode {
    return Object.hash(runtimeType,template,const DeepCollectionEquality().hash(_layers),side,selectedGroupId,isSaving);
}

@override
String toString() {
    return 'TemplateEditorState(template: $template, layers: $layers, side: $side, selectedGroupId: $selectedGroupId, isSaving: $isSaving)';
}


}

/// @nodoc
abstract mixin class _$TemplateEditorStateCopyWith<$Res> implements $TemplateEditorStateCopyWith<$Res> {
  factory _$TemplateEditorStateCopyWith(_TemplateEditorState value, $Res Function(_TemplateEditorState) _then) = __$TemplateEditorStateCopyWithImpl;
@override @useResult
$Res call({
 CardTemplateDetail template, List<TemplateLayer> layers, CardSide side, String? selectedGroupId, bool isSaving
});


@override $CardTemplateDetailCopyWith<$Res> get template;

}
/// @nodoc
class __$TemplateEditorStateCopyWithImpl<$Res>
    implements _$TemplateEditorStateCopyWith<$Res> {
  __$TemplateEditorStateCopyWithImpl(this._self, this._then);

  final _TemplateEditorState _self;
  final $Res Function(_TemplateEditorState) _then;

/// Create a copy of TemplateEditorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? template = null,Object? layers = null,Object? side = null,Object? selectedGroupId = freezed,Object? isSaving = null,}) {
  return _then(_TemplateEditorState(
template: null == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as CardTemplateDetail,layers: null == layers ? _self._layers : layers // ignore: cast_nullable_to_non_nullable
as List<TemplateLayer>,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as CardSide,selectedGroupId: freezed == selectedGroupId ? _self.selectedGroupId : selectedGroupId // ignore: cast_nullable_to_non_nullable
as String?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of TemplateEditorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardTemplateDetailCopyWith<$Res> get template {
  
  return $CardTemplateDetailCopyWith<$Res>(_self.template, (value) {
    return _then(_self.copyWith(template: value));
  });
}
}

// dart format on

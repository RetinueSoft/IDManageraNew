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

 CardTemplateDetail get template; List<TemplateLayer> get layers;/// Fields extracted from the template's one sample PDF - the palette layers are added from.
 List<ExtractedField> get sampleFields;/// The side edits go to (add/delete layer, the layers list, the properties panel). In the
/// combined view it is the side of the layer last clicked.
 CardSide get side;/// Show the front and back cards side by side (the default), each editable.
 bool get combined;/// Which of the template's backgrounds is on show (0 = the template's own). Only changes
/// what the canvas is drawn on; the layers are the same on every background.
 int get selectedBackgroundId; String? get selectedGroupId; bool get isSaving;
/// Create a copy of TemplateEditorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateEditorStateCopyWith<TemplateEditorState> get copyWith => _$TemplateEditorStateCopyWithImpl<TemplateEditorState>(this as TemplateEditorState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TemplateEditorState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateEditorState&&(identical(other.template, _this.template) || other.template == _this.template)&&const DeepCollectionEquality().equals(other.layers, _this.layers)&&const DeepCollectionEquality().equals(other.sampleFields, _this.sampleFields)&&(identical(other.side, _this.side) || other.side == _this.side)&&(identical(other.combined, _this.combined) || other.combined == _this.combined)&&(identical(other.selectedBackgroundId, _this.selectedBackgroundId) || other.selectedBackgroundId == _this.selectedBackgroundId)&&(identical(other.selectedGroupId, _this.selectedGroupId) || other.selectedGroupId == _this.selectedGroupId)&&(identical(other.isSaving, _this.isSaving) || other.isSaving == _this.isSaving));
}


@override
int get hashCode {
  final _this = this as TemplateEditorState;
  return Object.hash(runtimeType,_this.template,const DeepCollectionEquality().hash(_this.layers),const DeepCollectionEquality().hash(_this.sampleFields),_this.side,_this.combined,_this.selectedBackgroundId,_this.selectedGroupId,_this.isSaving);
}

@override
String toString() {
  final _this = this as TemplateEditorState;
  return 'TemplateEditorState(template: ${_this.template}, layers: ${_this.layers}, sampleFields: ${_this.sampleFields}, side: ${_this.side}, combined: ${_this.combined}, selectedBackgroundId: ${_this.selectedBackgroundId}, selectedGroupId: ${_this.selectedGroupId}, isSaving: ${_this.isSaving})';
}


}

/// @nodoc
abstract mixin class $TemplateEditorStateCopyWith<$Res>  {
  factory $TemplateEditorStateCopyWith(TemplateEditorState value, $Res Function(TemplateEditorState) _then) = _$TemplateEditorStateCopyWithImpl;
@useResult
$Res call({
 CardTemplateDetail template, List<TemplateLayer> layers, List<ExtractedField> sampleFields, CardSide side, bool combined, int selectedBackgroundId, String? selectedGroupId, bool isSaving
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
@pragma('vm:prefer-inline') @override $Res call({Object? template = null,Object? layers = null,Object? sampleFields = null,Object? side = null,Object? combined = null,Object? selectedBackgroundId = null,Object? selectedGroupId = freezed,Object? isSaving = null,}) {
  return _then(TemplateEditorState(
template: null == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as CardTemplateDetail,layers: null == layers ? _self.layers : layers // ignore: cast_nullable_to_non_nullable
as List<TemplateLayer>,sampleFields: null == sampleFields ? _self.sampleFields : sampleFields // ignore: cast_nullable_to_non_nullable
as List<ExtractedField>,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as CardSide,combined: null == combined ? _self.combined : combined // ignore: cast_nullable_to_non_nullable
as bool,selectedBackgroundId: null == selectedBackgroundId ? _self.selectedBackgroundId : selectedBackgroundId // ignore: cast_nullable_to_non_nullable
as int,selectedGroupId: freezed == selectedGroupId ? _self.selectedGroupId : selectedGroupId // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CardTemplateDetail template,  List<TemplateLayer> layers,  List<ExtractedField> sampleFields,  CardSide side,  bool combined,  int selectedBackgroundId,  String? selectedGroupId,  bool isSaving)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateEditorState() when $default != null:
return $default(_that.template,_that.layers,_that.sampleFields,_that.side,_that.combined,_that.selectedBackgroundId,_that.selectedGroupId,_that.isSaving);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CardTemplateDetail template,  List<TemplateLayer> layers,  List<ExtractedField> sampleFields,  CardSide side,  bool combined,  int selectedBackgroundId,  String? selectedGroupId,  bool isSaving)  $default,) {final _that = this;
switch (_that) {
case _TemplateEditorState():
return $default(_that.template,_that.layers,_that.sampleFields,_that.side,_that.combined,_that.selectedBackgroundId,_that.selectedGroupId,_that.isSaving);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CardTemplateDetail template,  List<TemplateLayer> layers,  List<ExtractedField> sampleFields,  CardSide side,  bool combined,  int selectedBackgroundId,  String? selectedGroupId,  bool isSaving)?  $default,) {final _that = this;
switch (_that) {
case _TemplateEditorState() when $default != null:
return $default(_that.template,_that.layers,_that.sampleFields,_that.side,_that.combined,_that.selectedBackgroundId,_that.selectedGroupId,_that.isSaving);case _:
  return null;

}
}

}

/// @nodoc


class _TemplateEditorState implements TemplateEditorState {
  const _TemplateEditorState({required this.template, required  List<TemplateLayer> layers,  List<ExtractedField> sampleFields = const <ExtractedField>[], this.side = CardSide.front, this.combined = true, this.selectedBackgroundId = 0, this.selectedGroupId, this.isSaving = false}): _layers = layers,_sampleFields = sampleFields;
  

@override final  CardTemplateDetail template;
 final  List<TemplateLayer> _layers;
@override List<TemplateLayer> get layers {
  if (_layers is EqualUnmodifiableListView) return _layers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_layers);
}

/// Fields extracted from the template's one sample PDF - the palette layers are added from.
 final  List<ExtractedField> _sampleFields;
/// Fields extracted from the template's one sample PDF - the palette layers are added from.
@override@JsonKey() List<ExtractedField> get sampleFields {
  if (_sampleFields is EqualUnmodifiableListView) return _sampleFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sampleFields);
}

/// The side edits go to (add/delete layer, the layers list, the properties panel). In the
/// combined view it is the side of the layer last clicked.
@override@JsonKey() final  CardSide side;
/// Show the front and back cards side by side (the default), each editable.
@override@JsonKey() final  bool combined;
/// Which of the template's backgrounds is on show (0 = the template's own). Only changes
/// what the canvas is drawn on; the layers are the same on every background.
@override@JsonKey() final  int selectedBackgroundId;
@override final  String? selectedGroupId;
@override@JsonKey() final  bool isSaving;

/// Create a copy of TemplateEditorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateEditorStateCopyWith<_TemplateEditorState> get copyWith => __$TemplateEditorStateCopyWithImpl<_TemplateEditorState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateEditorState&&(identical(other.template, template) || other.template == template)&&const DeepCollectionEquality().equals(other.layers, _layers)&&const DeepCollectionEquality().equals(other.sampleFields, _sampleFields)&&(identical(other.side, side) || other.side == side)&&(identical(other.combined, combined) || other.combined == combined)&&(identical(other.selectedBackgroundId, selectedBackgroundId) || other.selectedBackgroundId == selectedBackgroundId)&&(identical(other.selectedGroupId, selectedGroupId) || other.selectedGroupId == selectedGroupId)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving));
}


@override
int get hashCode {
    return Object.hash(runtimeType,template,const DeepCollectionEquality().hash(_layers),const DeepCollectionEquality().hash(_sampleFields),side,combined,selectedBackgroundId,selectedGroupId,isSaving);
}

@override
String toString() {
    return 'TemplateEditorState(template: $template, layers: $layers, sampleFields: $sampleFields, side: $side, combined: $combined, selectedBackgroundId: $selectedBackgroundId, selectedGroupId: $selectedGroupId, isSaving: $isSaving)';
}


}

/// @nodoc
abstract mixin class _$TemplateEditorStateCopyWith<$Res> implements $TemplateEditorStateCopyWith<$Res> {
  factory _$TemplateEditorStateCopyWith(_TemplateEditorState value, $Res Function(_TemplateEditorState) _then) = __$TemplateEditorStateCopyWithImpl;
@override @useResult
$Res call({
 CardTemplateDetail template, List<TemplateLayer> layers, List<ExtractedField> sampleFields, CardSide side, bool combined, int selectedBackgroundId, String? selectedGroupId, bool isSaving
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
@override @pragma('vm:prefer-inline') $Res call({Object? template = null,Object? layers = null,Object? sampleFields = null,Object? side = null,Object? combined = null,Object? selectedBackgroundId = null,Object? selectedGroupId = freezed,Object? isSaving = null,}) {
  return _then(_TemplateEditorState(
template: null == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as CardTemplateDetail,layers: null == layers ? _self._layers : layers // ignore: cast_nullable_to_non_nullable
as List<TemplateLayer>,sampleFields: null == sampleFields ? _self._sampleFields : sampleFields // ignore: cast_nullable_to_non_nullable
as List<ExtractedField>,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as CardSide,combined: null == combined ? _self.combined : combined // ignore: cast_nullable_to_non_nullable
as bool,selectedBackgroundId: null == selectedBackgroundId ? _self.selectedBackgroundId : selectedBackgroundId // ignore: cast_nullable_to_non_nullable
as int,selectedGroupId: freezed == selectedGroupId ? _self.selectedGroupId : selectedGroupId // ignore: cast_nullable_to_non_nullable
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

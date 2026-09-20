// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'generate_card_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GenerateCardState {

 List<LookupOption> get templateOptions; int? get selectedTemplateId;/// The selected template with its backgrounds (its own plus any it has added).
 CardTemplateDetail? get template;/// The background the card is printed on (0 = the template's own). It can be switched
/// before and after previewing without generating again.
 int get selectedCombinationId; UploadedFile? get pdfFile; List<QrSlot> get qrSlots; Map<String, UploadedFile> get qrFiles; GeneratedCard? get result;/// The background [result] was generated with - what the download prints on. Choosing another
/// background does not change the preview until Preview is pressed again.
 int? get resultCombinationId;/// The preview works like the template designer's canvas: front and back side by side by
/// default, [side] is the card edits go to, and one layer can be selected and adjusted.
 CardSide get side; bool get combined; String? get selectedGroupId; bool get isBusy; String? get error;
/// Create a copy of GenerateCardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerateCardStateCopyWith<GenerateCardState> get copyWith => _$GenerateCardStateCopyWithImpl<GenerateCardState>(this as GenerateCardState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GenerateCardState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerateCardState&&const DeepCollectionEquality().equals(other.templateOptions, _this.templateOptions)&&(identical(other.selectedTemplateId, _this.selectedTemplateId) || other.selectedTemplateId == _this.selectedTemplateId)&&(identical(other.template, _this.template) || other.template == _this.template)&&(identical(other.selectedCombinationId, _this.selectedCombinationId) || other.selectedCombinationId == _this.selectedCombinationId)&&(identical(other.pdfFile, _this.pdfFile) || other.pdfFile == _this.pdfFile)&&const DeepCollectionEquality().equals(other.qrSlots, _this.qrSlots)&&const DeepCollectionEquality().equals(other.qrFiles, _this.qrFiles)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.resultCombinationId, _this.resultCombinationId) || other.resultCombinationId == _this.resultCombinationId)&&(identical(other.side, _this.side) || other.side == _this.side)&&(identical(other.combined, _this.combined) || other.combined == _this.combined)&&(identical(other.selectedGroupId, _this.selectedGroupId) || other.selectedGroupId == _this.selectedGroupId)&&(identical(other.isBusy, _this.isBusy) || other.isBusy == _this.isBusy)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as GenerateCardState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.templateOptions),_this.selectedTemplateId,_this.template,_this.selectedCombinationId,_this.pdfFile,const DeepCollectionEquality().hash(_this.qrSlots),const DeepCollectionEquality().hash(_this.qrFiles),_this.result,_this.resultCombinationId,_this.side,_this.combined,_this.selectedGroupId,_this.isBusy,_this.error);
}

@override
String toString() {
  final _this = this as GenerateCardState;
  return 'GenerateCardState(templateOptions: ${_this.templateOptions}, selectedTemplateId: ${_this.selectedTemplateId}, template: ${_this.template}, selectedCombinationId: ${_this.selectedCombinationId}, pdfFile: ${_this.pdfFile}, qrSlots: ${_this.qrSlots}, qrFiles: ${_this.qrFiles}, result: ${_this.result}, resultCombinationId: ${_this.resultCombinationId}, side: ${_this.side}, combined: ${_this.combined}, selectedGroupId: ${_this.selectedGroupId}, isBusy: ${_this.isBusy}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $GenerateCardStateCopyWith<$Res>  {
  factory $GenerateCardStateCopyWith(GenerateCardState value, $Res Function(GenerateCardState) _then) = _$GenerateCardStateCopyWithImpl;
@useResult
$Res call({
 List<LookupOption> templateOptions, int? selectedTemplateId, CardTemplateDetail? template, int selectedCombinationId, UploadedFile? pdfFile, List<QrSlot> qrSlots, Map<String, UploadedFile> qrFiles, GeneratedCard? result, int? resultCombinationId, CardSide side, bool combined, String? selectedGroupId, bool isBusy, String? error
});


$CardTemplateDetailCopyWith<$Res>? get template;$GeneratedCardCopyWith<$Res>? get result;

}
/// @nodoc
class _$GenerateCardStateCopyWithImpl<$Res>
    implements $GenerateCardStateCopyWith<$Res> {
  _$GenerateCardStateCopyWithImpl(this._self, this._then);

  final GenerateCardState _self;
  final $Res Function(GenerateCardState) _then;

/// Create a copy of GenerateCardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? templateOptions = null,Object? selectedTemplateId = freezed,Object? template = freezed,Object? selectedCombinationId = null,Object? pdfFile = freezed,Object? qrSlots = null,Object? qrFiles = null,Object? result = freezed,Object? resultCombinationId = freezed,Object? side = null,Object? combined = null,Object? selectedGroupId = freezed,Object? isBusy = null,Object? error = freezed,}) {
  return _then(GenerateCardState(
templateOptions: null == templateOptions ? _self.templateOptions : templateOptions // ignore: cast_nullable_to_non_nullable
as List<LookupOption>,selectedTemplateId: freezed == selectedTemplateId ? _self.selectedTemplateId : selectedTemplateId // ignore: cast_nullable_to_non_nullable
as int?,template: freezed == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as CardTemplateDetail?,selectedCombinationId: null == selectedCombinationId ? _self.selectedCombinationId : selectedCombinationId // ignore: cast_nullable_to_non_nullable
as int,pdfFile: freezed == pdfFile ? _self.pdfFile : pdfFile // ignore: cast_nullable_to_non_nullable
as UploadedFile?,qrSlots: null == qrSlots ? _self.qrSlots : qrSlots // ignore: cast_nullable_to_non_nullable
as List<QrSlot>,qrFiles: null == qrFiles ? _self.qrFiles : qrFiles // ignore: cast_nullable_to_non_nullable
as Map<String, UploadedFile>,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as GeneratedCard?,resultCombinationId: freezed == resultCombinationId ? _self.resultCombinationId : resultCombinationId // ignore: cast_nullable_to_non_nullable
as int?,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as CardSide,combined: null == combined ? _self.combined : combined // ignore: cast_nullable_to_non_nullable
as bool,selectedGroupId: freezed == selectedGroupId ? _self.selectedGroupId : selectedGroupId // ignore: cast_nullable_to_non_nullable
as String?,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of GenerateCardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardTemplateDetailCopyWith<$Res>? get template {
    if (_self.template == null) {
    return null;
  }

  return $CardTemplateDetailCopyWith<$Res>(_self.template!, (value) {
    return _then(_self.copyWith(template: value));
  });
}/// Create a copy of GenerateCardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneratedCardCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $GeneratedCardCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [GenerateCardState].
extension GenerateCardStatePatterns on GenerateCardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenerateCardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenerateCardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenerateCardState value)  $default,){
final _that = this;
switch (_that) {
case _GenerateCardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenerateCardState value)?  $default,){
final _that = this;
switch (_that) {
case _GenerateCardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LookupOption> templateOptions,  int? selectedTemplateId,  CardTemplateDetail? template,  int selectedCombinationId,  UploadedFile? pdfFile,  List<QrSlot> qrSlots,  Map<String, UploadedFile> qrFiles,  GeneratedCard? result,  int? resultCombinationId,  CardSide side,  bool combined,  String? selectedGroupId,  bool isBusy,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerateCardState() when $default != null:
return $default(_that.templateOptions,_that.selectedTemplateId,_that.template,_that.selectedCombinationId,_that.pdfFile,_that.qrSlots,_that.qrFiles,_that.result,_that.resultCombinationId,_that.side,_that.combined,_that.selectedGroupId,_that.isBusy,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LookupOption> templateOptions,  int? selectedTemplateId,  CardTemplateDetail? template,  int selectedCombinationId,  UploadedFile? pdfFile,  List<QrSlot> qrSlots,  Map<String, UploadedFile> qrFiles,  GeneratedCard? result,  int? resultCombinationId,  CardSide side,  bool combined,  String? selectedGroupId,  bool isBusy,  String? error)  $default,) {final _that = this;
switch (_that) {
case _GenerateCardState():
return $default(_that.templateOptions,_that.selectedTemplateId,_that.template,_that.selectedCombinationId,_that.pdfFile,_that.qrSlots,_that.qrFiles,_that.result,_that.resultCombinationId,_that.side,_that.combined,_that.selectedGroupId,_that.isBusy,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LookupOption> templateOptions,  int? selectedTemplateId,  CardTemplateDetail? template,  int selectedCombinationId,  UploadedFile? pdfFile,  List<QrSlot> qrSlots,  Map<String, UploadedFile> qrFiles,  GeneratedCard? result,  int? resultCombinationId,  CardSide side,  bool combined,  String? selectedGroupId,  bool isBusy,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _GenerateCardState() when $default != null:
return $default(_that.templateOptions,_that.selectedTemplateId,_that.template,_that.selectedCombinationId,_that.pdfFile,_that.qrSlots,_that.qrFiles,_that.result,_that.resultCombinationId,_that.side,_that.combined,_that.selectedGroupId,_that.isBusy,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GenerateCardState implements GenerateCardState {
  const _GenerateCardState({ List<LookupOption> templateOptions = const <LookupOption>[], this.selectedTemplateId, this.template, this.selectedCombinationId = 0, this.pdfFile,  List<QrSlot> qrSlots = const <QrSlot>[],  Map<String, UploadedFile> qrFiles = const <String, UploadedFile>{}, this.result, this.resultCombinationId, this.side = CardSide.front, this.combined = true, this.selectedGroupId, this.isBusy = false, this.error}): _templateOptions = templateOptions,_qrSlots = qrSlots,_qrFiles = qrFiles;
  

 final  List<LookupOption> _templateOptions;
@override@JsonKey() List<LookupOption> get templateOptions {
  if (_templateOptions is EqualUnmodifiableListView) return _templateOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_templateOptions);
}

@override final  int? selectedTemplateId;
/// The selected template with its backgrounds (its own plus any it has added).
@override final  CardTemplateDetail? template;
/// The background the card is printed on (0 = the template's own). It can be switched
/// before and after previewing without generating again.
@override@JsonKey() final  int selectedCombinationId;
@override final  UploadedFile? pdfFile;
 final  List<QrSlot> _qrSlots;
@override@JsonKey() List<QrSlot> get qrSlots {
  if (_qrSlots is EqualUnmodifiableListView) return _qrSlots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_qrSlots);
}

 final  Map<String, UploadedFile> _qrFiles;
@override@JsonKey() Map<String, UploadedFile> get qrFiles {
  if (_qrFiles is EqualUnmodifiableMapView) return _qrFiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_qrFiles);
}

@override final  GeneratedCard? result;
/// The background [result] was generated with - what the download prints on. Choosing another
/// background does not change the preview until Preview is pressed again.
@override final  int? resultCombinationId;
/// The preview works like the template designer's canvas: front and back side by side by
/// default, [side] is the card edits go to, and one layer can be selected and adjusted.
@override@JsonKey() final  CardSide side;
@override@JsonKey() final  bool combined;
@override final  String? selectedGroupId;
@override@JsonKey() final  bool isBusy;
@override final  String? error;

/// Create a copy of GenerateCardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerateCardStateCopyWith<_GenerateCardState> get copyWith => __$GenerateCardStateCopyWithImpl<_GenerateCardState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerateCardState&&const DeepCollectionEquality().equals(other.templateOptions, _templateOptions)&&(identical(other.selectedTemplateId, selectedTemplateId) || other.selectedTemplateId == selectedTemplateId)&&(identical(other.template, template) || other.template == template)&&(identical(other.selectedCombinationId, selectedCombinationId) || other.selectedCombinationId == selectedCombinationId)&&(identical(other.pdfFile, pdfFile) || other.pdfFile == pdfFile)&&const DeepCollectionEquality().equals(other.qrSlots, _qrSlots)&&const DeepCollectionEquality().equals(other.qrFiles, _qrFiles)&&(identical(other.result, result) || other.result == result)&&(identical(other.resultCombinationId, resultCombinationId) || other.resultCombinationId == resultCombinationId)&&(identical(other.side, side) || other.side == side)&&(identical(other.combined, combined) || other.combined == combined)&&(identical(other.selectedGroupId, selectedGroupId) || other.selectedGroupId == selectedGroupId)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_templateOptions),selectedTemplateId,template,selectedCombinationId,pdfFile,const DeepCollectionEquality().hash(_qrSlots),const DeepCollectionEquality().hash(_qrFiles),result,resultCombinationId,side,combined,selectedGroupId,isBusy,error);
}

@override
String toString() {
    return 'GenerateCardState(templateOptions: $templateOptions, selectedTemplateId: $selectedTemplateId, template: $template, selectedCombinationId: $selectedCombinationId, pdfFile: $pdfFile, qrSlots: $qrSlots, qrFiles: $qrFiles, result: $result, resultCombinationId: $resultCombinationId, side: $side, combined: $combined, selectedGroupId: $selectedGroupId, isBusy: $isBusy, error: $error)';
}


}

/// @nodoc
abstract mixin class _$GenerateCardStateCopyWith<$Res> implements $GenerateCardStateCopyWith<$Res> {
  factory _$GenerateCardStateCopyWith(_GenerateCardState value, $Res Function(_GenerateCardState) _then) = __$GenerateCardStateCopyWithImpl;
@override @useResult
$Res call({
 List<LookupOption> templateOptions, int? selectedTemplateId, CardTemplateDetail? template, int selectedCombinationId, UploadedFile? pdfFile, List<QrSlot> qrSlots, Map<String, UploadedFile> qrFiles, GeneratedCard? result, int? resultCombinationId, CardSide side, bool combined, String? selectedGroupId, bool isBusy, String? error
});


@override $CardTemplateDetailCopyWith<$Res>? get template;@override $GeneratedCardCopyWith<$Res>? get result;

}
/// @nodoc
class __$GenerateCardStateCopyWithImpl<$Res>
    implements _$GenerateCardStateCopyWith<$Res> {
  __$GenerateCardStateCopyWithImpl(this._self, this._then);

  final _GenerateCardState _self;
  final $Res Function(_GenerateCardState) _then;

/// Create a copy of GenerateCardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? templateOptions = null,Object? selectedTemplateId = freezed,Object? template = freezed,Object? selectedCombinationId = null,Object? pdfFile = freezed,Object? qrSlots = null,Object? qrFiles = null,Object? result = freezed,Object? resultCombinationId = freezed,Object? side = null,Object? combined = null,Object? selectedGroupId = freezed,Object? isBusy = null,Object? error = freezed,}) {
  return _then(_GenerateCardState(
templateOptions: null == templateOptions ? _self._templateOptions : templateOptions // ignore: cast_nullable_to_non_nullable
as List<LookupOption>,selectedTemplateId: freezed == selectedTemplateId ? _self.selectedTemplateId : selectedTemplateId // ignore: cast_nullable_to_non_nullable
as int?,template: freezed == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as CardTemplateDetail?,selectedCombinationId: null == selectedCombinationId ? _self.selectedCombinationId : selectedCombinationId // ignore: cast_nullable_to_non_nullable
as int,pdfFile: freezed == pdfFile ? _self.pdfFile : pdfFile // ignore: cast_nullable_to_non_nullable
as UploadedFile?,qrSlots: null == qrSlots ? _self._qrSlots : qrSlots // ignore: cast_nullable_to_non_nullable
as List<QrSlot>,qrFiles: null == qrFiles ? _self._qrFiles : qrFiles // ignore: cast_nullable_to_non_nullable
as Map<String, UploadedFile>,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as GeneratedCard?,resultCombinationId: freezed == resultCombinationId ? _self.resultCombinationId : resultCombinationId // ignore: cast_nullable_to_non_nullable
as int?,side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as CardSide,combined: null == combined ? _self.combined : combined // ignore: cast_nullable_to_non_nullable
as bool,selectedGroupId: freezed == selectedGroupId ? _self.selectedGroupId : selectedGroupId // ignore: cast_nullable_to_non_nullable
as String?,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of GenerateCardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardTemplateDetailCopyWith<$Res>? get template {
    if (_self.template == null) {
    return null;
  }

  return $CardTemplateDetailCopyWith<$Res>(_self.template!, (value) {
    return _then(_self.copyWith(template: value));
  });
}/// Create a copy of GenerateCardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeneratedCardCopyWith<$Res>? get result {
    if (_self.result == null) {
    return null;
  }

  return $GeneratedCardCopyWith<$Res>(_self.result!, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

// dart format on

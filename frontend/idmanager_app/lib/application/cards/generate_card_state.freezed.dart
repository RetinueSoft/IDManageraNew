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

 List<LookupOption> get templateOptions; int? get selectedTemplateId; List<LookupOption> get combinationOptions; int? get selectedCombinationId; UploadedFile? get pdfFile; GeneratedCard? get result; bool get isBusy; String? get error;
/// Create a copy of GenerateCardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenerateCardStateCopyWith<GenerateCardState> get copyWith => _$GenerateCardStateCopyWithImpl<GenerateCardState>(this as GenerateCardState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GenerateCardState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenerateCardState&&const DeepCollectionEquality().equals(other.templateOptions, _this.templateOptions)&&(identical(other.selectedTemplateId, _this.selectedTemplateId) || other.selectedTemplateId == _this.selectedTemplateId)&&const DeepCollectionEquality().equals(other.combinationOptions, _this.combinationOptions)&&(identical(other.selectedCombinationId, _this.selectedCombinationId) || other.selectedCombinationId == _this.selectedCombinationId)&&(identical(other.pdfFile, _this.pdfFile) || other.pdfFile == _this.pdfFile)&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.isBusy, _this.isBusy) || other.isBusy == _this.isBusy)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as GenerateCardState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.templateOptions),_this.selectedTemplateId,const DeepCollectionEquality().hash(_this.combinationOptions),_this.selectedCombinationId,_this.pdfFile,_this.result,_this.isBusy,_this.error);
}

@override
String toString() {
  final _this = this as GenerateCardState;
  return 'GenerateCardState(templateOptions: ${_this.templateOptions}, selectedTemplateId: ${_this.selectedTemplateId}, combinationOptions: ${_this.combinationOptions}, selectedCombinationId: ${_this.selectedCombinationId}, pdfFile: ${_this.pdfFile}, result: ${_this.result}, isBusy: ${_this.isBusy}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $GenerateCardStateCopyWith<$Res>  {
  factory $GenerateCardStateCopyWith(GenerateCardState value, $Res Function(GenerateCardState) _then) = _$GenerateCardStateCopyWithImpl;
@useResult
$Res call({
 List<LookupOption> templateOptions, int? selectedTemplateId, List<LookupOption> combinationOptions, int? selectedCombinationId, UploadedFile? pdfFile, GeneratedCard? result, bool isBusy, String? error
});


$GeneratedCardCopyWith<$Res>? get result;

}
/// @nodoc
class _$GenerateCardStateCopyWithImpl<$Res>
    implements $GenerateCardStateCopyWith<$Res> {
  _$GenerateCardStateCopyWithImpl(this._self, this._then);

  final GenerateCardState _self;
  final $Res Function(GenerateCardState) _then;

/// Create a copy of GenerateCardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? templateOptions = null,Object? selectedTemplateId = freezed,Object? combinationOptions = null,Object? selectedCombinationId = freezed,Object? pdfFile = freezed,Object? result = freezed,Object? isBusy = null,Object? error = freezed,}) {
  return _then(GenerateCardState(
templateOptions: null == templateOptions ? _self.templateOptions : templateOptions // ignore: cast_nullable_to_non_nullable
as List<LookupOption>,selectedTemplateId: freezed == selectedTemplateId ? _self.selectedTemplateId : selectedTemplateId // ignore: cast_nullable_to_non_nullable
as int?,combinationOptions: null == combinationOptions ? _self.combinationOptions : combinationOptions // ignore: cast_nullable_to_non_nullable
as List<LookupOption>,selectedCombinationId: freezed == selectedCombinationId ? _self.selectedCombinationId : selectedCombinationId // ignore: cast_nullable_to_non_nullable
as int?,pdfFile: freezed == pdfFile ? _self.pdfFile : pdfFile // ignore: cast_nullable_to_non_nullable
as UploadedFile?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as GeneratedCard?,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of GenerateCardState
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<LookupOption> templateOptions,  int? selectedTemplateId,  List<LookupOption> combinationOptions,  int? selectedCombinationId,  UploadedFile? pdfFile,  GeneratedCard? result,  bool isBusy,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenerateCardState() when $default != null:
return $default(_that.templateOptions,_that.selectedTemplateId,_that.combinationOptions,_that.selectedCombinationId,_that.pdfFile,_that.result,_that.isBusy,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<LookupOption> templateOptions,  int? selectedTemplateId,  List<LookupOption> combinationOptions,  int? selectedCombinationId,  UploadedFile? pdfFile,  GeneratedCard? result,  bool isBusy,  String? error)  $default,) {final _that = this;
switch (_that) {
case _GenerateCardState():
return $default(_that.templateOptions,_that.selectedTemplateId,_that.combinationOptions,_that.selectedCombinationId,_that.pdfFile,_that.result,_that.isBusy,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<LookupOption> templateOptions,  int? selectedTemplateId,  List<LookupOption> combinationOptions,  int? selectedCombinationId,  UploadedFile? pdfFile,  GeneratedCard? result,  bool isBusy,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _GenerateCardState() when $default != null:
return $default(_that.templateOptions,_that.selectedTemplateId,_that.combinationOptions,_that.selectedCombinationId,_that.pdfFile,_that.result,_that.isBusy,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _GenerateCardState implements GenerateCardState {
  const _GenerateCardState({ List<LookupOption> templateOptions = const <LookupOption>[], this.selectedTemplateId,  List<LookupOption> combinationOptions = const <LookupOption>[], this.selectedCombinationId, this.pdfFile, this.result, this.isBusy = false, this.error}): _templateOptions = templateOptions,_combinationOptions = combinationOptions;
  

 final  List<LookupOption> _templateOptions;
@override@JsonKey() List<LookupOption> get templateOptions {
  if (_templateOptions is EqualUnmodifiableListView) return _templateOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_templateOptions);
}

@override final  int? selectedTemplateId;
 final  List<LookupOption> _combinationOptions;
@override@JsonKey() List<LookupOption> get combinationOptions {
  if (_combinationOptions is EqualUnmodifiableListView) return _combinationOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_combinationOptions);
}

@override final  int? selectedCombinationId;
@override final  UploadedFile? pdfFile;
@override final  GeneratedCard? result;
@override@JsonKey() final  bool isBusy;
@override final  String? error;

/// Create a copy of GenerateCardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerateCardStateCopyWith<_GenerateCardState> get copyWith => __$GenerateCardStateCopyWithImpl<_GenerateCardState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerateCardState&&const DeepCollectionEquality().equals(other.templateOptions, _templateOptions)&&(identical(other.selectedTemplateId, selectedTemplateId) || other.selectedTemplateId == selectedTemplateId)&&const DeepCollectionEquality().equals(other.combinationOptions, _combinationOptions)&&(identical(other.selectedCombinationId, selectedCombinationId) || other.selectedCombinationId == selectedCombinationId)&&(identical(other.pdfFile, pdfFile) || other.pdfFile == pdfFile)&&(identical(other.result, result) || other.result == result)&&(identical(other.isBusy, isBusy) || other.isBusy == isBusy)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_templateOptions),selectedTemplateId,const DeepCollectionEquality().hash(_combinationOptions),selectedCombinationId,pdfFile,result,isBusy,error);
}

@override
String toString() {
    return 'GenerateCardState(templateOptions: $templateOptions, selectedTemplateId: $selectedTemplateId, combinationOptions: $combinationOptions, selectedCombinationId: $selectedCombinationId, pdfFile: $pdfFile, result: $result, isBusy: $isBusy, error: $error)';
}


}

/// @nodoc
abstract mixin class _$GenerateCardStateCopyWith<$Res> implements $GenerateCardStateCopyWith<$Res> {
  factory _$GenerateCardStateCopyWith(_GenerateCardState value, $Res Function(_GenerateCardState) _then) = __$GenerateCardStateCopyWithImpl;
@override @useResult
$Res call({
 List<LookupOption> templateOptions, int? selectedTemplateId, List<LookupOption> combinationOptions, int? selectedCombinationId, UploadedFile? pdfFile, GeneratedCard? result, bool isBusy, String? error
});


@override $GeneratedCardCopyWith<$Res>? get result;

}
/// @nodoc
class __$GenerateCardStateCopyWithImpl<$Res>
    implements _$GenerateCardStateCopyWith<$Res> {
  __$GenerateCardStateCopyWithImpl(this._self, this._then);

  final _GenerateCardState _self;
  final $Res Function(_GenerateCardState) _then;

/// Create a copy of GenerateCardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? templateOptions = null,Object? selectedTemplateId = freezed,Object? combinationOptions = null,Object? selectedCombinationId = freezed,Object? pdfFile = freezed,Object? result = freezed,Object? isBusy = null,Object? error = freezed,}) {
  return _then(_GenerateCardState(
templateOptions: null == templateOptions ? _self._templateOptions : templateOptions // ignore: cast_nullable_to_non_nullable
as List<LookupOption>,selectedTemplateId: freezed == selectedTemplateId ? _self.selectedTemplateId : selectedTemplateId // ignore: cast_nullable_to_non_nullable
as int?,combinationOptions: null == combinationOptions ? _self._combinationOptions : combinationOptions // ignore: cast_nullable_to_non_nullable
as List<LookupOption>,selectedCombinationId: freezed == selectedCombinationId ? _self.selectedCombinationId : selectedCombinationId // ignore: cast_nullable_to_non_nullable
as int?,pdfFile: freezed == pdfFile ? _self.pdfFile : pdfFile // ignore: cast_nullable_to_non_nullable
as UploadedFile?,result: freezed == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as GeneratedCard?,isBusy: null == isBusy ? _self.isBusy : isBusy // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of GenerateCardState
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

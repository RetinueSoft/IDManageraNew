// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template_layer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LayerSourceItem {

/// What is printed before the value ("key: value"); empty prints the value alone. Also the
/// PDF field this source reads, unless [sourceKey] says otherwise.
 String? get key;/// The field of the member's PDF this source reads its value from, when that is not
/// [key] - so a label can be hidden or different without losing the link to the PDF.
/// Null means "read [key]". A source with neither is fixed text, never overwritten.
 String? get sourceKey; String? get value; LayerFieldType get type;/// In a combined (List) layer: how this field joins the NEXT one - a
/// JoinSeparator wire name ('comma', 'dash', 'space', 'newline'). Null means comma.
 String? get separator;/// In a combined layer: this entry is not a field but one empty line.
 bool get emptyLine;
/// Create a copy of LayerSourceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LayerSourceItemCopyWith<LayerSourceItem> get copyWith => _$LayerSourceItemCopyWithImpl<LayerSourceItem>(this as LayerSourceItem, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LayerSourceItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LayerSourceItem&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.sourceKey, _this.sourceKey) || other.sourceKey == _this.sourceKey)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.separator, _this.separator) || other.separator == _this.separator)&&(identical(other.emptyLine, _this.emptyLine) || other.emptyLine == _this.emptyLine));
}


@override
int get hashCode {
  final _this = this as LayerSourceItem;
  return Object.hash(runtimeType,_this.key,_this.sourceKey,_this.value,_this.type,_this.separator,_this.emptyLine);
}

@override
String toString() {
  final _this = this as LayerSourceItem;
  return 'LayerSourceItem(key: ${_this.key}, sourceKey: ${_this.sourceKey}, value: ${_this.value}, type: ${_this.type}, separator: ${_this.separator}, emptyLine: ${_this.emptyLine})';
}


}

/// @nodoc
abstract mixin class $LayerSourceItemCopyWith<$Res>  {
  factory $LayerSourceItemCopyWith(LayerSourceItem value, $Res Function(LayerSourceItem) _then) = _$LayerSourceItemCopyWithImpl;
@useResult
$Res call({
 String? key, String? sourceKey, String? value, LayerFieldType type, String? separator, bool emptyLine
});




}
/// @nodoc
class _$LayerSourceItemCopyWithImpl<$Res>
    implements $LayerSourceItemCopyWith<$Res> {
  _$LayerSourceItemCopyWithImpl(this._self, this._then);

  final LayerSourceItem _self;
  final $Res Function(LayerSourceItem) _then;

/// Create a copy of LayerSourceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = freezed,Object? sourceKey = freezed,Object? value = freezed,Object? type = null,Object? separator = freezed,Object? emptyLine = null,}) {
  return _then(LayerSourceItem(
key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,sourceKey: freezed == sourceKey ? _self.sourceKey : sourceKey // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LayerFieldType,separator: freezed == separator ? _self.separator : separator // ignore: cast_nullable_to_non_nullable
as String?,emptyLine: null == emptyLine ? _self.emptyLine : emptyLine // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LayerSourceItem].
extension LayerSourceItemPatterns on LayerSourceItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LayerSourceItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LayerSourceItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LayerSourceItem value)  $default,){
final _that = this;
switch (_that) {
case _LayerSourceItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LayerSourceItem value)?  $default,){
final _that = this;
switch (_that) {
case _LayerSourceItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? key,  String? sourceKey,  String? value,  LayerFieldType type,  String? separator,  bool emptyLine)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LayerSourceItem() when $default != null:
return $default(_that.key,_that.sourceKey,_that.value,_that.type,_that.separator,_that.emptyLine);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? key,  String? sourceKey,  String? value,  LayerFieldType type,  String? separator,  bool emptyLine)  $default,) {final _that = this;
switch (_that) {
case _LayerSourceItem():
return $default(_that.key,_that.sourceKey,_that.value,_that.type,_that.separator,_that.emptyLine);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? key,  String? sourceKey,  String? value,  LayerFieldType type,  String? separator,  bool emptyLine)?  $default,) {final _that = this;
switch (_that) {
case _LayerSourceItem() when $default != null:
return $default(_that.key,_that.sourceKey,_that.value,_that.type,_that.separator,_that.emptyLine);case _:
  return null;

}
}

}

/// @nodoc


class _LayerSourceItem implements LayerSourceItem {
  const _LayerSourceItem({this.key, this.sourceKey, this.value, this.type = LayerFieldType.text, this.separator, this.emptyLine = false});
  

/// What is printed before the value ("key: value"); empty prints the value alone. Also the
/// PDF field this source reads, unless [sourceKey] says otherwise.
@override final  String? key;
/// The field of the member's PDF this source reads its value from, when that is not
/// [key] - so a label can be hidden or different without losing the link to the PDF.
/// Null means "read [key]". A source with neither is fixed text, never overwritten.
@override final  String? sourceKey;
@override final  String? value;
@override@JsonKey() final  LayerFieldType type;
/// In a combined (List) layer: how this field joins the NEXT one - a
/// JoinSeparator wire name ('comma', 'dash', 'space', 'newline'). Null means comma.
@override final  String? separator;
/// In a combined layer: this entry is not a field but one empty line.
@override@JsonKey() final  bool emptyLine;

/// Create a copy of LayerSourceItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LayerSourceItemCopyWith<_LayerSourceItem> get copyWith => __$LayerSourceItemCopyWithImpl<_LayerSourceItem>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LayerSourceItem&&(identical(other.key, key) || other.key == key)&&(identical(other.sourceKey, sourceKey) || other.sourceKey == sourceKey)&&(identical(other.value, value) || other.value == value)&&(identical(other.type, type) || other.type == type)&&(identical(other.separator, separator) || other.separator == separator)&&(identical(other.emptyLine, emptyLine) || other.emptyLine == emptyLine));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,sourceKey,value,type,separator,emptyLine);
}

@override
String toString() {
    return 'LayerSourceItem(key: $key, sourceKey: $sourceKey, value: $value, type: $type, separator: $separator, emptyLine: $emptyLine)';
}


}

/// @nodoc
abstract mixin class _$LayerSourceItemCopyWith<$Res> implements $LayerSourceItemCopyWith<$Res> {
  factory _$LayerSourceItemCopyWith(_LayerSourceItem value, $Res Function(_LayerSourceItem) _then) = __$LayerSourceItemCopyWithImpl;
@override @useResult
$Res call({
 String? key, String? sourceKey, String? value, LayerFieldType type, String? separator, bool emptyLine
});




}
/// @nodoc
class __$LayerSourceItemCopyWithImpl<$Res>
    implements _$LayerSourceItemCopyWith<$Res> {
  __$LayerSourceItemCopyWithImpl(this._self, this._then);

  final _LayerSourceItem _self;
  final $Res Function(_LayerSourceItem) _then;

/// Create a copy of LayerSourceItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = freezed,Object? sourceKey = freezed,Object? value = freezed,Object? type = null,Object? separator = freezed,Object? emptyLine = null,}) {
  return _then(_LayerSourceItem(
key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,sourceKey: freezed == sourceKey ? _self.sourceKey : sourceKey // ignore: cast_nullable_to_non_nullable
as String?,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LayerFieldType,separator: freezed == separator ? _self.separator : separator // ignore: cast_nullable_to_non_nullable
as String?,emptyLine: null == emptyLine ? _self.emptyLine : emptyLine // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$LayerGroup {

/// Client-side only identity for the designer canvas (drag/select/delete) -
/// never sent to or read from the backend, which has no concept of it.
 String get id; String get name; LayerFieldType get fieldType; double get xMm; double get yMm; double? get widthMm; double? get heightMm; double get fontSizePt; double get lineHeightMm; double? get keyWidthMm; double? get valueWidthMm; bool get bold;/// A combined group: all [sources] render as one text, each joined to the next by
/// its own separator.
 bool get isList;/// In a combined layer: extra space (mm) added between all of its lines, common
/// to the whole layer. 0 keeps the normal line spacing.
 double get lineGapMm;/// An image layer left empty in the template; the card generator fills it with an
/// image the user picks (a QR code). Its source's key names the slot, e.g. 'QR 1'.
 bool get isQr;/// Words stripped out of every field's value in this layer (e.g. 'எண்' from
/// 'எண் :117 கூளமடை'), whole words only, never from keys. One list per layer.
 List<String> get removeWords;/// In a combined layer: print each field on its own line with a bullet point.
 bool get bulletList; bool get emptyLineEveryAfter; bool get newLineAfterFirst; bool get newLineBeforeLast; bool get formatAsDate; bool get useDashSeparator; List<LayerSourceItem> get sources;
/// Create a copy of LayerGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LayerGroupCopyWith<LayerGroup> get copyWith => _$LayerGroupCopyWithImpl<LayerGroup>(this as LayerGroup, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LayerGroup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LayerGroup&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.fieldType, _this.fieldType) || other.fieldType == _this.fieldType)&&(identical(other.xMm, _this.xMm) || other.xMm == _this.xMm)&&(identical(other.yMm, _this.yMm) || other.yMm == _this.yMm)&&(identical(other.widthMm, _this.widthMm) || other.widthMm == _this.widthMm)&&(identical(other.heightMm, _this.heightMm) || other.heightMm == _this.heightMm)&&(identical(other.fontSizePt, _this.fontSizePt) || other.fontSizePt == _this.fontSizePt)&&(identical(other.lineHeightMm, _this.lineHeightMm) || other.lineHeightMm == _this.lineHeightMm)&&(identical(other.keyWidthMm, _this.keyWidthMm) || other.keyWidthMm == _this.keyWidthMm)&&(identical(other.valueWidthMm, _this.valueWidthMm) || other.valueWidthMm == _this.valueWidthMm)&&(identical(other.bold, _this.bold) || other.bold == _this.bold)&&(identical(other.isList, _this.isList) || other.isList == _this.isList)&&(identical(other.lineGapMm, _this.lineGapMm) || other.lineGapMm == _this.lineGapMm)&&(identical(other.isQr, _this.isQr) || other.isQr == _this.isQr)&&const DeepCollectionEquality().equals(other.removeWords, _this.removeWords)&&(identical(other.bulletList, _this.bulletList) || other.bulletList == _this.bulletList)&&(identical(other.emptyLineEveryAfter, _this.emptyLineEveryAfter) || other.emptyLineEveryAfter == _this.emptyLineEveryAfter)&&(identical(other.newLineAfterFirst, _this.newLineAfterFirst) || other.newLineAfterFirst == _this.newLineAfterFirst)&&(identical(other.newLineBeforeLast, _this.newLineBeforeLast) || other.newLineBeforeLast == _this.newLineBeforeLast)&&(identical(other.formatAsDate, _this.formatAsDate) || other.formatAsDate == _this.formatAsDate)&&(identical(other.useDashSeparator, _this.useDashSeparator) || other.useDashSeparator == _this.useDashSeparator)&&const DeepCollectionEquality().equals(other.sources, _this.sources));
}


@override
int get hashCode {
  final _this = this as LayerGroup;
  return Object.hashAll([runtimeType,_this.id,_this.name,_this.fieldType,_this.xMm,_this.yMm,_this.widthMm,_this.heightMm,_this.fontSizePt,_this.lineHeightMm,_this.keyWidthMm,_this.valueWidthMm,_this.bold,_this.isList,_this.lineGapMm,_this.isQr,const DeepCollectionEquality().hash(_this.removeWords),_this.bulletList,_this.emptyLineEveryAfter,_this.newLineAfterFirst,_this.newLineBeforeLast,_this.formatAsDate,_this.useDashSeparator,const DeepCollectionEquality().hash(_this.sources)]);
}

@override
String toString() {
  final _this = this as LayerGroup;
  return 'LayerGroup(id: ${_this.id}, name: ${_this.name}, fieldType: ${_this.fieldType}, xMm: ${_this.xMm}, yMm: ${_this.yMm}, widthMm: ${_this.widthMm}, heightMm: ${_this.heightMm}, fontSizePt: ${_this.fontSizePt}, lineHeightMm: ${_this.lineHeightMm}, keyWidthMm: ${_this.keyWidthMm}, valueWidthMm: ${_this.valueWidthMm}, bold: ${_this.bold}, isList: ${_this.isList}, lineGapMm: ${_this.lineGapMm}, isQr: ${_this.isQr}, removeWords: ${_this.removeWords}, bulletList: ${_this.bulletList}, emptyLineEveryAfter: ${_this.emptyLineEveryAfter}, newLineAfterFirst: ${_this.newLineAfterFirst}, newLineBeforeLast: ${_this.newLineBeforeLast}, formatAsDate: ${_this.formatAsDate}, useDashSeparator: ${_this.useDashSeparator}, sources: ${_this.sources})';
}


}

/// @nodoc
abstract mixin class $LayerGroupCopyWith<$Res>  {
  factory $LayerGroupCopyWith(LayerGroup value, $Res Function(LayerGroup) _then) = _$LayerGroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, LayerFieldType fieldType, double xMm, double yMm, double? widthMm, double? heightMm, double fontSizePt, double lineHeightMm, double? keyWidthMm, double? valueWidthMm, bool bold, bool isList, double lineGapMm, bool isQr, List<String> removeWords, bool bulletList, bool emptyLineEveryAfter, bool newLineAfterFirst, bool newLineBeforeLast, bool formatAsDate, bool useDashSeparator, List<LayerSourceItem> sources
});




}
/// @nodoc
class _$LayerGroupCopyWithImpl<$Res>
    implements $LayerGroupCopyWith<$Res> {
  _$LayerGroupCopyWithImpl(this._self, this._then);

  final LayerGroup _self;
  final $Res Function(LayerGroup) _then;

/// Create a copy of LayerGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? fieldType = null,Object? xMm = null,Object? yMm = null,Object? widthMm = freezed,Object? heightMm = freezed,Object? fontSizePt = null,Object? lineHeightMm = null,Object? keyWidthMm = freezed,Object? valueWidthMm = freezed,Object? bold = null,Object? isList = null,Object? lineGapMm = null,Object? isQr = null,Object? removeWords = null,Object? bulletList = null,Object? emptyLineEveryAfter = null,Object? newLineAfterFirst = null,Object? newLineBeforeLast = null,Object? formatAsDate = null,Object? useDashSeparator = null,Object? sources = null,}) {
  return _then(LayerGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fieldType: null == fieldType ? _self.fieldType : fieldType // ignore: cast_nullable_to_non_nullable
as LayerFieldType,xMm: null == xMm ? _self.xMm : xMm // ignore: cast_nullable_to_non_nullable
as double,yMm: null == yMm ? _self.yMm : yMm // ignore: cast_nullable_to_non_nullable
as double,widthMm: freezed == widthMm ? _self.widthMm : widthMm // ignore: cast_nullable_to_non_nullable
as double?,heightMm: freezed == heightMm ? _self.heightMm : heightMm // ignore: cast_nullable_to_non_nullable
as double?,fontSizePt: null == fontSizePt ? _self.fontSizePt : fontSizePt // ignore: cast_nullable_to_non_nullable
as double,lineHeightMm: null == lineHeightMm ? _self.lineHeightMm : lineHeightMm // ignore: cast_nullable_to_non_nullable
as double,keyWidthMm: freezed == keyWidthMm ? _self.keyWidthMm : keyWidthMm // ignore: cast_nullable_to_non_nullable
as double?,valueWidthMm: freezed == valueWidthMm ? _self.valueWidthMm : valueWidthMm // ignore: cast_nullable_to_non_nullable
as double?,bold: null == bold ? _self.bold : bold // ignore: cast_nullable_to_non_nullable
as bool,isList: null == isList ? _self.isList : isList // ignore: cast_nullable_to_non_nullable
as bool,lineGapMm: null == lineGapMm ? _self.lineGapMm : lineGapMm // ignore: cast_nullable_to_non_nullable
as double,isQr: null == isQr ? _self.isQr : isQr // ignore: cast_nullable_to_non_nullable
as bool,removeWords: null == removeWords ? _self.removeWords : removeWords // ignore: cast_nullable_to_non_nullable
as List<String>,bulletList: null == bulletList ? _self.bulletList : bulletList // ignore: cast_nullable_to_non_nullable
as bool,emptyLineEveryAfter: null == emptyLineEveryAfter ? _self.emptyLineEveryAfter : emptyLineEveryAfter // ignore: cast_nullable_to_non_nullable
as bool,newLineAfterFirst: null == newLineAfterFirst ? _self.newLineAfterFirst : newLineAfterFirst // ignore: cast_nullable_to_non_nullable
as bool,newLineBeforeLast: null == newLineBeforeLast ? _self.newLineBeforeLast : newLineBeforeLast // ignore: cast_nullable_to_non_nullable
as bool,formatAsDate: null == formatAsDate ? _self.formatAsDate : formatAsDate // ignore: cast_nullable_to_non_nullable
as bool,useDashSeparator: null == useDashSeparator ? _self.useDashSeparator : useDashSeparator // ignore: cast_nullable_to_non_nullable
as bool,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as List<LayerSourceItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [LayerGroup].
extension LayerGroupPatterns on LayerGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LayerGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LayerGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LayerGroup value)  $default,){
final _that = this;
switch (_that) {
case _LayerGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LayerGroup value)?  $default,){
final _that = this;
switch (_that) {
case _LayerGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  LayerFieldType fieldType,  double xMm,  double yMm,  double? widthMm,  double? heightMm,  double fontSizePt,  double lineHeightMm,  double? keyWidthMm,  double? valueWidthMm,  bool bold,  bool isList,  double lineGapMm,  bool isQr,  List<String> removeWords,  bool bulletList,  bool emptyLineEveryAfter,  bool newLineAfterFirst,  bool newLineBeforeLast,  bool formatAsDate,  bool useDashSeparator,  List<LayerSourceItem> sources)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LayerGroup() when $default != null:
return $default(_that.id,_that.name,_that.fieldType,_that.xMm,_that.yMm,_that.widthMm,_that.heightMm,_that.fontSizePt,_that.lineHeightMm,_that.keyWidthMm,_that.valueWidthMm,_that.bold,_that.isList,_that.lineGapMm,_that.isQr,_that.removeWords,_that.bulletList,_that.emptyLineEveryAfter,_that.newLineAfterFirst,_that.newLineBeforeLast,_that.formatAsDate,_that.useDashSeparator,_that.sources);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  LayerFieldType fieldType,  double xMm,  double yMm,  double? widthMm,  double? heightMm,  double fontSizePt,  double lineHeightMm,  double? keyWidthMm,  double? valueWidthMm,  bool bold,  bool isList,  double lineGapMm,  bool isQr,  List<String> removeWords,  bool bulletList,  bool emptyLineEveryAfter,  bool newLineAfterFirst,  bool newLineBeforeLast,  bool formatAsDate,  bool useDashSeparator,  List<LayerSourceItem> sources)  $default,) {final _that = this;
switch (_that) {
case _LayerGroup():
return $default(_that.id,_that.name,_that.fieldType,_that.xMm,_that.yMm,_that.widthMm,_that.heightMm,_that.fontSizePt,_that.lineHeightMm,_that.keyWidthMm,_that.valueWidthMm,_that.bold,_that.isList,_that.lineGapMm,_that.isQr,_that.removeWords,_that.bulletList,_that.emptyLineEveryAfter,_that.newLineAfterFirst,_that.newLineBeforeLast,_that.formatAsDate,_that.useDashSeparator,_that.sources);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  LayerFieldType fieldType,  double xMm,  double yMm,  double? widthMm,  double? heightMm,  double fontSizePt,  double lineHeightMm,  double? keyWidthMm,  double? valueWidthMm,  bool bold,  bool isList,  double lineGapMm,  bool isQr,  List<String> removeWords,  bool bulletList,  bool emptyLineEveryAfter,  bool newLineAfterFirst,  bool newLineBeforeLast,  bool formatAsDate,  bool useDashSeparator,  List<LayerSourceItem> sources)?  $default,) {final _that = this;
switch (_that) {
case _LayerGroup() when $default != null:
return $default(_that.id,_that.name,_that.fieldType,_that.xMm,_that.yMm,_that.widthMm,_that.heightMm,_that.fontSizePt,_that.lineHeightMm,_that.keyWidthMm,_that.valueWidthMm,_that.bold,_that.isList,_that.lineGapMm,_that.isQr,_that.removeWords,_that.bulletList,_that.emptyLineEveryAfter,_that.newLineAfterFirst,_that.newLineBeforeLast,_that.formatAsDate,_that.useDashSeparator,_that.sources);case _:
  return null;

}
}

}

/// @nodoc


class _LayerGroup implements LayerGroup {
  const _LayerGroup({required this.id, required this.name, this.fieldType = LayerFieldType.text, required this.xMm, required this.yMm, this.widthMm, this.heightMm, this.fontSizePt = 10, this.lineHeightMm = 5, this.keyWidthMm, this.valueWidthMm, this.bold = false, this.isList = false, this.lineGapMm = 0, this.isQr = false,  List<String> removeWords = const <String>[], this.bulletList = false, this.emptyLineEveryAfter = false, this.newLineAfterFirst = false, this.newLineBeforeLast = false, this.formatAsDate = false, this.useDashSeparator = false,  List<LayerSourceItem> sources = const <LayerSourceItem>[]}): _removeWords = removeWords,_sources = sources;
  

/// Client-side only identity for the designer canvas (drag/select/delete) -
/// never sent to or read from the backend, which has no concept of it.
@override final  String id;
@override final  String name;
@override@JsonKey() final  LayerFieldType fieldType;
@override final  double xMm;
@override final  double yMm;
@override final  double? widthMm;
@override final  double? heightMm;
@override@JsonKey() final  double fontSizePt;
@override@JsonKey() final  double lineHeightMm;
@override final  double? keyWidthMm;
@override final  double? valueWidthMm;
@override@JsonKey() final  bool bold;
/// A combined group: all [sources] render as one text, each joined to the next by
/// its own separator.
@override@JsonKey() final  bool isList;
/// In a combined layer: extra space (mm) added between all of its lines, common
/// to the whole layer. 0 keeps the normal line spacing.
@override@JsonKey() final  double lineGapMm;
/// An image layer left empty in the template; the card generator fills it with an
/// image the user picks (a QR code). Its source's key names the slot, e.g. 'QR 1'.
@override@JsonKey() final  bool isQr;
/// Words stripped out of every field's value in this layer (e.g. 'எண்' from
/// 'எண் :117 கூளமடை'), whole words only, never from keys. One list per layer.
 final  List<String> _removeWords;
/// Words stripped out of every field's value in this layer (e.g. 'எண்' from
/// 'எண் :117 கூளமடை'), whole words only, never from keys. One list per layer.
@override@JsonKey() List<String> get removeWords {
  if (_removeWords is EqualUnmodifiableListView) return _removeWords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_removeWords);
}

/// In a combined layer: print each field on its own line with a bullet point.
@override@JsonKey() final  bool bulletList;
@override@JsonKey() final  bool emptyLineEveryAfter;
@override@JsonKey() final  bool newLineAfterFirst;
@override@JsonKey() final  bool newLineBeforeLast;
@override@JsonKey() final  bool formatAsDate;
@override@JsonKey() final  bool useDashSeparator;
 final  List<LayerSourceItem> _sources;
@override@JsonKey() List<LayerSourceItem> get sources {
  if (_sources is EqualUnmodifiableListView) return _sources;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sources);
}


/// Create a copy of LayerGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LayerGroupCopyWith<_LayerGroup> get copyWith => __$LayerGroupCopyWithImpl<_LayerGroup>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LayerGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.fieldType, fieldType) || other.fieldType == fieldType)&&(identical(other.xMm, xMm) || other.xMm == xMm)&&(identical(other.yMm, yMm) || other.yMm == yMm)&&(identical(other.widthMm, widthMm) || other.widthMm == widthMm)&&(identical(other.heightMm, heightMm) || other.heightMm == heightMm)&&(identical(other.fontSizePt, fontSizePt) || other.fontSizePt == fontSizePt)&&(identical(other.lineHeightMm, lineHeightMm) || other.lineHeightMm == lineHeightMm)&&(identical(other.keyWidthMm, keyWidthMm) || other.keyWidthMm == keyWidthMm)&&(identical(other.valueWidthMm, valueWidthMm) || other.valueWidthMm == valueWidthMm)&&(identical(other.bold, bold) || other.bold == bold)&&(identical(other.isList, isList) || other.isList == isList)&&(identical(other.lineGapMm, lineGapMm) || other.lineGapMm == lineGapMm)&&(identical(other.isQr, isQr) || other.isQr == isQr)&&const DeepCollectionEquality().equals(other.removeWords, _removeWords)&&(identical(other.bulletList, bulletList) || other.bulletList == bulletList)&&(identical(other.emptyLineEveryAfter, emptyLineEveryAfter) || other.emptyLineEveryAfter == emptyLineEveryAfter)&&(identical(other.newLineAfterFirst, newLineAfterFirst) || other.newLineAfterFirst == newLineAfterFirst)&&(identical(other.newLineBeforeLast, newLineBeforeLast) || other.newLineBeforeLast == newLineBeforeLast)&&(identical(other.formatAsDate, formatAsDate) || other.formatAsDate == formatAsDate)&&(identical(other.useDashSeparator, useDashSeparator) || other.useDashSeparator == useDashSeparator)&&const DeepCollectionEquality().equals(other.sources, _sources));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,name,fieldType,xMm,yMm,widthMm,heightMm,fontSizePt,lineHeightMm,keyWidthMm,valueWidthMm,bold,isList,lineGapMm,isQr,const DeepCollectionEquality().hash(_removeWords),bulletList,emptyLineEveryAfter,newLineAfterFirst,newLineBeforeLast,formatAsDate,useDashSeparator,const DeepCollectionEquality().hash(_sources)]);
}

@override
String toString() {
    return 'LayerGroup(id: $id, name: $name, fieldType: $fieldType, xMm: $xMm, yMm: $yMm, widthMm: $widthMm, heightMm: $heightMm, fontSizePt: $fontSizePt, lineHeightMm: $lineHeightMm, keyWidthMm: $keyWidthMm, valueWidthMm: $valueWidthMm, bold: $bold, isList: $isList, lineGapMm: $lineGapMm, isQr: $isQr, removeWords: $removeWords, bulletList: $bulletList, emptyLineEveryAfter: $emptyLineEveryAfter, newLineAfterFirst: $newLineAfterFirst, newLineBeforeLast: $newLineBeforeLast, formatAsDate: $formatAsDate, useDashSeparator: $useDashSeparator, sources: $sources)';
}


}

/// @nodoc
abstract mixin class _$LayerGroupCopyWith<$Res> implements $LayerGroupCopyWith<$Res> {
  factory _$LayerGroupCopyWith(_LayerGroup value, $Res Function(_LayerGroup) _then) = __$LayerGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, LayerFieldType fieldType, double xMm, double yMm, double? widthMm, double? heightMm, double fontSizePt, double lineHeightMm, double? keyWidthMm, double? valueWidthMm, bool bold, bool isList, double lineGapMm, bool isQr, List<String> removeWords, bool bulletList, bool emptyLineEveryAfter, bool newLineAfterFirst, bool newLineBeforeLast, bool formatAsDate, bool useDashSeparator, List<LayerSourceItem> sources
});




}
/// @nodoc
class __$LayerGroupCopyWithImpl<$Res>
    implements _$LayerGroupCopyWith<$Res> {
  __$LayerGroupCopyWithImpl(this._self, this._then);

  final _LayerGroup _self;
  final $Res Function(_LayerGroup) _then;

/// Create a copy of LayerGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? fieldType = null,Object? xMm = null,Object? yMm = null,Object? widthMm = freezed,Object? heightMm = freezed,Object? fontSizePt = null,Object? lineHeightMm = null,Object? keyWidthMm = freezed,Object? valueWidthMm = freezed,Object? bold = null,Object? isList = null,Object? lineGapMm = null,Object? isQr = null,Object? removeWords = null,Object? bulletList = null,Object? emptyLineEveryAfter = null,Object? newLineAfterFirst = null,Object? newLineBeforeLast = null,Object? formatAsDate = null,Object? useDashSeparator = null,Object? sources = null,}) {
  return _then(_LayerGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fieldType: null == fieldType ? _self.fieldType : fieldType // ignore: cast_nullable_to_non_nullable
as LayerFieldType,xMm: null == xMm ? _self.xMm : xMm // ignore: cast_nullable_to_non_nullable
as double,yMm: null == yMm ? _self.yMm : yMm // ignore: cast_nullable_to_non_nullable
as double,widthMm: freezed == widthMm ? _self.widthMm : widthMm // ignore: cast_nullable_to_non_nullable
as double?,heightMm: freezed == heightMm ? _self.heightMm : heightMm // ignore: cast_nullable_to_non_nullable
as double?,fontSizePt: null == fontSizePt ? _self.fontSizePt : fontSizePt // ignore: cast_nullable_to_non_nullable
as double,lineHeightMm: null == lineHeightMm ? _self.lineHeightMm : lineHeightMm // ignore: cast_nullable_to_non_nullable
as double,keyWidthMm: freezed == keyWidthMm ? _self.keyWidthMm : keyWidthMm // ignore: cast_nullable_to_non_nullable
as double?,valueWidthMm: freezed == valueWidthMm ? _self.valueWidthMm : valueWidthMm // ignore: cast_nullable_to_non_nullable
as double?,bold: null == bold ? _self.bold : bold // ignore: cast_nullable_to_non_nullable
as bool,isList: null == isList ? _self.isList : isList // ignore: cast_nullable_to_non_nullable
as bool,lineGapMm: null == lineGapMm ? _self.lineGapMm : lineGapMm // ignore: cast_nullable_to_non_nullable
as double,isQr: null == isQr ? _self.isQr : isQr // ignore: cast_nullable_to_non_nullable
as bool,removeWords: null == removeWords ? _self._removeWords : removeWords // ignore: cast_nullable_to_non_nullable
as List<String>,bulletList: null == bulletList ? _self.bulletList : bulletList // ignore: cast_nullable_to_non_nullable
as bool,emptyLineEveryAfter: null == emptyLineEveryAfter ? _self.emptyLineEveryAfter : emptyLineEveryAfter // ignore: cast_nullable_to_non_nullable
as bool,newLineAfterFirst: null == newLineAfterFirst ? _self.newLineAfterFirst : newLineAfterFirst // ignore: cast_nullable_to_non_nullable
as bool,newLineBeforeLast: null == newLineBeforeLast ? _self.newLineBeforeLast : newLineBeforeLast // ignore: cast_nullable_to_non_nullable
as bool,formatAsDate: null == formatAsDate ? _self.formatAsDate : formatAsDate // ignore: cast_nullable_to_non_nullable
as bool,useDashSeparator: null == useDashSeparator ? _self.useDashSeparator : useDashSeparator // ignore: cast_nullable_to_non_nullable
as bool,sources: null == sources ? _self._sources : sources // ignore: cast_nullable_to_non_nullable
as List<LayerSourceItem>,
  ));
}


}

/// @nodoc
mixin _$TemplateLayer {

 CardSide get side; List<LayerGroup> get groups;
/// Create a copy of TemplateLayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateLayerCopyWith<TemplateLayer> get copyWith => _$TemplateLayerCopyWithImpl<TemplateLayer>(this as TemplateLayer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TemplateLayer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateLayer&&(identical(other.side, _this.side) || other.side == _this.side)&&const DeepCollectionEquality().equals(other.groups, _this.groups));
}


@override
int get hashCode {
  final _this = this as TemplateLayer;
  return Object.hash(runtimeType,_this.side,const DeepCollectionEquality().hash(_this.groups));
}

@override
String toString() {
  final _this = this as TemplateLayer;
  return 'TemplateLayer(side: ${_this.side}, groups: ${_this.groups})';
}


}

/// @nodoc
abstract mixin class $TemplateLayerCopyWith<$Res>  {
  factory $TemplateLayerCopyWith(TemplateLayer value, $Res Function(TemplateLayer) _then) = _$TemplateLayerCopyWithImpl;
@useResult
$Res call({
 CardSide side, List<LayerGroup> groups
});




}
/// @nodoc
class _$TemplateLayerCopyWithImpl<$Res>
    implements $TemplateLayerCopyWith<$Res> {
  _$TemplateLayerCopyWithImpl(this._self, this._then);

  final TemplateLayer _self;
  final $Res Function(TemplateLayer) _then;

/// Create a copy of TemplateLayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? side = null,Object? groups = null,}) {
  return _then(TemplateLayer(
side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as CardSide,groups: null == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as List<LayerGroup>,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateLayer].
extension TemplateLayerPatterns on TemplateLayer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateLayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateLayer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateLayer value)  $default,){
final _that = this;
switch (_that) {
case _TemplateLayer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateLayer value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateLayer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CardSide side,  List<LayerGroup> groups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateLayer() when $default != null:
return $default(_that.side,_that.groups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CardSide side,  List<LayerGroup> groups)  $default,) {final _that = this;
switch (_that) {
case _TemplateLayer():
return $default(_that.side,_that.groups);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CardSide side,  List<LayerGroup> groups)?  $default,) {final _that = this;
switch (_that) {
case _TemplateLayer() when $default != null:
return $default(_that.side,_that.groups);case _:
  return null;

}
}

}

/// @nodoc


class _TemplateLayer implements TemplateLayer {
  const _TemplateLayer({required this.side,  List<LayerGroup> groups = const <LayerGroup>[]}): _groups = groups;
  

@override final  CardSide side;
 final  List<LayerGroup> _groups;
@override@JsonKey() List<LayerGroup> get groups {
  if (_groups is EqualUnmodifiableListView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groups);
}


/// Create a copy of TemplateLayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateLayerCopyWith<_TemplateLayer> get copyWith => __$TemplateLayerCopyWithImpl<_TemplateLayer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateLayer&&(identical(other.side, side) || other.side == side)&&const DeepCollectionEquality().equals(other.groups, _groups));
}


@override
int get hashCode {
    return Object.hash(runtimeType,side,const DeepCollectionEquality().hash(_groups));
}

@override
String toString() {
    return 'TemplateLayer(side: $side, groups: $groups)';
}


}

/// @nodoc
abstract mixin class _$TemplateLayerCopyWith<$Res> implements $TemplateLayerCopyWith<$Res> {
  factory _$TemplateLayerCopyWith(_TemplateLayer value, $Res Function(_TemplateLayer) _then) = __$TemplateLayerCopyWithImpl;
@override @useResult
$Res call({
 CardSide side, List<LayerGroup> groups
});




}
/// @nodoc
class __$TemplateLayerCopyWithImpl<$Res>
    implements _$TemplateLayerCopyWith<$Res> {
  __$TemplateLayerCopyWithImpl(this._self, this._then);

  final _TemplateLayer _self;
  final $Res Function(_TemplateLayer) _then;

/// Create a copy of TemplateLayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? side = null,Object? groups = null,}) {
  return _then(_TemplateLayer(
side: null == side ? _self.side : side // ignore: cast_nullable_to_non_nullable
as CardSide,groups: null == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as List<LayerGroup>,
  ));
}


}

// dart format on

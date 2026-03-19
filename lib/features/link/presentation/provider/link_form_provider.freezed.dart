// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link_form_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LinkFormState {

 String get url; String get title; String get description; String? get thumbnailUrl; String? get collectionId; String get memo; List<TagEntity> get tags; bool get isFavorite; bool get isParsingOg; bool get isSubmitting; String? get errorMessage;
/// Create a copy of LinkFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkFormStateCopyWith<LinkFormState> get copyWith => _$LinkFormStateCopyWithImpl<LinkFormState>(this as LinkFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkFormState&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.memo, memo) || other.memo == memo)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isParsingOg, isParsingOg) || other.isParsingOg == isParsingOg)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,url,title,description,thumbnailUrl,collectionId,memo,const DeepCollectionEquality().hash(tags),isFavorite,isParsingOg,isSubmitting,errorMessage);

@override
String toString() {
  return 'LinkFormState(url: $url, title: $title, description: $description, thumbnailUrl: $thumbnailUrl, collectionId: $collectionId, memo: $memo, tags: $tags, isFavorite: $isFavorite, isParsingOg: $isParsingOg, isSubmitting: $isSubmitting, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $LinkFormStateCopyWith<$Res>  {
  factory $LinkFormStateCopyWith(LinkFormState value, $Res Function(LinkFormState) _then) = _$LinkFormStateCopyWithImpl;
@useResult
$Res call({
 String url, String title, String description, String? thumbnailUrl, String? collectionId, String memo, List<TagEntity> tags, bool isFavorite, bool isParsingOg, bool isSubmitting, String? errorMessage
});




}
/// @nodoc
class _$LinkFormStateCopyWithImpl<$Res>
    implements $LinkFormStateCopyWith<$Res> {
  _$LinkFormStateCopyWithImpl(this._self, this._then);

  final LinkFormState _self;
  final $Res Function(LinkFormState) _then;

/// Create a copy of LinkFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? title = null,Object? description = null,Object? thumbnailUrl = freezed,Object? collectionId = freezed,Object? memo = null,Object? tags = null,Object? isFavorite = null,Object? isParsingOg = null,Object? isSubmitting = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,collectionId: freezed == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String?,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<TagEntity>,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isParsingOg: null == isParsingOg ? _self.isParsingOg : isParsingOg // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LinkFormState].
extension LinkFormStatePatterns on LinkFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkFormState value)  $default,){
final _that = this;
switch (_that) {
case _LinkFormState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkFormState value)?  $default,){
final _that = this;
switch (_that) {
case _LinkFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String title,  String description,  String? thumbnailUrl,  String? collectionId,  String memo,  List<TagEntity> tags,  bool isFavorite,  bool isParsingOg,  bool isSubmitting,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkFormState() when $default != null:
return $default(_that.url,_that.title,_that.description,_that.thumbnailUrl,_that.collectionId,_that.memo,_that.tags,_that.isFavorite,_that.isParsingOg,_that.isSubmitting,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String title,  String description,  String? thumbnailUrl,  String? collectionId,  String memo,  List<TagEntity> tags,  bool isFavorite,  bool isParsingOg,  bool isSubmitting,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _LinkFormState():
return $default(_that.url,_that.title,_that.description,_that.thumbnailUrl,_that.collectionId,_that.memo,_that.tags,_that.isFavorite,_that.isParsingOg,_that.isSubmitting,_that.errorMessage);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String title,  String description,  String? thumbnailUrl,  String? collectionId,  String memo,  List<TagEntity> tags,  bool isFavorite,  bool isParsingOg,  bool isSubmitting,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _LinkFormState() when $default != null:
return $default(_that.url,_that.title,_that.description,_that.thumbnailUrl,_that.collectionId,_that.memo,_that.tags,_that.isFavorite,_that.isParsingOg,_that.isSubmitting,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _LinkFormState implements LinkFormState {
  const _LinkFormState({this.url = '', this.title = '', this.description = '', this.thumbnailUrl, this.collectionId, this.memo = '', final  List<TagEntity> tags = const [], this.isFavorite = false, this.isParsingOg = false, this.isSubmitting = false, this.errorMessage}): _tags = tags;
  

@override@JsonKey() final  String url;
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override final  String? thumbnailUrl;
@override final  String? collectionId;
@override@JsonKey() final  String memo;
 final  List<TagEntity> _tags;
@override@JsonKey() List<TagEntity> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  bool isFavorite;
@override@JsonKey() final  bool isParsingOg;
@override@JsonKey() final  bool isSubmitting;
@override final  String? errorMessage;

/// Create a copy of LinkFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkFormStateCopyWith<_LinkFormState> get copyWith => __$LinkFormStateCopyWithImpl<_LinkFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkFormState&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.memo, memo) || other.memo == memo)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isParsingOg, isParsingOg) || other.isParsingOg == isParsingOg)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,url,title,description,thumbnailUrl,collectionId,memo,const DeepCollectionEquality().hash(_tags),isFavorite,isParsingOg,isSubmitting,errorMessage);

@override
String toString() {
  return 'LinkFormState(url: $url, title: $title, description: $description, thumbnailUrl: $thumbnailUrl, collectionId: $collectionId, memo: $memo, tags: $tags, isFavorite: $isFavorite, isParsingOg: $isParsingOg, isSubmitting: $isSubmitting, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$LinkFormStateCopyWith<$Res> implements $LinkFormStateCopyWith<$Res> {
  factory _$LinkFormStateCopyWith(_LinkFormState value, $Res Function(_LinkFormState) _then) = __$LinkFormStateCopyWithImpl;
@override @useResult
$Res call({
 String url, String title, String description, String? thumbnailUrl, String? collectionId, String memo, List<TagEntity> tags, bool isFavorite, bool isParsingOg, bool isSubmitting, String? errorMessage
});




}
/// @nodoc
class __$LinkFormStateCopyWithImpl<$Res>
    implements _$LinkFormStateCopyWith<$Res> {
  __$LinkFormStateCopyWithImpl(this._self, this._then);

  final _LinkFormState _self;
  final $Res Function(_LinkFormState) _then;

/// Create a copy of LinkFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? title = null,Object? description = null,Object? thumbnailUrl = freezed,Object? collectionId = freezed,Object? memo = null,Object? tags = null,Object? isFavorite = null,Object? isParsingOg = null,Object? isSubmitting = null,Object? errorMessage = freezed,}) {
  return _then(_LinkFormState(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,collectionId: freezed == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String?,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<TagEntity>,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isParsingOg: null == isParsingOg ? _self.isParsingOg : isParsingOg // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LinkDto {

 String get id;@JsonKey(name: 'user_id') String get userId; String get url; String get title;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt; String? get description;@JsonKey(name: 'thumbnail_url') String? get thumbnailUrl;@JsonKey(name: 'collection_id') String? get collectionId; String? get memo;@JsonKey(name: 'is_favorite') bool get isFavorite;@JsonKey(name: 'link_tags') List<LinkTagDto> get linkTags; CollectionNameDto? get collections;
/// Create a copy of LinkDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkDtoCopyWith<LinkDto> get copyWith => _$LinkDtoCopyWithImpl<LinkDto>(this as LinkDto, _$identity);

  /// Serializes this LinkDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&const DeepCollectionEquality().equals(other.linkTags, linkTags)&&(identical(other.collections, collections) || other.collections == collections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,url,title,createdAt,updatedAt,description,thumbnailUrl,collectionId,memo,isFavorite,const DeepCollectionEquality().hash(linkTags),collections);

@override
String toString() {
  return 'LinkDto(id: $id, userId: $userId, url: $url, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, thumbnailUrl: $thumbnailUrl, collectionId: $collectionId, memo: $memo, isFavorite: $isFavorite, linkTags: $linkTags, collections: $collections)';
}


}

/// @nodoc
abstract mixin class $LinkDtoCopyWith<$Res>  {
  factory $LinkDtoCopyWith(LinkDto value, $Res Function(LinkDto) _then) = _$LinkDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String url, String title,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, String? description,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'collection_id') String? collectionId, String? memo,@JsonKey(name: 'is_favorite') bool isFavorite,@JsonKey(name: 'link_tags') List<LinkTagDto> linkTags, CollectionNameDto? collections
});


$CollectionNameDtoCopyWith<$Res>? get collections;

}
/// @nodoc
class _$LinkDtoCopyWithImpl<$Res>
    implements $LinkDtoCopyWith<$Res> {
  _$LinkDtoCopyWithImpl(this._self, this._then);

  final LinkDto _self;
  final $Res Function(LinkDto) _then;

/// Create a copy of LinkDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? url = null,Object? title = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? thumbnailUrl = freezed,Object? collectionId = freezed,Object? memo = freezed,Object? isFavorite = null,Object? linkTags = null,Object? collections = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,collectionId: freezed == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String?,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,linkTags: null == linkTags ? _self.linkTags : linkTags // ignore: cast_nullable_to_non_nullable
as List<LinkTagDto>,collections: freezed == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as CollectionNameDto?,
  ));
}
/// Create a copy of LinkDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CollectionNameDtoCopyWith<$Res>? get collections {
    if (_self.collections == null) {
    return null;
  }

  return $CollectionNameDtoCopyWith<$Res>(_self.collections!, (value) {
    return _then(_self.copyWith(collections: value));
  });
}
}


/// Adds pattern-matching-related methods to [LinkDto].
extension LinkDtoPatterns on LinkDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkDto value)  $default,){
final _that = this;
switch (_that) {
case _LinkDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkDto value)?  $default,){
final _that = this;
switch (_that) {
case _LinkDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String url,  String title, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? description, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'collection_id')  String? collectionId,  String? memo, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'link_tags')  List<LinkTagDto> linkTags,  CollectionNameDto? collections)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkDto() when $default != null:
return $default(_that.id,_that.userId,_that.url,_that.title,_that.createdAt,_that.updatedAt,_that.description,_that.thumbnailUrl,_that.collectionId,_that.memo,_that.isFavorite,_that.linkTags,_that.collections);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String url,  String title, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? description, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'collection_id')  String? collectionId,  String? memo, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'link_tags')  List<LinkTagDto> linkTags,  CollectionNameDto? collections)  $default,) {final _that = this;
switch (_that) {
case _LinkDto():
return $default(_that.id,_that.userId,_that.url,_that.title,_that.createdAt,_that.updatedAt,_that.description,_that.thumbnailUrl,_that.collectionId,_that.memo,_that.isFavorite,_that.linkTags,_that.collections);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String url,  String title, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? description, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'collection_id')  String? collectionId,  String? memo, @JsonKey(name: 'is_favorite')  bool isFavorite, @JsonKey(name: 'link_tags')  List<LinkTagDto> linkTags,  CollectionNameDto? collections)?  $default,) {final _that = this;
switch (_that) {
case _LinkDto() when $default != null:
return $default(_that.id,_that.userId,_that.url,_that.title,_that.createdAt,_that.updatedAt,_that.description,_that.thumbnailUrl,_that.collectionId,_that.memo,_that.isFavorite,_that.linkTags,_that.collections);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LinkDto implements LinkDto {
  const _LinkDto({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.url, required this.title, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, this.description, @JsonKey(name: 'thumbnail_url') this.thumbnailUrl, @JsonKey(name: 'collection_id') this.collectionId, this.memo, @JsonKey(name: 'is_favorite') this.isFavorite = false, @JsonKey(name: 'link_tags') final  List<LinkTagDto> linkTags = const [], this.collections}): _linkTags = linkTags;
  factory _LinkDto.fromJson(Map<String, dynamic> json) => _$LinkDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String url;
@override final  String title;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
@override final  String? description;
@override@JsonKey(name: 'thumbnail_url') final  String? thumbnailUrl;
@override@JsonKey(name: 'collection_id') final  String? collectionId;
@override final  String? memo;
@override@JsonKey(name: 'is_favorite') final  bool isFavorite;
 final  List<LinkTagDto> _linkTags;
@override@JsonKey(name: 'link_tags') List<LinkTagDto> get linkTags {
  if (_linkTags is EqualUnmodifiableListView) return _linkTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_linkTags);
}

@override final  CollectionNameDto? collections;

/// Create a copy of LinkDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkDtoCopyWith<_LinkDto> get copyWith => __$LinkDtoCopyWithImpl<_LinkDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinkDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&const DeepCollectionEquality().equals(other._linkTags, _linkTags)&&(identical(other.collections, collections) || other.collections == collections));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,url,title,createdAt,updatedAt,description,thumbnailUrl,collectionId,memo,isFavorite,const DeepCollectionEquality().hash(_linkTags),collections);

@override
String toString() {
  return 'LinkDto(id: $id, userId: $userId, url: $url, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, thumbnailUrl: $thumbnailUrl, collectionId: $collectionId, memo: $memo, isFavorite: $isFavorite, linkTags: $linkTags, collections: $collections)';
}


}

/// @nodoc
abstract mixin class _$LinkDtoCopyWith<$Res> implements $LinkDtoCopyWith<$Res> {
  factory _$LinkDtoCopyWith(_LinkDto value, $Res Function(_LinkDto) _then) = __$LinkDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String url, String title,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, String? description,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'collection_id') String? collectionId, String? memo,@JsonKey(name: 'is_favorite') bool isFavorite,@JsonKey(name: 'link_tags') List<LinkTagDto> linkTags, CollectionNameDto? collections
});


@override $CollectionNameDtoCopyWith<$Res>? get collections;

}
/// @nodoc
class __$LinkDtoCopyWithImpl<$Res>
    implements _$LinkDtoCopyWith<$Res> {
  __$LinkDtoCopyWithImpl(this._self, this._then);

  final _LinkDto _self;
  final $Res Function(_LinkDto) _then;

/// Create a copy of LinkDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? url = null,Object? title = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? thumbnailUrl = freezed,Object? collectionId = freezed,Object? memo = freezed,Object? isFavorite = null,Object? linkTags = null,Object? collections = freezed,}) {
  return _then(_LinkDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,collectionId: freezed == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String?,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,linkTags: null == linkTags ? _self._linkTags : linkTags // ignore: cast_nullable_to_non_nullable
as List<LinkTagDto>,collections: freezed == collections ? _self.collections : collections // ignore: cast_nullable_to_non_nullable
as CollectionNameDto?,
  ));
}

/// Create a copy of LinkDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CollectionNameDtoCopyWith<$Res>? get collections {
    if (_self.collections == null) {
    return null;
  }

  return $CollectionNameDtoCopyWith<$Res>(_self.collections!, (value) {
    return _then(_self.copyWith(collections: value));
  });
}
}


/// @nodoc
mixin _$LinkTagDto {

 TagDto get tags;
/// Create a copy of LinkTagDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkTagDtoCopyWith<LinkTagDto> get copyWith => _$LinkTagDtoCopyWithImpl<LinkTagDto>(this as LinkTagDto, _$identity);

  /// Serializes this LinkTagDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkTagDto&&(identical(other.tags, tags) || other.tags == tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tags);

@override
String toString() {
  return 'LinkTagDto(tags: $tags)';
}


}

/// @nodoc
abstract mixin class $LinkTagDtoCopyWith<$Res>  {
  factory $LinkTagDtoCopyWith(LinkTagDto value, $Res Function(LinkTagDto) _then) = _$LinkTagDtoCopyWithImpl;
@useResult
$Res call({
 TagDto tags
});


$TagDtoCopyWith<$Res> get tags;

}
/// @nodoc
class _$LinkTagDtoCopyWithImpl<$Res>
    implements $LinkTagDtoCopyWith<$Res> {
  _$LinkTagDtoCopyWithImpl(this._self, this._then);

  final LinkTagDto _self;
  final $Res Function(LinkTagDto) _then;

/// Create a copy of LinkTagDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tags = null,}) {
  return _then(_self.copyWith(
tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as TagDto,
  ));
}
/// Create a copy of LinkTagDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TagDtoCopyWith<$Res> get tags {
  
  return $TagDtoCopyWith<$Res>(_self.tags, (value) {
    return _then(_self.copyWith(tags: value));
  });
}
}


/// Adds pattern-matching-related methods to [LinkTagDto].
extension LinkTagDtoPatterns on LinkTagDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkTagDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkTagDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkTagDto value)  $default,){
final _that = this;
switch (_that) {
case _LinkTagDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkTagDto value)?  $default,){
final _that = this;
switch (_that) {
case _LinkTagDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TagDto tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkTagDto() when $default != null:
return $default(_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TagDto tags)  $default,) {final _that = this;
switch (_that) {
case _LinkTagDto():
return $default(_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TagDto tags)?  $default,) {final _that = this;
switch (_that) {
case _LinkTagDto() when $default != null:
return $default(_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LinkTagDto implements LinkTagDto {
  const _LinkTagDto({required this.tags});
  factory _LinkTagDto.fromJson(Map<String, dynamic> json) => _$LinkTagDtoFromJson(json);

@override final  TagDto tags;

/// Create a copy of LinkTagDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkTagDtoCopyWith<_LinkTagDto> get copyWith => __$LinkTagDtoCopyWithImpl<_LinkTagDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinkTagDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkTagDto&&(identical(other.tags, tags) || other.tags == tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tags);

@override
String toString() {
  return 'LinkTagDto(tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$LinkTagDtoCopyWith<$Res> implements $LinkTagDtoCopyWith<$Res> {
  factory _$LinkTagDtoCopyWith(_LinkTagDto value, $Res Function(_LinkTagDto) _then) = __$LinkTagDtoCopyWithImpl;
@override @useResult
$Res call({
 TagDto tags
});


@override $TagDtoCopyWith<$Res> get tags;

}
/// @nodoc
class __$LinkTagDtoCopyWithImpl<$Res>
    implements _$LinkTagDtoCopyWith<$Res> {
  __$LinkTagDtoCopyWithImpl(this._self, this._then);

  final _LinkTagDto _self;
  final $Res Function(_LinkTagDto) _then;

/// Create a copy of LinkTagDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tags = null,}) {
  return _then(_LinkTagDto(
tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as TagDto,
  ));
}

/// Create a copy of LinkTagDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TagDtoCopyWith<$Res> get tags {
  
  return $TagDtoCopyWith<$Res>(_self.tags, (value) {
    return _then(_self.copyWith(tags: value));
  });
}
}


/// @nodoc
mixin _$TagDto {

 String get id; String get name; String get color;
/// Create a copy of TagDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagDtoCopyWith<TagDto> get copyWith => _$TagDtoCopyWithImpl<TagDto>(this as TagDto, _$identity);

  /// Serializes this TagDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color);

@override
String toString() {
  return 'TagDto(id: $id, name: $name, color: $color)';
}


}

/// @nodoc
abstract mixin class $TagDtoCopyWith<$Res>  {
  factory $TagDtoCopyWith(TagDto value, $Res Function(TagDto) _then) = _$TagDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String color
});




}
/// @nodoc
class _$TagDtoCopyWithImpl<$Res>
    implements $TagDtoCopyWith<$Res> {
  _$TagDtoCopyWithImpl(this._self, this._then);

  final TagDto _self;
  final $Res Function(TagDto) _then;

/// Create a copy of TagDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TagDto].
extension TagDtoPatterns on TagDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagDto value)  $default,){
final _that = this;
switch (_that) {
case _TagDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagDto value)?  $default,){
final _that = this;
switch (_that) {
case _TagDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagDto() when $default != null:
return $default(_that.id,_that.name,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String color)  $default,) {final _that = this;
switch (_that) {
case _TagDto():
return $default(_that.id,_that.name,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String color)?  $default,) {final _that = this;
switch (_that) {
case _TagDto() when $default != null:
return $default(_that.id,_that.name,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TagDto implements TagDto {
  const _TagDto({required this.id, required this.name, required this.color});
  factory _TagDto.fromJson(Map<String, dynamic> json) => _$TagDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String color;

/// Create a copy of TagDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagDtoCopyWith<_TagDto> get copyWith => __$TagDtoCopyWithImpl<_TagDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TagDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color);

@override
String toString() {
  return 'TagDto(id: $id, name: $name, color: $color)';
}


}

/// @nodoc
abstract mixin class _$TagDtoCopyWith<$Res> implements $TagDtoCopyWith<$Res> {
  factory _$TagDtoCopyWith(_TagDto value, $Res Function(_TagDto) _then) = __$TagDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String color
});




}
/// @nodoc
class __$TagDtoCopyWithImpl<$Res>
    implements _$TagDtoCopyWith<$Res> {
  __$TagDtoCopyWithImpl(this._self, this._then);

  final _TagDto _self;
  final $Res Function(_TagDto) _then;

/// Create a copy of TagDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = null,}) {
  return _then(_TagDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CollectionNameDto {

 String get name;
/// Create a copy of CollectionNameDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionNameDtoCopyWith<CollectionNameDto> get copyWith => _$CollectionNameDtoCopyWithImpl<CollectionNameDto>(this as CollectionNameDto, _$identity);

  /// Serializes this CollectionNameDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionNameDto&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'CollectionNameDto(name: $name)';
}


}

/// @nodoc
abstract mixin class $CollectionNameDtoCopyWith<$Res>  {
  factory $CollectionNameDtoCopyWith(CollectionNameDto value, $Res Function(CollectionNameDto) _then) = _$CollectionNameDtoCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$CollectionNameDtoCopyWithImpl<$Res>
    implements $CollectionNameDtoCopyWith<$Res> {
  _$CollectionNameDtoCopyWithImpl(this._self, this._then);

  final CollectionNameDto _self;
  final $Res Function(CollectionNameDto) _then;

/// Create a copy of CollectionNameDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CollectionNameDto].
extension CollectionNameDtoPatterns on CollectionNameDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionNameDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionNameDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionNameDto value)  $default,){
final _that = this;
switch (_that) {
case _CollectionNameDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionNameDto value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionNameDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionNameDto() when $default != null:
return $default(_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name)  $default,) {final _that = this;
switch (_that) {
case _CollectionNameDto():
return $default(_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name)?  $default,) {final _that = this;
switch (_that) {
case _CollectionNameDto() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CollectionNameDto implements CollectionNameDto {
  const _CollectionNameDto({required this.name});
  factory _CollectionNameDto.fromJson(Map<String, dynamic> json) => _$CollectionNameDtoFromJson(json);

@override final  String name;

/// Create a copy of CollectionNameDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionNameDtoCopyWith<_CollectionNameDto> get copyWith => __$CollectionNameDtoCopyWithImpl<_CollectionNameDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectionNameDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionNameDto&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'CollectionNameDto(name: $name)';
}


}

/// @nodoc
abstract mixin class _$CollectionNameDtoCopyWith<$Res> implements $CollectionNameDtoCopyWith<$Res> {
  factory _$CollectionNameDtoCopyWith(_CollectionNameDto value, $Res Function(_CollectionNameDto) _then) = __$CollectionNameDtoCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class __$CollectionNameDtoCopyWithImpl<$Res>
    implements _$CollectionNameDtoCopyWith<$Res> {
  __$CollectionNameDtoCopyWithImpl(this._self, this._then);

  final _CollectionNameDto _self;
  final $Res Function(_CollectionNameDto) _then;

/// Create a copy of CollectionNameDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(_CollectionNameDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

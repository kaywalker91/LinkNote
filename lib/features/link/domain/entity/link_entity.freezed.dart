// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LinkEntity {

 String get id; String get url; String get title; DateTime get createdAt; DateTime get updatedAt; String? get description; String? get thumbnailUrl; String? get collectionId; String? get collectionName; String? get memo; List<TagEntity> get tags; bool get isFavorite;
/// Create a copy of LinkEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkEntityCopyWith<LinkEntity> get copyWith => _$LinkEntityCopyWithImpl<LinkEntity>(this as LinkEntity, _$identity);

  /// Serializes this LinkEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.collectionName, collectionName) || other.collectionName == collectionName)&&(identical(other.memo, memo) || other.memo == memo)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,title,createdAt,updatedAt,description,thumbnailUrl,collectionId,collectionName,memo,const DeepCollectionEquality().hash(tags),isFavorite);

@override
String toString() {
  return 'LinkEntity(id: $id, url: $url, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, thumbnailUrl: $thumbnailUrl, collectionId: $collectionId, collectionName: $collectionName, memo: $memo, tags: $tags, isFavorite: $isFavorite)';
}


}

/// @nodoc
abstract mixin class $LinkEntityCopyWith<$Res>  {
  factory $LinkEntityCopyWith(LinkEntity value, $Res Function(LinkEntity) _then) = _$LinkEntityCopyWithImpl;
@useResult
$Res call({
 String id, String url, String title, DateTime createdAt, DateTime updatedAt, String? description, String? thumbnailUrl, String? collectionId, String? collectionName, String? memo, List<TagEntity> tags, bool isFavorite
});




}
/// @nodoc
class _$LinkEntityCopyWithImpl<$Res>
    implements $LinkEntityCopyWith<$Res> {
  _$LinkEntityCopyWithImpl(this._self, this._then);

  final LinkEntity _self;
  final $Res Function(LinkEntity) _then;

/// Create a copy of LinkEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = null,Object? title = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? thumbnailUrl = freezed,Object? collectionId = freezed,Object? collectionName = freezed,Object? memo = freezed,Object? tags = null,Object? isFavorite = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,collectionId: freezed == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String?,collectionName: freezed == collectionName ? _self.collectionName : collectionName // ignore: cast_nullable_to_non_nullable
as String?,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<TagEntity>,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LinkEntity].
extension LinkEntityPatterns on LinkEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkEntity value)  $default,){
final _that = this;
switch (_that) {
case _LinkEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkEntity value)?  $default,){
final _that = this;
switch (_that) {
case _LinkEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String url,  String title,  DateTime createdAt,  DateTime updatedAt,  String? description,  String? thumbnailUrl,  String? collectionId,  String? collectionName,  String? memo,  List<TagEntity> tags,  bool isFavorite)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkEntity() when $default != null:
return $default(_that.id,_that.url,_that.title,_that.createdAt,_that.updatedAt,_that.description,_that.thumbnailUrl,_that.collectionId,_that.collectionName,_that.memo,_that.tags,_that.isFavorite);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String url,  String title,  DateTime createdAt,  DateTime updatedAt,  String? description,  String? thumbnailUrl,  String? collectionId,  String? collectionName,  String? memo,  List<TagEntity> tags,  bool isFavorite)  $default,) {final _that = this;
switch (_that) {
case _LinkEntity():
return $default(_that.id,_that.url,_that.title,_that.createdAt,_that.updatedAt,_that.description,_that.thumbnailUrl,_that.collectionId,_that.collectionName,_that.memo,_that.tags,_that.isFavorite);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String url,  String title,  DateTime createdAt,  DateTime updatedAt,  String? description,  String? thumbnailUrl,  String? collectionId,  String? collectionName,  String? memo,  List<TagEntity> tags,  bool isFavorite)?  $default,) {final _that = this;
switch (_that) {
case _LinkEntity() when $default != null:
return $default(_that.id,_that.url,_that.title,_that.createdAt,_that.updatedAt,_that.description,_that.thumbnailUrl,_that.collectionId,_that.collectionName,_that.memo,_that.tags,_that.isFavorite);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LinkEntity implements LinkEntity {
  const _LinkEntity({required this.id, required this.url, required this.title, required this.createdAt, required this.updatedAt, this.description, this.thumbnailUrl, this.collectionId, this.collectionName, this.memo, final  List<TagEntity> tags = const [], this.isFavorite = false}): _tags = tags;
  factory _LinkEntity.fromJson(Map<String, dynamic> json) => _$LinkEntityFromJson(json);

@override final  String id;
@override final  String url;
@override final  String title;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? description;
@override final  String? thumbnailUrl;
@override final  String? collectionId;
@override final  String? collectionName;
@override final  String? memo;
 final  List<TagEntity> _tags;
@override@JsonKey() List<TagEntity> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  bool isFavorite;

/// Create a copy of LinkEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkEntityCopyWith<_LinkEntity> get copyWith => __$LinkEntityCopyWithImpl<_LinkEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinkEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.collectionName, collectionName) || other.collectionName == collectionName)&&(identical(other.memo, memo) || other.memo == memo)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,url,title,createdAt,updatedAt,description,thumbnailUrl,collectionId,collectionName,memo,const DeepCollectionEquality().hash(_tags),isFavorite);

@override
String toString() {
  return 'LinkEntity(id: $id, url: $url, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, thumbnailUrl: $thumbnailUrl, collectionId: $collectionId, collectionName: $collectionName, memo: $memo, tags: $tags, isFavorite: $isFavorite)';
}


}

/// @nodoc
abstract mixin class _$LinkEntityCopyWith<$Res> implements $LinkEntityCopyWith<$Res> {
  factory _$LinkEntityCopyWith(_LinkEntity value, $Res Function(_LinkEntity) _then) = __$LinkEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String url, String title, DateTime createdAt, DateTime updatedAt, String? description, String? thumbnailUrl, String? collectionId, String? collectionName, String? memo, List<TagEntity> tags, bool isFavorite
});




}
/// @nodoc
class __$LinkEntityCopyWithImpl<$Res>
    implements _$LinkEntityCopyWith<$Res> {
  __$LinkEntityCopyWithImpl(this._self, this._then);

  final _LinkEntity _self;
  final $Res Function(_LinkEntity) _then;

/// Create a copy of LinkEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = null,Object? title = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? thumbnailUrl = freezed,Object? collectionId = freezed,Object? collectionName = freezed,Object? memo = freezed,Object? tags = null,Object? isFavorite = null,}) {
  return _then(_LinkEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,collectionId: freezed == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String?,collectionName: freezed == collectionName ? _self.collectionName : collectionName // ignore: cast_nullable_to_non_nullable
as String?,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<TagEntity>,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

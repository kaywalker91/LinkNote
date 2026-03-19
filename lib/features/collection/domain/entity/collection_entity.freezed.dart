// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CollectionEntity {

 String get id; String get name; String? get description; String? get coverImageUrl; int get linkCount; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of CollectionEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionEntityCopyWith<CollectionEntity> get copyWith => _$CollectionEntityCopyWithImpl<CollectionEntity>(this as CollectionEntity, _$identity);

  /// Serializes this CollectionEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.linkCount, linkCount) || other.linkCount == linkCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,coverImageUrl,linkCount,createdAt,updatedAt);

@override
String toString() {
  return 'CollectionEntity(id: $id, name: $name, description: $description, coverImageUrl: $coverImageUrl, linkCount: $linkCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CollectionEntityCopyWith<$Res>  {
  factory $CollectionEntityCopyWith(CollectionEntity value, $Res Function(CollectionEntity) _then) = _$CollectionEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String? coverImageUrl, int linkCount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$CollectionEntityCopyWithImpl<$Res>
    implements $CollectionEntityCopyWith<$Res> {
  _$CollectionEntityCopyWithImpl(this._self, this._then);

  final CollectionEntity _self;
  final $Res Function(CollectionEntity) _then;

/// Create a copy of CollectionEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? coverImageUrl = freezed,Object? linkCount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,linkCount: null == linkCount ? _self.linkCount : linkCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CollectionEntity].
extension CollectionEntityPatterns on CollectionEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionEntity value)  $default,){
final _that = this;
switch (_that) {
case _CollectionEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionEntity value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? coverImageUrl,  int linkCount,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionEntity() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.coverImageUrl,_that.linkCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? coverImageUrl,  int linkCount,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CollectionEntity():
return $default(_that.id,_that.name,_that.description,_that.coverImageUrl,_that.linkCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String? coverImageUrl,  int linkCount,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CollectionEntity() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.coverImageUrl,_that.linkCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CollectionEntity implements CollectionEntity {
  const _CollectionEntity({required this.id, required this.name, this.description, this.coverImageUrl, this.linkCount = 0, required this.createdAt, required this.updatedAt});
  factory _CollectionEntity.fromJson(Map<String, dynamic> json) => _$CollectionEntityFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String? coverImageUrl;
@override@JsonKey() final  int linkCount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of CollectionEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionEntityCopyWith<_CollectionEntity> get copyWith => __$CollectionEntityCopyWithImpl<_CollectionEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectionEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.linkCount, linkCount) || other.linkCount == linkCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,coverImageUrl,linkCount,createdAt,updatedAt);

@override
String toString() {
  return 'CollectionEntity(id: $id, name: $name, description: $description, coverImageUrl: $coverImageUrl, linkCount: $linkCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CollectionEntityCopyWith<$Res> implements $CollectionEntityCopyWith<$Res> {
  factory _$CollectionEntityCopyWith(_CollectionEntity value, $Res Function(_CollectionEntity) _then) = __$CollectionEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String? coverImageUrl, int linkCount, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$CollectionEntityCopyWithImpl<$Res>
    implements _$CollectionEntityCopyWith<$Res> {
  __$CollectionEntityCopyWithImpl(this._self, this._then);

  final _CollectionEntity _self;
  final $Res Function(_CollectionEntity) _then;

/// Create a copy of CollectionEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? coverImageUrl = freezed,Object? linkCount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CollectionEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,linkCount: null == linkCount ? _self.linkCount : linkCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

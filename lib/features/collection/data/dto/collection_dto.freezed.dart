// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CollectionDto {

 String get id;@JsonKey(name: 'user_id') String get userId; String get name;@JsonKey(name: 'created_at') String get createdAt;@JsonKey(name: 'updated_at') String get updatedAt; String? get description;@JsonKey(name: 'cover_image_url') String? get coverImageUrl; List<LinkCountDto> get links;
/// Create a copy of CollectionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionDtoCopyWith<CollectionDto> get copyWith => _$CollectionDtoCopyWithImpl<CollectionDto>(this as CollectionDto, _$identity);

  /// Serializes this CollectionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&const DeepCollectionEquality().equals(other.links, links));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,createdAt,updatedAt,description,coverImageUrl,const DeepCollectionEquality().hash(links));

@override
String toString() {
  return 'CollectionDto(id: $id, userId: $userId, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, coverImageUrl: $coverImageUrl, links: $links)';
}


}

/// @nodoc
abstract mixin class $CollectionDtoCopyWith<$Res>  {
  factory $CollectionDtoCopyWith(CollectionDto value, $Res Function(CollectionDto) _then) = _$CollectionDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, String? description,@JsonKey(name: 'cover_image_url') String? coverImageUrl, List<LinkCountDto> links
});




}
/// @nodoc
class _$CollectionDtoCopyWithImpl<$Res>
    implements $CollectionDtoCopyWith<$Res> {
  _$CollectionDtoCopyWithImpl(this._self, this._then);

  final CollectionDto _self;
  final $Res Function(CollectionDto) _then;

/// Create a copy of CollectionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? coverImageUrl = freezed,Object? links = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as List<LinkCountDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [CollectionDto].
extension CollectionDtoPatterns on CollectionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionDto value)  $default,){
final _that = this;
switch (_that) {
case _CollectionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionDto value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? description, @JsonKey(name: 'cover_image_url')  String? coverImageUrl,  List<LinkCountDto> links)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionDto() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.createdAt,_that.updatedAt,_that.description,_that.coverImageUrl,_that.links);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? description, @JsonKey(name: 'cover_image_url')  String? coverImageUrl,  List<LinkCountDto> links)  $default,) {final _that = this;
switch (_that) {
case _CollectionDto():
return $default(_that.id,_that.userId,_that.name,_that.createdAt,_that.updatedAt,_that.description,_that.coverImageUrl,_that.links);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId,  String name, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'updated_at')  String updatedAt,  String? description, @JsonKey(name: 'cover_image_url')  String? coverImageUrl,  List<LinkCountDto> links)?  $default,) {final _that = this;
switch (_that) {
case _CollectionDto() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.createdAt,_that.updatedAt,_that.description,_that.coverImageUrl,_that.links);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CollectionDto implements CollectionDto {
  const _CollectionDto({required this.id, @JsonKey(name: 'user_id') required this.userId, required this.name, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt, this.description, @JsonKey(name: 'cover_image_url') this.coverImageUrl, final  List<LinkCountDto> links = const []}): _links = links;
  factory _CollectionDto.fromJson(Map<String, dynamic> json) => _$CollectionDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override final  String name;
@override@JsonKey(name: 'created_at') final  String createdAt;
@override@JsonKey(name: 'updated_at') final  String updatedAt;
@override final  String? description;
@override@JsonKey(name: 'cover_image_url') final  String? coverImageUrl;
 final  List<LinkCountDto> _links;
@override@JsonKey() List<LinkCountDto> get links {
  if (_links is EqualUnmodifiableListView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_links);
}


/// Create a copy of CollectionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionDtoCopyWith<_CollectionDto> get copyWith => __$CollectionDtoCopyWithImpl<_CollectionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&const DeepCollectionEquality().equals(other._links, _links));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,createdAt,updatedAt,description,coverImageUrl,const DeepCollectionEquality().hash(_links));

@override
String toString() {
  return 'CollectionDto(id: $id, userId: $userId, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, coverImageUrl: $coverImageUrl, links: $links)';
}


}

/// @nodoc
abstract mixin class _$CollectionDtoCopyWith<$Res> implements $CollectionDtoCopyWith<$Res> {
  factory _$CollectionDtoCopyWith(_CollectionDto value, $Res Function(_CollectionDto) _then) = __$CollectionDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId, String name,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'updated_at') String updatedAt, String? description,@JsonKey(name: 'cover_image_url') String? coverImageUrl, List<LinkCountDto> links
});




}
/// @nodoc
class __$CollectionDtoCopyWithImpl<$Res>
    implements _$CollectionDtoCopyWith<$Res> {
  __$CollectionDtoCopyWithImpl(this._self, this._then);

  final _CollectionDto _self;
  final $Res Function(_CollectionDto) _then;

/// Create a copy of CollectionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? coverImageUrl = freezed,Object? links = null,}) {
  return _then(_CollectionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as List<LinkCountDto>,
  ));
}


}


/// @nodoc
mixin _$LinkCountDto {

 int get count;
/// Create a copy of LinkCountDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkCountDtoCopyWith<LinkCountDto> get copyWith => _$LinkCountDtoCopyWithImpl<LinkCountDto>(this as LinkCountDto, _$identity);

  /// Serializes this LinkCountDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkCountDto&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count);

@override
String toString() {
  return 'LinkCountDto(count: $count)';
}


}

/// @nodoc
abstract mixin class $LinkCountDtoCopyWith<$Res>  {
  factory $LinkCountDtoCopyWith(LinkCountDto value, $Res Function(LinkCountDto) _then) = _$LinkCountDtoCopyWithImpl;
@useResult
$Res call({
 int count
});




}
/// @nodoc
class _$LinkCountDtoCopyWithImpl<$Res>
    implements $LinkCountDtoCopyWith<$Res> {
  _$LinkCountDtoCopyWithImpl(this._self, this._then);

  final LinkCountDto _self;
  final $Res Function(LinkCountDto) _then;

/// Create a copy of LinkCountDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LinkCountDto].
extension LinkCountDtoPatterns on LinkCountDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkCountDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkCountDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkCountDto value)  $default,){
final _that = this;
switch (_that) {
case _LinkCountDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkCountDto value)?  $default,){
final _that = this;
switch (_that) {
case _LinkCountDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkCountDto() when $default != null:
return $default(_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count)  $default,) {final _that = this;
switch (_that) {
case _LinkCountDto():
return $default(_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count)?  $default,) {final _that = this;
switch (_that) {
case _LinkCountDto() when $default != null:
return $default(_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LinkCountDto implements LinkCountDto {
  const _LinkCountDto({required this.count});
  factory _LinkCountDto.fromJson(Map<String, dynamic> json) => _$LinkCountDtoFromJson(json);

@override final  int count;

/// Create a copy of LinkCountDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkCountDtoCopyWith<_LinkCountDto> get copyWith => __$LinkCountDtoCopyWithImpl<_LinkCountDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinkCountDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkCountDto&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count);

@override
String toString() {
  return 'LinkCountDto(count: $count)';
}


}

/// @nodoc
abstract mixin class _$LinkCountDtoCopyWith<$Res> implements $LinkCountDtoCopyWith<$Res> {
  factory _$LinkCountDtoCopyWith(_LinkCountDto value, $Res Function(_LinkCountDto) _then) = __$LinkCountDtoCopyWithImpl;
@override @useResult
$Res call({
 int count
});




}
/// @nodoc
class __$LinkCountDtoCopyWithImpl<$Res>
    implements _$LinkCountDtoCopyWith<$Res> {
  __$LinkCountDtoCopyWithImpl(this._self, this._then);

  final _LinkCountDto _self;
  final $Res Function(_LinkCountDto) _then;

/// Create a copy of LinkCountDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,}) {
  return _then(_LinkCountDto(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_stats_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReadingStatsEntity {

 String get linkId; int get totalReads; DateTime? get lastReadAt;
/// Create a copy of ReadingStatsEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingStatsEntityCopyWith<ReadingStatsEntity> get copyWith => _$ReadingStatsEntityCopyWithImpl<ReadingStatsEntity>(this as ReadingStatsEntity, _$identity);

  /// Serializes this ReadingStatsEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingStatsEntity&&(identical(other.linkId, linkId) || other.linkId == linkId)&&(identical(other.totalReads, totalReads) || other.totalReads == totalReads)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,linkId,totalReads,lastReadAt);

@override
String toString() {
  return 'ReadingStatsEntity(linkId: $linkId, totalReads: $totalReads, lastReadAt: $lastReadAt)';
}


}

/// @nodoc
abstract mixin class $ReadingStatsEntityCopyWith<$Res>  {
  factory $ReadingStatsEntityCopyWith(ReadingStatsEntity value, $Res Function(ReadingStatsEntity) _then) = _$ReadingStatsEntityCopyWithImpl;
@useResult
$Res call({
 String linkId, int totalReads, DateTime? lastReadAt
});




}
/// @nodoc
class _$ReadingStatsEntityCopyWithImpl<$Res>
    implements $ReadingStatsEntityCopyWith<$Res> {
  _$ReadingStatsEntityCopyWithImpl(this._self, this._then);

  final ReadingStatsEntity _self;
  final $Res Function(ReadingStatsEntity) _then;

/// Create a copy of ReadingStatsEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? linkId = null,Object? totalReads = null,Object? lastReadAt = freezed,}) {
  return _then(_self.copyWith(
linkId: null == linkId ? _self.linkId : linkId // ignore: cast_nullable_to_non_nullable
as String,totalReads: null == totalReads ? _self.totalReads : totalReads // ignore: cast_nullable_to_non_nullable
as int,lastReadAt: freezed == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingStatsEntity].
extension ReadingStatsEntityPatterns on ReadingStatsEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingStatsEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingStatsEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingStatsEntity value)  $default,){
final _that = this;
switch (_that) {
case _ReadingStatsEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingStatsEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingStatsEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String linkId,  int totalReads,  DateTime? lastReadAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingStatsEntity() when $default != null:
return $default(_that.linkId,_that.totalReads,_that.lastReadAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String linkId,  int totalReads,  DateTime? lastReadAt)  $default,) {final _that = this;
switch (_that) {
case _ReadingStatsEntity():
return $default(_that.linkId,_that.totalReads,_that.lastReadAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String linkId,  int totalReads,  DateTime? lastReadAt)?  $default,) {final _that = this;
switch (_that) {
case _ReadingStatsEntity() when $default != null:
return $default(_that.linkId,_that.totalReads,_that.lastReadAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadingStatsEntity implements ReadingStatsEntity {
  const _ReadingStatsEntity({required this.linkId, this.totalReads = 0, this.lastReadAt});
  factory _ReadingStatsEntity.fromJson(Map<String, dynamic> json) => _$ReadingStatsEntityFromJson(json);

@override final  String linkId;
@override@JsonKey() final  int totalReads;
@override final  DateTime? lastReadAt;

/// Create a copy of ReadingStatsEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingStatsEntityCopyWith<_ReadingStatsEntity> get copyWith => __$ReadingStatsEntityCopyWithImpl<_ReadingStatsEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingStatsEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingStatsEntity&&(identical(other.linkId, linkId) || other.linkId == linkId)&&(identical(other.totalReads, totalReads) || other.totalReads == totalReads)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,linkId,totalReads,lastReadAt);

@override
String toString() {
  return 'ReadingStatsEntity(linkId: $linkId, totalReads: $totalReads, lastReadAt: $lastReadAt)';
}


}

/// @nodoc
abstract mixin class _$ReadingStatsEntityCopyWith<$Res> implements $ReadingStatsEntityCopyWith<$Res> {
  factory _$ReadingStatsEntityCopyWith(_ReadingStatsEntity value, $Res Function(_ReadingStatsEntity) _then) = __$ReadingStatsEntityCopyWithImpl;
@override @useResult
$Res call({
 String linkId, int totalReads, DateTime? lastReadAt
});




}
/// @nodoc
class __$ReadingStatsEntityCopyWithImpl<$Res>
    implements _$ReadingStatsEntityCopyWith<$Res> {
  __$ReadingStatsEntityCopyWithImpl(this._self, this._then);

  final _ReadingStatsEntity _self;
  final $Res Function(_ReadingStatsEntity) _then;

/// Create a copy of ReadingStatsEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? linkId = null,Object? totalReads = null,Object? lastReadAt = freezed,}) {
  return _then(_ReadingStatsEntity(
linkId: null == linkId ? _self.linkId : linkId // ignore: cast_nullable_to_non_nullable
as String,totalReads: null == totalReads ? _self.totalReads : totalReads // ignore: cast_nullable_to_non_nullable
as int,lastReadAt: freezed == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

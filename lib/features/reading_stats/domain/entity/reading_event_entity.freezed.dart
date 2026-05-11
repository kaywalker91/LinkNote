// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_event_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReadingEventEntity {

 String get linkId; DateTime get timestamp; int? get durationSeconds;
/// Create a copy of ReadingEventEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingEventEntityCopyWith<ReadingEventEntity> get copyWith => _$ReadingEventEntityCopyWithImpl<ReadingEventEntity>(this as ReadingEventEntity, _$identity);

  /// Serializes this ReadingEventEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingEventEntity&&(identical(other.linkId, linkId) || other.linkId == linkId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,linkId,timestamp,durationSeconds);

@override
String toString() {
  return 'ReadingEventEntity(linkId: $linkId, timestamp: $timestamp, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class $ReadingEventEntityCopyWith<$Res>  {
  factory $ReadingEventEntityCopyWith(ReadingEventEntity value, $Res Function(ReadingEventEntity) _then) = _$ReadingEventEntityCopyWithImpl;
@useResult
$Res call({
 String linkId, DateTime timestamp, int? durationSeconds
});




}
/// @nodoc
class _$ReadingEventEntityCopyWithImpl<$Res>
    implements $ReadingEventEntityCopyWith<$Res> {
  _$ReadingEventEntityCopyWithImpl(this._self, this._then);

  final ReadingEventEntity _self;
  final $Res Function(ReadingEventEntity) _then;

/// Create a copy of ReadingEventEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? linkId = null,Object? timestamp = null,Object? durationSeconds = freezed,}) {
  return _then(_self.copyWith(
linkId: null == linkId ? _self.linkId : linkId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingEventEntity].
extension ReadingEventEntityPatterns on ReadingEventEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingEventEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingEventEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingEventEntity value)  $default,){
final _that = this;
switch (_that) {
case _ReadingEventEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingEventEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingEventEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String linkId,  DateTime timestamp,  int? durationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingEventEntity() when $default != null:
return $default(_that.linkId,_that.timestamp,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String linkId,  DateTime timestamp,  int? durationSeconds)  $default,) {final _that = this;
switch (_that) {
case _ReadingEventEntity():
return $default(_that.linkId,_that.timestamp,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String linkId,  DateTime timestamp,  int? durationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _ReadingEventEntity() when $default != null:
return $default(_that.linkId,_that.timestamp,_that.durationSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadingEventEntity implements ReadingEventEntity {
  const _ReadingEventEntity({required this.linkId, required this.timestamp, this.durationSeconds});
  factory _ReadingEventEntity.fromJson(Map<String, dynamic> json) => _$ReadingEventEntityFromJson(json);

@override final  String linkId;
@override final  DateTime timestamp;
@override final  int? durationSeconds;

/// Create a copy of ReadingEventEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingEventEntityCopyWith<_ReadingEventEntity> get copyWith => __$ReadingEventEntityCopyWithImpl<_ReadingEventEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingEventEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingEventEntity&&(identical(other.linkId, linkId) || other.linkId == linkId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,linkId,timestamp,durationSeconds);

@override
String toString() {
  return 'ReadingEventEntity(linkId: $linkId, timestamp: $timestamp, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class _$ReadingEventEntityCopyWith<$Res> implements $ReadingEventEntityCopyWith<$Res> {
  factory _$ReadingEventEntityCopyWith(_ReadingEventEntity value, $Res Function(_ReadingEventEntity) _then) = __$ReadingEventEntityCopyWithImpl;
@override @useResult
$Res call({
 String linkId, DateTime timestamp, int? durationSeconds
});




}
/// @nodoc
class __$ReadingEventEntityCopyWithImpl<$Res>
    implements _$ReadingEventEntityCopyWith<$Res> {
  __$ReadingEventEntityCopyWithImpl(this._self, this._then);

  final _ReadingEventEntity _self;
  final $Res Function(_ReadingEventEntity) _then;

/// Create a copy of ReadingEventEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? linkId = null,Object? timestamp = null,Object? durationSeconds = freezed,}) {
  return _then(_ReadingEventEntity(
linkId: null == linkId ? _self.linkId : linkId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

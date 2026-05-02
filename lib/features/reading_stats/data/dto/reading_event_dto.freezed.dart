// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_event_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReadingEventDto {

 String get linkId; String get timestamp; int? get durationSeconds;
/// Create a copy of ReadingEventDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingEventDtoCopyWith<ReadingEventDto> get copyWith => _$ReadingEventDtoCopyWithImpl<ReadingEventDto>(this as ReadingEventDto, _$identity);

  /// Serializes this ReadingEventDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingEventDto&&(identical(other.linkId, linkId) || other.linkId == linkId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,linkId,timestamp,durationSeconds);

@override
String toString() {
  return 'ReadingEventDto(linkId: $linkId, timestamp: $timestamp, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class $ReadingEventDtoCopyWith<$Res>  {
  factory $ReadingEventDtoCopyWith(ReadingEventDto value, $Res Function(ReadingEventDto) _then) = _$ReadingEventDtoCopyWithImpl;
@useResult
$Res call({
 String linkId, String timestamp, int? durationSeconds
});




}
/// @nodoc
class _$ReadingEventDtoCopyWithImpl<$Res>
    implements $ReadingEventDtoCopyWith<$Res> {
  _$ReadingEventDtoCopyWithImpl(this._self, this._then);

  final ReadingEventDto _self;
  final $Res Function(ReadingEventDto) _then;

/// Create a copy of ReadingEventDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? linkId = null,Object? timestamp = null,Object? durationSeconds = freezed,}) {
  return _then(_self.copyWith(
linkId: null == linkId ? _self.linkId : linkId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingEventDto].
extension ReadingEventDtoPatterns on ReadingEventDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingEventDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingEventDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingEventDto value)  $default,){
final _that = this;
switch (_that) {
case _ReadingEventDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingEventDto value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingEventDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String linkId,  String timestamp,  int? durationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingEventDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String linkId,  String timestamp,  int? durationSeconds)  $default,) {final _that = this;
switch (_that) {
case _ReadingEventDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String linkId,  String timestamp,  int? durationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _ReadingEventDto() when $default != null:
return $default(_that.linkId,_that.timestamp,_that.durationSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadingEventDto implements ReadingEventDto {
  const _ReadingEventDto({required this.linkId, required this.timestamp, this.durationSeconds});
  factory _ReadingEventDto.fromJson(Map<String, dynamic> json) => _$ReadingEventDtoFromJson(json);

@override final  String linkId;
@override final  String timestamp;
@override final  int? durationSeconds;

/// Create a copy of ReadingEventDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingEventDtoCopyWith<_ReadingEventDto> get copyWith => __$ReadingEventDtoCopyWithImpl<_ReadingEventDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingEventDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingEventDto&&(identical(other.linkId, linkId) || other.linkId == linkId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,linkId,timestamp,durationSeconds);

@override
String toString() {
  return 'ReadingEventDto(linkId: $linkId, timestamp: $timestamp, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class _$ReadingEventDtoCopyWith<$Res> implements $ReadingEventDtoCopyWith<$Res> {
  factory _$ReadingEventDtoCopyWith(_ReadingEventDto value, $Res Function(_ReadingEventDto) _then) = __$ReadingEventDtoCopyWithImpl;
@override @useResult
$Res call({
 String linkId, String timestamp, int? durationSeconds
});




}
/// @nodoc
class __$ReadingEventDtoCopyWithImpl<$Res>
    implements _$ReadingEventDtoCopyWith<$Res> {
  __$ReadingEventDtoCopyWithImpl(this._self, this._then);

  final _ReadingEventDto _self;
  final $Res Function(_ReadingEventDto) _then;

/// Create a copy of ReadingEventDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? linkId = null,Object? timestamp = null,Object? durationSeconds = freezed,}) {
  return _then(_ReadingEventDto(
linkId: null == linkId ? _self.linkId : linkId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

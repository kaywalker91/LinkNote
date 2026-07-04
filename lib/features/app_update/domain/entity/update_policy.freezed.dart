// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_policy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdatePolicy {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdatePolicy);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdatePolicy()';
}


}

/// @nodoc
class $UpdatePolicyCopyWith<$Res>  {
$UpdatePolicyCopyWith(UpdatePolicy _, $Res Function(UpdatePolicy) __);
}


/// Adds pattern-matching-related methods to [UpdatePolicy].
extension UpdatePolicyPatterns on UpdatePolicy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( UpToDate value)?  upToDate,TResult Function( OptionalUpdate value)?  optional,TResult Function( ForcedUpdate value)?  forced,required TResult orElse(),}){
final _that = this;
switch (_that) {
case UpToDate() when upToDate != null:
return upToDate(_that);case OptionalUpdate() when optional != null:
return optional(_that);case ForcedUpdate() when forced != null:
return forced(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( UpToDate value)  upToDate,required TResult Function( OptionalUpdate value)  optional,required TResult Function( ForcedUpdate value)  forced,}){
final _that = this;
switch (_that) {
case UpToDate():
return upToDate(_that);case OptionalUpdate():
return optional(_that);case ForcedUpdate():
return forced(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( UpToDate value)?  upToDate,TResult? Function( OptionalUpdate value)?  optional,TResult? Function( ForcedUpdate value)?  forced,}){
final _that = this;
switch (_that) {
case UpToDate() when upToDate != null:
return upToDate(_that);case OptionalUpdate() when optional != null:
return optional(_that);case ForcedUpdate() when forced != null:
return forced(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  upToDate,TResult Function( int latestVersionCode,  String? message,  String? storeUrl)?  optional,TResult Function( int minVersionCode,  String? message,  String? storeUrl)?  forced,required TResult orElse(),}) {final _that = this;
switch (_that) {
case UpToDate() when upToDate != null:
return upToDate();case OptionalUpdate() when optional != null:
return optional(_that.latestVersionCode,_that.message,_that.storeUrl);case ForcedUpdate() when forced != null:
return forced(_that.minVersionCode,_that.message,_that.storeUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  upToDate,required TResult Function( int latestVersionCode,  String? message,  String? storeUrl)  optional,required TResult Function( int minVersionCode,  String? message,  String? storeUrl)  forced,}) {final _that = this;
switch (_that) {
case UpToDate():
return upToDate();case OptionalUpdate():
return optional(_that.latestVersionCode,_that.message,_that.storeUrl);case ForcedUpdate():
return forced(_that.minVersionCode,_that.message,_that.storeUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  upToDate,TResult? Function( int latestVersionCode,  String? message,  String? storeUrl)?  optional,TResult? Function( int minVersionCode,  String? message,  String? storeUrl)?  forced,}) {final _that = this;
switch (_that) {
case UpToDate() when upToDate != null:
return upToDate();case OptionalUpdate() when optional != null:
return optional(_that.latestVersionCode,_that.message,_that.storeUrl);case ForcedUpdate() when forced != null:
return forced(_that.minVersionCode,_that.message,_that.storeUrl);case _:
  return null;

}
}

}

/// @nodoc


class UpToDate implements UpdatePolicy {
  const UpToDate();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpToDate);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdatePolicy.upToDate()';
}


}




/// @nodoc


class OptionalUpdate implements UpdatePolicy {
  const OptionalUpdate({required this.latestVersionCode, this.message, this.storeUrl});
  

 final  int latestVersionCode;
 final  String? message;
 final  String? storeUrl;

/// Create a copy of UpdatePolicy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OptionalUpdateCopyWith<OptionalUpdate> get copyWith => _$OptionalUpdateCopyWithImpl<OptionalUpdate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OptionalUpdate&&(identical(other.latestVersionCode, latestVersionCode) || other.latestVersionCode == latestVersionCode)&&(identical(other.message, message) || other.message == message)&&(identical(other.storeUrl, storeUrl) || other.storeUrl == storeUrl));
}


@override
int get hashCode => Object.hash(runtimeType,latestVersionCode,message,storeUrl);

@override
String toString() {
  return 'UpdatePolicy.optional(latestVersionCode: $latestVersionCode, message: $message, storeUrl: $storeUrl)';
}


}

/// @nodoc
abstract mixin class $OptionalUpdateCopyWith<$Res> implements $UpdatePolicyCopyWith<$Res> {
  factory $OptionalUpdateCopyWith(OptionalUpdate value, $Res Function(OptionalUpdate) _then) = _$OptionalUpdateCopyWithImpl;
@useResult
$Res call({
 int latestVersionCode, String? message, String? storeUrl
});




}
/// @nodoc
class _$OptionalUpdateCopyWithImpl<$Res>
    implements $OptionalUpdateCopyWith<$Res> {
  _$OptionalUpdateCopyWithImpl(this._self, this._then);

  final OptionalUpdate _self;
  final $Res Function(OptionalUpdate) _then;

/// Create a copy of UpdatePolicy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? latestVersionCode = null,Object? message = freezed,Object? storeUrl = freezed,}) {
  return _then(OptionalUpdate(
latestVersionCode: null == latestVersionCode ? _self.latestVersionCode : latestVersionCode // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,storeUrl: freezed == storeUrl ? _self.storeUrl : storeUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class ForcedUpdate implements UpdatePolicy {
  const ForcedUpdate({required this.minVersionCode, this.message, this.storeUrl});
  

 final  int minVersionCode;
 final  String? message;
 final  String? storeUrl;

/// Create a copy of UpdatePolicy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForcedUpdateCopyWith<ForcedUpdate> get copyWith => _$ForcedUpdateCopyWithImpl<ForcedUpdate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForcedUpdate&&(identical(other.minVersionCode, minVersionCode) || other.minVersionCode == minVersionCode)&&(identical(other.message, message) || other.message == message)&&(identical(other.storeUrl, storeUrl) || other.storeUrl == storeUrl));
}


@override
int get hashCode => Object.hash(runtimeType,minVersionCode,message,storeUrl);

@override
String toString() {
  return 'UpdatePolicy.forced(minVersionCode: $minVersionCode, message: $message, storeUrl: $storeUrl)';
}


}

/// @nodoc
abstract mixin class $ForcedUpdateCopyWith<$Res> implements $UpdatePolicyCopyWith<$Res> {
  factory $ForcedUpdateCopyWith(ForcedUpdate value, $Res Function(ForcedUpdate) _then) = _$ForcedUpdateCopyWithImpl;
@useResult
$Res call({
 int minVersionCode, String? message, String? storeUrl
});




}
/// @nodoc
class _$ForcedUpdateCopyWithImpl<$Res>
    implements $ForcedUpdateCopyWith<$Res> {
  _$ForcedUpdateCopyWithImpl(this._self, this._then);

  final ForcedUpdate _self;
  final $Res Function(ForcedUpdate) _then;

/// Create a copy of UpdatePolicy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? minVersionCode = null,Object? message = freezed,Object? storeUrl = freezed,}) {
  return _then(ForcedUpdate(
minVersionCode: null == minVersionCode ? _self.minVersionCode : minVersionCode // ignore: cast_nullable_to_non_nullable
as int,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,storeUrl: freezed == storeUrl ? _self.storeUrl : storeUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link_filter_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LinkFilter {

 bool get favoritesOnly;
/// Create a copy of LinkFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkFilterCopyWith<LinkFilter> get copyWith => _$LinkFilterCopyWithImpl<LinkFilter>(this as LinkFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkFilter&&(identical(other.favoritesOnly, favoritesOnly) || other.favoritesOnly == favoritesOnly));
}


@override
int get hashCode => Object.hash(runtimeType,favoritesOnly);

@override
String toString() {
  return 'LinkFilter(favoritesOnly: $favoritesOnly)';
}


}

/// @nodoc
abstract mixin class $LinkFilterCopyWith<$Res>  {
  factory $LinkFilterCopyWith(LinkFilter value, $Res Function(LinkFilter) _then) = _$LinkFilterCopyWithImpl;
@useResult
$Res call({
 bool favoritesOnly
});




}
/// @nodoc
class _$LinkFilterCopyWithImpl<$Res>
    implements $LinkFilterCopyWith<$Res> {
  _$LinkFilterCopyWithImpl(this._self, this._then);

  final LinkFilter _self;
  final $Res Function(LinkFilter) _then;

/// Create a copy of LinkFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? favoritesOnly = null,}) {
  return _then(_self.copyWith(
favoritesOnly: null == favoritesOnly ? _self.favoritesOnly : favoritesOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LinkFilter].
extension LinkFilterPatterns on LinkFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkFilter value)  $default,){
final _that = this;
switch (_that) {
case _LinkFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkFilter value)?  $default,){
final _that = this;
switch (_that) {
case _LinkFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool favoritesOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkFilter() when $default != null:
return $default(_that.favoritesOnly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool favoritesOnly)  $default,) {final _that = this;
switch (_that) {
case _LinkFilter():
return $default(_that.favoritesOnly);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool favoritesOnly)?  $default,) {final _that = this;
switch (_that) {
case _LinkFilter() when $default != null:
return $default(_that.favoritesOnly);case _:
  return null;

}
}

}

/// @nodoc


class _LinkFilter implements LinkFilter {
  const _LinkFilter({this.favoritesOnly = false});
  

@override@JsonKey() final  bool favoritesOnly;

/// Create a copy of LinkFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkFilterCopyWith<_LinkFilter> get copyWith => __$LinkFilterCopyWithImpl<_LinkFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkFilter&&(identical(other.favoritesOnly, favoritesOnly) || other.favoritesOnly == favoritesOnly));
}


@override
int get hashCode => Object.hash(runtimeType,favoritesOnly);

@override
String toString() {
  return 'LinkFilter(favoritesOnly: $favoritesOnly)';
}


}

/// @nodoc
abstract mixin class _$LinkFilterCopyWith<$Res> implements $LinkFilterCopyWith<$Res> {
  factory _$LinkFilterCopyWith(_LinkFilter value, $Res Function(_LinkFilter) _then) = __$LinkFilterCopyWithImpl;
@override @useResult
$Res call({
 bool favoritesOnly
});




}
/// @nodoc
class __$LinkFilterCopyWithImpl<$Res>
    implements _$LinkFilterCopyWith<$Res> {
  __$LinkFilterCopyWithImpl(this._self, this._then);

  final _LinkFilter _self;
  final $Res Function(_LinkFilter) _then;

/// Create a copy of LinkFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? favoritesOnly = null,}) {
  return _then(_LinkFilter(
favoritesOnly: null == favoritesOnly ? _self.favoritesOnly : favoritesOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

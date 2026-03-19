// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paginated_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaginatedState<T> {

 List<T> get items; bool get hasMore; String? get nextCursor; bool get isLoadingMore; Object? get loadMoreError;
/// Create a copy of PaginatedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedStateCopyWith<T, PaginatedState<T>> get copyWith => _$PaginatedStateCopyWithImpl<T, PaginatedState<T>>(this as PaginatedState<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedState<T>&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&const DeepCollectionEquality().equals(other.loadMoreError, loadMoreError));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),hasMore,nextCursor,isLoadingMore,const DeepCollectionEquality().hash(loadMoreError));

@override
String toString() {
  return 'PaginatedState<$T>(items: $items, hasMore: $hasMore, nextCursor: $nextCursor, isLoadingMore: $isLoadingMore, loadMoreError: $loadMoreError)';
}


}

/// @nodoc
abstract mixin class $PaginatedStateCopyWith<T,$Res>  {
  factory $PaginatedStateCopyWith(PaginatedState<T> value, $Res Function(PaginatedState<T>) _then) = _$PaginatedStateCopyWithImpl;
@useResult
$Res call({
 List<T> items, bool hasMore, String? nextCursor, bool isLoadingMore, Object? loadMoreError
});




}
/// @nodoc
class _$PaginatedStateCopyWithImpl<T,$Res>
    implements $PaginatedStateCopyWith<T, $Res> {
  _$PaginatedStateCopyWithImpl(this._self, this._then);

  final PaginatedState<T> _self;
  final $Res Function(PaginatedState<T>) _then;

/// Create a copy of PaginatedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? hasMore = null,Object? nextCursor = freezed,Object? isLoadingMore = null,Object? loadMoreError = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<T>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreError: freezed == loadMoreError ? _self.loadMoreError : loadMoreError ,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginatedState].
extension PaginatedStatePatterns<T> on PaginatedState<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedState<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedState<T> value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedState():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedState<T> value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<T> items,  bool hasMore,  String? nextCursor,  bool isLoadingMore,  Object? loadMoreError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedState() when $default != null:
return $default(_that.items,_that.hasMore,_that.nextCursor,_that.isLoadingMore,_that.loadMoreError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<T> items,  bool hasMore,  String? nextCursor,  bool isLoadingMore,  Object? loadMoreError)  $default,) {final _that = this;
switch (_that) {
case _PaginatedState():
return $default(_that.items,_that.hasMore,_that.nextCursor,_that.isLoadingMore,_that.loadMoreError);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<T> items,  bool hasMore,  String? nextCursor,  bool isLoadingMore,  Object? loadMoreError)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedState() when $default != null:
return $default(_that.items,_that.hasMore,_that.nextCursor,_that.isLoadingMore,_that.loadMoreError);case _:
  return null;

}
}

}

/// @nodoc


class _PaginatedState<T> implements PaginatedState<T> {
  const _PaginatedState({final  List<T> items = const [], this.hasMore = false, this.nextCursor, this.isLoadingMore = false, this.loadMoreError}): _items = items;
  

 final  List<T> _items;
@override@JsonKey() List<T> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override@JsonKey() final  bool hasMore;
@override final  String? nextCursor;
@override@JsonKey() final  bool isLoadingMore;
@override final  Object? loadMoreError;

/// Create a copy of PaginatedState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedStateCopyWith<T, _PaginatedState<T>> get copyWith => __$PaginatedStateCopyWithImpl<T, _PaginatedState<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedState<T>&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&const DeepCollectionEquality().equals(other.loadMoreError, loadMoreError));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),hasMore,nextCursor,isLoadingMore,const DeepCollectionEquality().hash(loadMoreError));

@override
String toString() {
  return 'PaginatedState<$T>(items: $items, hasMore: $hasMore, nextCursor: $nextCursor, isLoadingMore: $isLoadingMore, loadMoreError: $loadMoreError)';
}


}

/// @nodoc
abstract mixin class _$PaginatedStateCopyWith<T,$Res> implements $PaginatedStateCopyWith<T, $Res> {
  factory _$PaginatedStateCopyWith(_PaginatedState<T> value, $Res Function(_PaginatedState<T>) _then) = __$PaginatedStateCopyWithImpl;
@override @useResult
$Res call({
 List<T> items, bool hasMore, String? nextCursor, bool isLoadingMore, Object? loadMoreError
});




}
/// @nodoc
class __$PaginatedStateCopyWithImpl<T,$Res>
    implements _$PaginatedStateCopyWith<T, $Res> {
  __$PaginatedStateCopyWithImpl(this._self, this._then);

  final _PaginatedState<T> _self;
  final $Res Function(_PaginatedState<T>) _then;

/// Create a copy of PaginatedState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? hasMore = null,Object? nextCursor = freezed,Object? isLoadingMore = null,Object? loadMoreError = freezed,}) {
  return _then(_PaginatedState<T>(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<T>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,loadMoreError: freezed == loadMoreError ? _self.loadMoreError : loadMoreError ,
  ));
}


}

// dart format on

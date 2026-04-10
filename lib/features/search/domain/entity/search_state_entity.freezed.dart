// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchStateEntity {

 String get query; List<LinkEntity> get results; List<String> get recentSearches; bool get isSearching; SearchFilterEntity get filter;
/// Create a copy of SearchStateEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchStateEntityCopyWith<SearchStateEntity> get copyWith => _$SearchStateEntityCopyWithImpl<SearchStateEntity>(this as SearchStateEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchStateEntity&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.results, results)&&const DeepCollectionEquality().equals(other.recentSearches, recentSearches)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching)&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,query,const DeepCollectionEquality().hash(results),const DeepCollectionEquality().hash(recentSearches),isSearching,filter);

@override
String toString() {
  return 'SearchStateEntity(query: $query, results: $results, recentSearches: $recentSearches, isSearching: $isSearching, filter: $filter)';
}


}

/// @nodoc
abstract mixin class $SearchStateEntityCopyWith<$Res>  {
  factory $SearchStateEntityCopyWith(SearchStateEntity value, $Res Function(SearchStateEntity) _then) = _$SearchStateEntityCopyWithImpl;
@useResult
$Res call({
 String query, List<LinkEntity> results, List<String> recentSearches, bool isSearching, SearchFilterEntity filter
});


$SearchFilterEntityCopyWith<$Res> get filter;

}
/// @nodoc
class _$SearchStateEntityCopyWithImpl<$Res>
    implements $SearchStateEntityCopyWith<$Res> {
  _$SearchStateEntityCopyWithImpl(this._self, this._then);

  final SearchStateEntity _self;
  final $Res Function(SearchStateEntity) _then;

/// Create a copy of SearchStateEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? results = null,Object? recentSearches = null,Object? isSearching = null,Object? filter = null,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<LinkEntity>,recentSearches: null == recentSearches ? _self.recentSearches : recentSearches // ignore: cast_nullable_to_non_nullable
as List<String>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as SearchFilterEntity,
  ));
}
/// Create a copy of SearchStateEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchFilterEntityCopyWith<$Res> get filter {
  
  return $SearchFilterEntityCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}


/// Adds pattern-matching-related methods to [SearchStateEntity].
extension SearchStateEntityPatterns on SearchStateEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchStateEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchStateEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchStateEntity value)  $default,){
final _that = this;
switch (_that) {
case _SearchStateEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchStateEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SearchStateEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  List<LinkEntity> results,  List<String> recentSearches,  bool isSearching,  SearchFilterEntity filter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchStateEntity() when $default != null:
return $default(_that.query,_that.results,_that.recentSearches,_that.isSearching,_that.filter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  List<LinkEntity> results,  List<String> recentSearches,  bool isSearching,  SearchFilterEntity filter)  $default,) {final _that = this;
switch (_that) {
case _SearchStateEntity():
return $default(_that.query,_that.results,_that.recentSearches,_that.isSearching,_that.filter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  List<LinkEntity> results,  List<String> recentSearches,  bool isSearching,  SearchFilterEntity filter)?  $default,) {final _that = this;
switch (_that) {
case _SearchStateEntity() when $default != null:
return $default(_that.query,_that.results,_that.recentSearches,_that.isSearching,_that.filter);case _:
  return null;

}
}

}

/// @nodoc


class _SearchStateEntity implements SearchStateEntity {
  const _SearchStateEntity({this.query = '', final  List<LinkEntity> results = const [], final  List<String> recentSearches = const [], this.isSearching = false, this.filter = const SearchFilterEntity()}): _results = results,_recentSearches = recentSearches;
  

@override@JsonKey() final  String query;
 final  List<LinkEntity> _results;
@override@JsonKey() List<LinkEntity> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

 final  List<String> _recentSearches;
@override@JsonKey() List<String> get recentSearches {
  if (_recentSearches is EqualUnmodifiableListView) return _recentSearches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentSearches);
}

@override@JsonKey() final  bool isSearching;
@override@JsonKey() final  SearchFilterEntity filter;

/// Create a copy of SearchStateEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchStateEntityCopyWith<_SearchStateEntity> get copyWith => __$SearchStateEntityCopyWithImpl<_SearchStateEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchStateEntity&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other._results, _results)&&const DeepCollectionEquality().equals(other._recentSearches, _recentSearches)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching)&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,query,const DeepCollectionEquality().hash(_results),const DeepCollectionEquality().hash(_recentSearches),isSearching,filter);

@override
String toString() {
  return 'SearchStateEntity(query: $query, results: $results, recentSearches: $recentSearches, isSearching: $isSearching, filter: $filter)';
}


}

/// @nodoc
abstract mixin class _$SearchStateEntityCopyWith<$Res> implements $SearchStateEntityCopyWith<$Res> {
  factory _$SearchStateEntityCopyWith(_SearchStateEntity value, $Res Function(_SearchStateEntity) _then) = __$SearchStateEntityCopyWithImpl;
@override @useResult
$Res call({
 String query, List<LinkEntity> results, List<String> recentSearches, bool isSearching, SearchFilterEntity filter
});


@override $SearchFilterEntityCopyWith<$Res> get filter;

}
/// @nodoc
class __$SearchStateEntityCopyWithImpl<$Res>
    implements _$SearchStateEntityCopyWith<$Res> {
  __$SearchStateEntityCopyWithImpl(this._self, this._then);

  final _SearchStateEntity _self;
  final $Res Function(_SearchStateEntity) _then;

/// Create a copy of SearchStateEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? results = null,Object? recentSearches = null,Object? isSearching = null,Object? filter = null,}) {
  return _then(_SearchStateEntity(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<LinkEntity>,recentSearches: null == recentSearches ? _self._recentSearches : recentSearches // ignore: cast_nullable_to_non_nullable
as List<String>,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,filter: null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as SearchFilterEntity,
  ));
}

/// Create a copy of SearchStateEntity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SearchFilterEntityCopyWith<$Res> get filter {
  
  return $SearchFilterEntityCopyWith<$Res>(_self.filter, (value) {
    return _then(_self.copyWith(filter: value));
  });
}
}

// dart format on

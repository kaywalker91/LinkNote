// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_filter_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchFilterEntity {

 List<String> get selectedTagIds; bool get favoritesOnly; DateTime? get dateFrom; DateTime? get dateTo;
/// Create a copy of SearchFilterEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchFilterEntityCopyWith<SearchFilterEntity> get copyWith => _$SearchFilterEntityCopyWithImpl<SearchFilterEntity>(this as SearchFilterEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchFilterEntity&&const DeepCollectionEquality().equals(other.selectedTagIds, selectedTagIds)&&(identical(other.favoritesOnly, favoritesOnly) || other.favoritesOnly == favoritesOnly)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(selectedTagIds),favoritesOnly,dateFrom,dateTo);

@override
String toString() {
  return 'SearchFilterEntity(selectedTagIds: $selectedTagIds, favoritesOnly: $favoritesOnly, dateFrom: $dateFrom, dateTo: $dateTo)';
}


}

/// @nodoc
abstract mixin class $SearchFilterEntityCopyWith<$Res>  {
  factory $SearchFilterEntityCopyWith(SearchFilterEntity value, $Res Function(SearchFilterEntity) _then) = _$SearchFilterEntityCopyWithImpl;
@useResult
$Res call({
 List<String> selectedTagIds, bool favoritesOnly, DateTime? dateFrom, DateTime? dateTo
});




}
/// @nodoc
class _$SearchFilterEntityCopyWithImpl<$Res>
    implements $SearchFilterEntityCopyWith<$Res> {
  _$SearchFilterEntityCopyWithImpl(this._self, this._then);

  final SearchFilterEntity _self;
  final $Res Function(SearchFilterEntity) _then;

/// Create a copy of SearchFilterEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedTagIds = null,Object? favoritesOnly = null,Object? dateFrom = freezed,Object? dateTo = freezed,}) {
  return _then(_self.copyWith(
selectedTagIds: null == selectedTagIds ? _self.selectedTagIds : selectedTagIds // ignore: cast_nullable_to_non_nullable
as List<String>,favoritesOnly: null == favoritesOnly ? _self.favoritesOnly : favoritesOnly // ignore: cast_nullable_to_non_nullable
as bool,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchFilterEntity].
extension SearchFilterEntityPatterns on SearchFilterEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchFilterEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchFilterEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchFilterEntity value)  $default,){
final _that = this;
switch (_that) {
case _SearchFilterEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchFilterEntity value)?  $default,){
final _that = this;
switch (_that) {
case _SearchFilterEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> selectedTagIds,  bool favoritesOnly,  DateTime? dateFrom,  DateTime? dateTo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchFilterEntity() when $default != null:
return $default(_that.selectedTagIds,_that.favoritesOnly,_that.dateFrom,_that.dateTo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> selectedTagIds,  bool favoritesOnly,  DateTime? dateFrom,  DateTime? dateTo)  $default,) {final _that = this;
switch (_that) {
case _SearchFilterEntity():
return $default(_that.selectedTagIds,_that.favoritesOnly,_that.dateFrom,_that.dateTo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> selectedTagIds,  bool favoritesOnly,  DateTime? dateFrom,  DateTime? dateTo)?  $default,) {final _that = this;
switch (_that) {
case _SearchFilterEntity() when $default != null:
return $default(_that.selectedTagIds,_that.favoritesOnly,_that.dateFrom,_that.dateTo);case _:
  return null;

}
}

}

/// @nodoc


class _SearchFilterEntity extends SearchFilterEntity {
  const _SearchFilterEntity({final  List<String> selectedTagIds = const [], this.favoritesOnly = false, this.dateFrom, this.dateTo}): _selectedTagIds = selectedTagIds,super._();
  

 final  List<String> _selectedTagIds;
@override@JsonKey() List<String> get selectedTagIds {
  if (_selectedTagIds is EqualUnmodifiableListView) return _selectedTagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedTagIds);
}

@override@JsonKey() final  bool favoritesOnly;
@override final  DateTime? dateFrom;
@override final  DateTime? dateTo;

/// Create a copy of SearchFilterEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchFilterEntityCopyWith<_SearchFilterEntity> get copyWith => __$SearchFilterEntityCopyWithImpl<_SearchFilterEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchFilterEntity&&const DeepCollectionEquality().equals(other._selectedTagIds, _selectedTagIds)&&(identical(other.favoritesOnly, favoritesOnly) || other.favoritesOnly == favoritesOnly)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_selectedTagIds),favoritesOnly,dateFrom,dateTo);

@override
String toString() {
  return 'SearchFilterEntity(selectedTagIds: $selectedTagIds, favoritesOnly: $favoritesOnly, dateFrom: $dateFrom, dateTo: $dateTo)';
}


}

/// @nodoc
abstract mixin class _$SearchFilterEntityCopyWith<$Res> implements $SearchFilterEntityCopyWith<$Res> {
  factory _$SearchFilterEntityCopyWith(_SearchFilterEntity value, $Res Function(_SearchFilterEntity) _then) = __$SearchFilterEntityCopyWithImpl;
@override @useResult
$Res call({
 List<String> selectedTagIds, bool favoritesOnly, DateTime? dateFrom, DateTime? dateTo
});




}
/// @nodoc
class __$SearchFilterEntityCopyWithImpl<$Res>
    implements _$SearchFilterEntityCopyWith<$Res> {
  __$SearchFilterEntityCopyWithImpl(this._self, this._then);

  final _SearchFilterEntity _self;
  final $Res Function(_SearchFilterEntity) _then;

/// Create a copy of SearchFilterEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedTagIds = null,Object? favoritesOnly = null,Object? dateFrom = freezed,Object? dateTo = freezed,}) {
  return _then(_SearchFilterEntity(
selectedTagIds: null == selectedTagIds ? _self._selectedTagIds : selectedTagIds // ignore: cast_nullable_to_non_nullable
as List<String>,favoritesOnly: null == favoritesOnly ? _self.favoritesOnly : favoritesOnly // ignore: cast_nullable_to_non_nullable
as bool,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_filter_entity.freezed.dart';

@freezed
abstract class SearchFilterEntity with _$SearchFilterEntity {
  const SearchFilterEntity._();

  const factory SearchFilterEntity({
    @Default([]) List<String> selectedTagIds,
    @Default(false) bool favoritesOnly,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) = _SearchFilterEntity;

  bool get hasActiveFilters =>
      selectedTagIds.isNotEmpty ||
      favoritesOnly ||
      dateFrom != null ||
      dateTo != null;
}

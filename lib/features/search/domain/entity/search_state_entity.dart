import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';

part 'search_state_entity.freezed.dart';

@freezed
abstract class SearchStateEntity with _$SearchStateEntity {
  const factory SearchStateEntity({
    @Default('') String query,
    @Default([]) List<LinkEntity> results,
    @Default([]) List<String> recentSearches,
    @Default(false) bool isSearching,
  }) = _SearchStateEntity;
}

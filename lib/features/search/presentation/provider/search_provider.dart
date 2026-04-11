import 'dart:async';

import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/utils/debouncer.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:linknote/features/search/domain/entity/search_filter_entity.dart';
import 'package:linknote/features/search/domain/entity/search_state_entity.dart';
import 'package:linknote/features/search/presentation/provider/search_di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_provider.g.dart';

@riverpod
class Search extends _$Search {
  late final Debouncer _debouncer;

  @override
  SearchStateEntity build() {
    _debouncer = Debouncer();
    ref.onDispose(_debouncer.dispose);

    final history = ref.read(searchHistoryLocalDataSourceProvider);
    final recentSearches = history.getRecentSearches();

    return SearchStateEntity(recentSearches: recentSearches);
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query, isSearching: query.isNotEmpty);
    if (query.isEmpty) {
      state = state.copyWith(results: [], isSearching: false);
      return;
    }
    _debouncer(() => _performSearch(query));
  }

  Future<void> _performSearch(String query) async {
    if (state.query != query) return;

    final result = await ref
        .read(searchLinksUsecaseProvider)
        .call(query, filter: state.filter);
    if (state.query != query) return;

    if (result.isSuccess) {
      state = state.copyWith(results: result.data!, isSearching: false);
    } else {
      state = state.copyWith(results: [], isSearching: false);
    }
  }

  void clearSearch() {
    state = state.copyWith(query: '', results: [], isSearching: false);
  }

  void addRecentSearch(String query) {
    if (query.isEmpty) return;
    final recent = [
      query,
      ...state.recentSearches.where((q) => q != query),
    ].take(10).toList();
    state = state.copyWith(recentSearches: recent);

    unawaited(
      ref.read(searchHistoryLocalDataSourceProvider).addRecentSearch(query),
    );
  }

  void removeRecentSearch(String query) {
    final recent = state.recentSearches.where((q) => q != query).toList();
    state = state.copyWith(recentSearches: recent);

    unawaited(
      ref.read(searchHistoryLocalDataSourceProvider).removeRecentSearch(query),
    );
  }

  void clearRecentSearches() {
    state = state.copyWith(recentSearches: []);

    unawaited(
      ref.read(searchHistoryLocalDataSourceProvider).clearRecentSearches(),
    );
  }

  // -------------------------------------------------------------------------
  // Filter methods
  // -------------------------------------------------------------------------

  void toggleTagFilter(String tagId) {
    final current = state.filter.selectedTagIds;
    final updated = current.contains(tagId)
        ? current.where((id) => id != tagId).toList()
        : [...current, tagId];
    state = state.copyWith(
      filter: state.filter.copyWith(selectedTagIds: updated),
    );
    _reSearchIfNeeded();
  }

  void toggleFavoritesFilter() {
    state = state.copyWith(
      filter: state.filter.copyWith(favoritesOnly: !state.filter.favoritesOnly),
    );
    _reSearchIfNeeded();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    state = state.copyWith(
      filter: state.filter.copyWith(dateFrom: from, dateTo: to),
    );
    _reSearchIfNeeded();
  }

  void clearFilters() {
    state = state.copyWith(filter: const SearchFilterEntity());
    _reSearchIfNeeded();
  }

  void _reSearchIfNeeded() {
    if (state.query.isNotEmpty) {
      state = state.copyWith(isSearching: true);
      _debouncer(() => _performSearch(state.query));
    }
  }

  /// Optimistic favorite toggle — mirrors link_list_provider pattern.
  Future<void> toggleFavorite(String id) async {
    final results = state.results;
    final index = results.indexWhere((l) => l.id == id);
    if (index == -1) return;

    final link = results[index];
    final previous = results;
    final updated = results.toList()
      ..[index] = link.copyWith(isFavorite: !link.isFavorite);
    state = state.copyWith(results: updated);

    final result = await ref
        .read(toggleFavoriteUsecaseProvider)
        .call(id, isFavorite: !link.isFavorite);
    if (result.isFailure) {
      state = state.copyWith(results: previous);
    }
  }
}

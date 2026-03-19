import 'package:linknote/core/utils/debouncer.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/search/domain/entity/search_state_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_provider.g.dart';

@riverpod
class Search extends _$Search {
  late final Debouncer _debouncer;

  @override
  SearchStateEntity build() {
    _debouncer = Debouncer();
    ref.onDispose(_debouncer.dispose);
    return const SearchStateEntity();
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
    if (state.query != query) return; // Stale query
    // TODO(linknote): Use SearchLinksUsecase via repository
    await Future.delayed(const Duration(milliseconds: 300));
    final mockResults = List.generate(
      5,
      (i) => LinkEntity(
        id: 'search_result_$i',
        url: 'https://example.com/result-$i',
        title: 'Result for "$query" — Article $i',
        description: 'Search result description',
        isFavorite: false,
        createdAt: DateTime.now().subtract(Duration(days: i)),
        updatedAt: DateTime.now().subtract(Duration(days: i)),
      ),
    );
    if (state.query == query) {
      state = state.copyWith(results: mockResults, isSearching: false);
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
  }
}

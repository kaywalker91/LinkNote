import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/utils/debouncer.dart';
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

    final result = await ref.read(searchLinksUsecaseProvider).call(query);
    if (state.query != query) return; // Query changed during fetch

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
  }
}

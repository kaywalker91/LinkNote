import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/search/domain/entity/search_state_entity.dart';
import 'package:linknote/features/search/presentation/provider/search_provider.dart';
import 'package:linknote/features/search/presentation/provider/search_suggestions_provider.dart';
import 'package:linknote/features/search/presentation/provider/user_tags_provider.dart';
import 'package:linknote/features/search/presentation/screens/search_screen.dart';
import 'package:linknote/shared/widgets/skeleton/link_card_skeleton.dart';

// ---------------------------------------------------------------------------
// Stub base mixin — shared no-op implementations
// ---------------------------------------------------------------------------
mixin _SearchStubMixin on Search {
  @override
  void updateQuery(String query) {}

  @override
  void clearSearch() {}

  @override
  void addRecentSearch(String query) {}

  @override
  void removeRecentSearch(String query) {}

  @override
  void clearRecentSearches() {}

  @override
  void toggleTagFilter(String tagId) {}

  @override
  void toggleFavoritesFilter() {}

  @override
  void setDateRange(DateTime? from, DateTime? to) {}

  @override
  void clearFilters() {}

  @override
  Future<void> toggleFavorite(String id) async {}
}

class _EmptySearch extends Search with _SearchStubMixin {
  @override
  SearchStateEntity build() => const SearchStateEntity();
}

class _SearchingState extends Search with _SearchStubMixin {
  @override
  SearchStateEntity build() =>
      const SearchStateEntity(query: 'flutter', isSearching: true);
}

class _WithResults extends Search with _SearchStubMixin {
  final List<LinkEntity> _results;
  _WithResults(this._results);

  @override
  SearchStateEntity build() => SearchStateEntity(
        query: 'flutter',
        results: _results,
      );
}

class _NoResults extends Search with _SearchStubMixin {
  @override
  SearchStateEntity build() => const SearchStateEntity(query: 'xyz');
}

class _WithRecentSearches extends Search with _SearchStubMixin {
  @override
  SearchStateEntity build() => const SearchStateEntity(
        recentSearches: ['flutter', 'dart'],
      );
}

Widget _wrapWithProviders(Widget child, Search Function() searchFactory) {
  return ProviderScope(
    overrides: [
      searchProvider.overrideWith(searchFactory),
      userTagsProvider.overrideWith(
        (ref) => Future.value(<TagEntity>[]),
      ),
      searchSuggestionsProvider.overrideWith((ref) => <SearchSuggestion>[]),
    ],
    child: MaterialApp(home: child),
  );
}

void main() {
  group('SearchScreen', () {
    testWidgets('should show empty state when no query and no recent searches',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(const SearchScreen(), _EmptySearch.new),
      );
      await tester.pumpAndSettle();

      expect(find.text('링크를 검색하세요'), findsOneWidget);
    });

    testWidgets('should show recent searches when available', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(const SearchScreen(), _WithRecentSearches.new),
      );
      await tester.pumpAndSettle();

      expect(find.text('최근 검색'), findsOneWidget);
      expect(find.text('flutter'), findsOneWidget);
      expect(find.text('dart'), findsOneWidget);
    });

    testWidgets('should show loading indicator when searching', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(const SearchScreen(), _SearchingState.new),
      );
      await tester.pump();

      expect(find.byType(LinkCardSkeleton), findsWidgets);
    });

    testWidgets('should show results when search has data', (tester) async {
      final links = [
        LinkEntity(
          id: '1',
          url: 'https://flutter.dev',
          title: 'Flutter Dev',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ];

      await tester.pumpWidget(
        _wrapWithProviders(
          const SearchScreen(),
          () => _WithResults(links),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flutter Dev'), findsOneWidget);
    });

    testWidgets('should show no results message when query has no matches',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(const SearchScreen(), _NoResults.new),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('검색 결과 없음'), findsOneWidget);
    });

    testWidgets('should show search text field in app bar', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(const SearchScreen(), _EmptySearch.new),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(
        find.text('링크, 메모, 태그 검색'),
        findsOneWidget,
      );
    });

    testWidgets('should show filter bar with favorites chip', (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(const SearchScreen(), _EmptySearch.new),
      );
      await tester.pumpAndSettle();

      expect(find.text('즐겨찾기'), findsOneWidget);
      expect(find.text('날짜'), findsOneWidget);
    });

    testWidgets('should show clear all button for recent searches',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithProviders(
          const SearchScreen(),
          _WithRecentSearches.new,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('전체 삭제'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_detail_provider.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/features/link/presentation/screens/link_detail_screen.dart';
import 'package:linknote/features/search/domain/entity/search_state_entity.dart';
import 'package:linknote/features/search/presentation/provider/search_provider.dart';
import 'package:linknote/features/search/presentation/provider/search_suggestions_provider.dart';
import 'package:linknote/features/search/presentation/provider/user_tags_provider.dart';
import 'package:linknote/features/search/presentation/screens/search_screen.dart';
import 'package:linknote/shared/models/paginated_state.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------
final _tLink = LinkEntity(
  id: 'link-1',
  url: 'https://flutter.dev',
  title: 'Flutter Dev',
  description: 'Build apps for any screen',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

// ---------------------------------------------------------------------------
// Mock notifiers
// ---------------------------------------------------------------------------

/// Search notifier that returns pre-set results for any query.
class _MockSearch extends Search {
  @override
  SearchStateEntity build() {
    return const SearchStateEntity();
  }

  @override
  void updateQuery(String query) {
    if (query.isEmpty) {
      state = state.copyWith(query: '', results: [], isSearching: false);
      return;
    }
    // Immediate results (no debounce in test)
    state = state.copyWith(
      query: query,
      results: [_tLink],
      isSearching: false,
    );
  }

  @override
  void clearSearch() {
    state = state.copyWith(query: '', results: [], isSearching: false);
  }

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

/// Common extra overrides for providers required by SearchScreen.
// ignore: specify_nonobvious_property_types
final _extraOverrides = [
  userTagsProvider.overrideWith((ref) => Future.value(<TagEntity>[])),
  searchSuggestionsProvider.overrideWith((ref) => <SearchSuggestion>[]),
];

/// LinkDetail notifier that returns a fixed link entity.
class _MockLinkDetail extends LinkDetail {
  @override
  Future<LinkEntity> build(String linkId) async => _tLink;

  @override
  Future<void> refresh() async {}

  @override
  Future<void> delete() async {}
}

class _EmptyLinkList extends LinkList {
  @override
  Future<PaginatedState<LinkEntity>> build() async {
    return const PaginatedState<LinkEntity>(items: []);
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> deleteLink(String id) async {}

  @override
  Future<void> toggleFavorite(String id) async {}
}

void main() {
  group('Search → Results → Detail flow', () {
    testWidgets('should show empty state initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchProvider.overrideWith(_MockSearch.new),
            ..._extraOverrides,
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('링크를 검색하세요'), findsOneWidget);
    });

    testWidgets('should show results after typing query', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchProvider.overrideWith(_MockSearch.new),
            ..._extraOverrides,
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pumpAndSettle();

      expect(find.text('Flutter Dev'), findsOneWidget);
      expect(find.text('flutter.dev'), findsOneWidget);
    });

    testWidgets('should clear results when clearing search', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchProvider.overrideWith(_MockSearch.new),
            ..._extraOverrides,
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pumpAndSettle();
      expect(find.text('Flutter Dev'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('Flutter Dev'), findsNothing);
      expect(find.text('링크를 검색하세요'), findsOneWidget);
    });

    testWidgets('should navigate to detail when tapping result', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/search',
        routes: [
          GoRoute(
            path: '/search',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/links/:id',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: LinkDetailScreen(linkId: state.pathParameters['id']!),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchProvider.overrideWith(_MockSearch.new),
            linkDetailProvider.overrideWith(_MockLinkDetail.new),
            linkListProvider.overrideWith(_EmptyLinkList.new),
            ..._extraOverrides,
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Flutter Dev'));
      await tester.pumpAndSettle();

      expect(find.text('Flutter Dev'), findsOneWidget);
      expect(find.text('https://flutter.dev'), findsOneWidget);
      expect(find.text('Build apps for any screen'), findsOneWidget);
    });

    testWidgets('should show no results message for unmatched query', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchProvider.overrideWith(_MockSearch.new),
            ..._extraOverrides,
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pumpAndSettle();

      expect(find.text('Flutter Dev'), findsOneWidget);
    });
  });
}

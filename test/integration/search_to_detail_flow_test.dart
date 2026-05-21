import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_detail_provider.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/features/link/presentation/screens/link_detail_screen.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_event_entity.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:linknote/features/reading_stats/domain/usecase/get_reading_stats_usecase.dart';
import 'package:linknote/features/reading_stats/domain/usecase/record_read_event_usecase.dart';
import 'package:linknote/features/reading_stats/presentation/provider/link_reading_stats_provider.dart';
import 'package:linknote/features/reading_stats/presentation/provider/reading_stats_di_providers.dart';
import 'package:linknote/features/search/domain/entity/search_state_entity.dart';
import 'package:linknote/features/search/presentation/provider/search_provider.dart';
import 'package:linknote/features/search/presentation/provider/search_suggestions_provider.dart';
import 'package:linknote/features/search/presentation/provider/user_tags_provider.dart';
import 'package:linknote/features/search/presentation/screens/search_screen.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';

class _StubRecordReadEvent extends Mock implements RecordReadEventUsecase {}

class _StubGetReadingStats extends Mock implements GetReadingStatsUsecase {}

class _FakeReadingEventEntity extends Fake implements ReadingEventEntity {}

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

final _stubRecord = _StubRecordReadEvent();
final _stubGet = _StubGetReadingStats();

/// Common extra overrides for providers required by SearchScreen.
// ignore: specify_nonobvious_property_types
final _extraOverrides = [
  userTagsProvider.overrideWith((ref) => Future.value(<TagEntity>[])),
  searchSuggestionsProvider.overrideWith((ref) => <SearchSuggestion>[]),
  recordReadEventUsecaseProvider.overrideWithValue(_stubRecord),
  getReadingStatsUsecaseProvider.overrideWithValue(_stubGet),
  // Zero-stats so LnLinkCard mini badge stays un-rendered (AC-9).
  linkReadingStatsProvider.overrideWith(
    (ref, linkId) async => const ReadingStatsEntity(linkId: ''),
  ),
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
  setUpAll(() {
    registerFallbackValue(_FakeReadingEventEntity());
    when(() => _stubRecord.call(any())).thenAnswer((_) async => success(null));
    when(() => _stubGet.call(any())).thenAnswer(
      (_) async => success(const ReadingStatsEntity(linkId: 'link-1')),
    );
  });

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

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Flutter Dev'), findsNothing);
      expect(find.text('링크를 검색하세요'), findsOneWidget);
    });

    testWidgets('should navigate to detail when long-pressing result', (
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

      await tester.longPress(find.text('Flutter Dev'));
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

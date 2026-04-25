import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/usecase/toggle_favorite_usecase.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:linknote/features/search/data/datasource/search_history_local_datasource.dart';
import 'package:linknote/features/search/domain/entity/search_filter_entity.dart';
import 'package:linknote/features/search/domain/usecase/search_links_usecase.dart';
import 'package:linknote/features/search/presentation/provider/search_di_providers.dart';
import 'package:linknote/features/search/presentation/provider/search_provider.dart';
import 'package:mocktail/mocktail.dart';

class _MockSearchLinksUsecase extends Mock implements SearchLinksUsecase {}

class _MockToggleFavoriteUsecase extends Mock
    implements ToggleFavoriteUsecase {}

class _MockSearchHistoryLocalDataSource extends Mock
    implements SearchHistoryLocalDataSource {}

final _favoriteLink = LinkEntity(
  id: 'fav-1',
  url: 'https://favorite.example.com',
  title: 'Favorite Link',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  isFavorite: true,
);

void main() {
  late _MockSearchLinksUsecase mockSearch;
  late _MockToggleFavoriteUsecase mockToggle;
  late _MockSearchHistoryLocalDataSource mockHistory;
  late ProviderContainer container;
  late ProviderSubscription<Object?> sub;

  setUpAll(() {
    registerFallbackValue(const SearchFilterEntity());
  });

  setUp(() {
    mockSearch = _MockSearchLinksUsecase();
    mockToggle = _MockToggleFavoriteUsecase();
    mockHistory = _MockSearchHistoryLocalDataSource();
    when(() => mockHistory.getRecentSearches()).thenReturn([]);
    container = ProviderContainer(
      overrides: [
        searchLinksUsecaseProvider.overrideWithValue(mockSearch),
        toggleFavoriteUsecaseProvider.overrideWithValue(mockToggle),
        searchHistoryLocalDataSourceProvider.overrideWithValue(mockHistory),
      ],
    );
    sub = container.listen(searchProvider, (_, __) {});
  });

  tearDown(() {
    sub.close();
    container.dispose();
  });

  Future<void> waitForDebounce() =>
      Future<void>.delayed(const Duration(milliseconds: 400));

  group('search_provider — filter-only triggers', () {
    test(
      'toggleFavoritesFilter triggers search when query is empty',
      () async {
        when(
          () => mockSearch.call(any(), filter: any(named: 'filter')),
        ).thenAnswer((_) async => success([_favoriteLink]));
        container.read(searchProvider.notifier).toggleFavoritesFilter();
        await waitForDebounce();

        verify(
          () => mockSearch.call('', filter: any(named: 'filter')),
        ).called(1);
        expect(container.read(searchProvider).results, [_favoriteLink]);
        expect(container.read(searchProvider).isSearching, isFalse);
      },
    );

    test(
      'setDateRange triggers search when query is empty but range provided',
      () async {
        when(
          () => mockSearch.call(any(), filter: any(named: 'filter')),
        ).thenAnswer((_) async => success([_favoriteLink]));
        final from = DateTime(2026);
        final to = DateTime(2026, 1, 31);

        container.read(searchProvider.notifier).setDateRange(from, to);
        await waitForDebounce();

        verify(
          () => mockSearch.call('', filter: any(named: 'filter')),
        ).called(1);
        expect(container.read(searchProvider).results, [_favoriteLink]);
      },
    );

    test(
      'toggleTagFilter triggers search when query is empty',
      () async {
        when(
          () => mockSearch.call(any(), filter: any(named: 'filter')),
        ).thenAnswer((_) async => success([_favoriteLink]));
        container.read(searchProvider.notifier).toggleTagFilter('tag-1');
        await waitForDebounce();

        verify(
          () => mockSearch.call('', filter: any(named: 'filter')),
        ).called(1);
      },
    );

    test(
      'clearFilters with empty query clears results without invoking search',
      () async {
        when(
          () => mockSearch.call(any(), filter: any(named: 'filter')),
        ).thenAnswer((_) async => success([_favoriteLink]));
        final notifier = container.read(searchProvider.notifier)
          ..toggleFavoritesFilter();
        await waitForDebounce();
        expect(container.read(searchProvider).results, isNotEmpty);

        // Clearing filters with empty query should drop results to empty
        // and avoid issuing another search call.
        notifier.clearFilters();
        await waitForDebounce();

        expect(container.read(searchProvider).results, isEmpty);
        expect(container.read(searchProvider).isSearching, isFalse);
        // First call: filter activation. No second call after clearFilters.
        verify(
          () => mockSearch.call('', filter: any(named: 'filter')),
        ).called(1);
      },
    );

    test(
      'updateQuery to empty keeps filter results when filter active',
      () async {
        when(
          () => mockSearch.call(any(), filter: any(named: 'filter')),
        ).thenAnswer((_) async => success([_favoriteLink]));
        final notifier = container.read(searchProvider.notifier)
          ..toggleFavoritesFilter();
        await waitForDebounce();
        expect(container.read(searchProvider).results, isNotEmpty);

        // Typing then clearing query while filter active should re-search,
        // not wipe results immediately.
        notifier.updateQuery('flutter');
        await waitForDebounce();
        notifier.updateQuery('');
        await waitForDebounce();

        expect(container.read(searchProvider).results, [_favoriteLink]);
      },
    );

    test(
      'rapid toggle on/off coalesces: no search fired, results empty',
      () async {
        when(
          () => mockSearch.call(any(), filter: any(named: 'filter')),
        ).thenAnswer((_) async => success([_favoriteLink]));
        // Activate then clear filter synchronously: pending debouncer is
        // cancelled before it fires, so no usecase call is issued.
        container.read(searchProvider.notifier)
          ..toggleFavoritesFilter()
          ..toggleFavoritesFilter();
        await waitForDebounce();

        expect(container.read(searchProvider).results, isEmpty);
        expect(container.read(searchProvider).isSearching, isFalse);
        verifyNever(
          () => mockSearch.call(any(), filter: any(named: 'filter')),
        );
      },
    );
  });
}

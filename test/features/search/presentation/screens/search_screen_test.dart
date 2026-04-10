import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/search/domain/entity/search_state_entity.dart';
import 'package:linknote/features/search/presentation/provider/search_provider.dart';
import 'package:linknote/features/search/presentation/screens/search_screen.dart';

class _EmptySearch extends Search {
  @override
  SearchStateEntity build() => const SearchStateEntity();

  @override
  void updateQuery(String query) {}

  @override
  void clearSearch() {}

  @override
  void addRecentSearch(String query) {}

  @override
  Future<void> toggleFavorite(String id) async {}
}

class _SearchingState extends Search {
  @override
  SearchStateEntity build() =>
      const SearchStateEntity(query: 'flutter', isSearching: true);

  @override
  void updateQuery(String query) {}

  @override
  void clearSearch() {}

  @override
  void addRecentSearch(String query) {}

  @override
  Future<void> toggleFavorite(String id) async {}
}

class _WithResults extends Search {
  final List<LinkEntity> _results;
  _WithResults(this._results);

  @override
  SearchStateEntity build() => SearchStateEntity(
        query: 'flutter',
        results: _results,
      );

  @override
  void updateQuery(String query) {}

  @override
  void clearSearch() {}

  @override
  void addRecentSearch(String query) {}

  @override
  Future<void> toggleFavorite(String id) async {}
}

class _NoResults extends Search {
  @override
  SearchStateEntity build() => const SearchStateEntity(
        query: 'xyz',
      );

  @override
  void updateQuery(String query) {}

  @override
  void clearSearch() {}

  @override
  void addRecentSearch(String query) {}

  @override
  Future<void> toggleFavorite(String id) async {}
}

class _WithRecentSearches extends Search {
  @override
  SearchStateEntity build() => const SearchStateEntity(
        recentSearches: ['flutter', 'dart'],
      );

  @override
  void updateQuery(String query) {}

  @override
  void clearSearch() {}

  @override
  void addRecentSearch(String query) {}

  @override
  Future<void> toggleFavorite(String id) async {}
}

void main() {
  group('SearchScreen', () {
    testWidgets('should show empty state when no query and no recent searches',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [searchProvider.overrideWith(_EmptySearch.new)],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search for links'), findsOneWidget);
    });

    testWidgets('should show recent searches when available', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchProvider.overrideWith(_WithRecentSearches.new),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recent searches'), findsOneWidget);
      expect(find.text('flutter'), findsOneWidget);
      expect(find.text('dart'), findsOneWidget);
    });

    testWidgets('should show loading indicator when searching', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [searchProvider.overrideWith(_SearchingState.new)],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
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
        ProviderScope(
          overrides: [
            searchProvider.overrideWith(() => _WithResults(links)),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flutter Dev'), findsOneWidget);
    });

    testWidgets('should show no results message when query has no matches',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [searchProvider.overrideWith(_NoResults.new)],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('No results for'), findsOneWidget);
    });

    testWidgets('should show search text field in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [searchProvider.overrideWith(_EmptySearch.new)],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(
        find.text('Search links, notes, tags'),
        findsOneWidget,
      );
    });
  });
}

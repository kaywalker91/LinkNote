import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';
import 'package:linknote/features/collection/presentation/screens/collection_list_screen.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class _LoadingCollectionList extends CollectionList {
  @override
  Future<PaginatedState<CollectionEntity>> build() {
    return Completer<PaginatedState<CollectionEntity>>().future;
  }
}

class _ErrorCollectionList extends CollectionList {
  @override
  Future<PaginatedState<CollectionEntity>> build() async {
    throw Exception('Network error');
  }

  @override
  Future<void> refresh() async {}
}

class _DataCollectionList extends CollectionList {
  final PaginatedState<CollectionEntity> _data;
  _DataCollectionList(this._data);

  @override
  Future<PaginatedState<CollectionEntity>> build() async => _data;

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> createCollection({
    required String name,
    String? description,
  }) async {}

  @override
  Future<void> updateCollection({
    required String id,
    required String name,
    String? description,
  }) async {}

  @override
  Future<void> deleteCollection(String id) async {}
}

void main() {
  group('CollectionListScreen', () {
    testWidgets('should show app bar with title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(_LoadingCollectionList.new),
          ],
          child: const MaterialApp(home: CollectionListScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Collections'), findsOneWidget);
    });

    testWidgets('should show skeletons when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(_LoadingCollectionList.new),
          ],
          child: const MaterialApp(home: CollectionListScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should show error state with retry button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(_ErrorCollectionList.new),
          ],
          child: const MaterialApp(home: CollectionListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('should show empty state when no collections', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(
              () => _DataCollectionList(
                const PaginatedState<CollectionEntity>(items: []),
              ),
            ),
          ],
          child: const MaterialApp(home: CollectionListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No collections yet'), findsOneWidget);
    });

    testWidgets('should show collection cards when data is loaded',
        (tester) async {
      final collections = [
        CollectionEntity(
          id: '1',
          name: 'Flutter Resources',
          description: 'Best Flutter links',
          linkCount: 5,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
        CollectionEntity(
          id: '2',
          name: 'Dart Tips',
          linkCount: 3,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(
              () => _DataCollectionList(
                PaginatedState<CollectionEntity>(items: collections),
              ),
            ),
          ],
          child: const MaterialApp(home: CollectionListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flutter Resources'), findsOneWidget);
      expect(find.text('Best Flutter links'), findsOneWidget);
      expect(find.text('5 links'), findsOneWidget);
      expect(find.text('Dart Tips'), findsOneWidget);
      expect(find.text('3 links'), findsOneWidget);
    });

    testWidgets('should show FAB for adding collections', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(
              () => _DataCollectionList(
                const PaginatedState<CollectionEntity>(items: []),
              ),
            ),
          ],
          child: const MaterialApp(home: CollectionListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/presentation/provider/collection_detail_provider.dart';
import 'package:linknote/features/collection/presentation/provider/collection_links_provider.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';
import 'package:linknote/features/collection/presentation/screens/collection_detail_screen.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:linknote/features/reading_stats/presentation/provider/link_reading_stats_provider.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class _LoadingCollectionDetail extends CollectionDetail {
  @override
  Future<CollectionEntity> build(String collectionId) {
    return Completer<CollectionEntity>().future;
  }
}

class _ErrorCollectionDetail extends CollectionDetail {
  @override
  Future<CollectionEntity> build(String collectionId) async {
    throw Exception('Failed to load');
  }

  @override
  Future<void> refresh() async {}
}

class _DataCollectionDetail extends CollectionDetail {
  final CollectionEntity _collection;
  _DataCollectionDetail(this._collection);

  @override
  Future<CollectionEntity> build(String collectionId) async => _collection;

  @override
  Future<void> refresh() async {}
}

class _SpyCollectionDetail extends CollectionDetail {
  _SpyCollectionDetail(this._collection);
  final CollectionEntity _collection;

  CollectionVisibility? lastVisibility;
  bool? lastLocked;

  @override
  Future<CollectionEntity> build(String collectionId) async => _collection;

  @override
  Future<void> refresh() async {}

  @override
  Future<void> setVisibility(CollectionVisibility visibility) async {
    lastVisibility = visibility;
  }

  @override
  Future<void> setLocked({required bool locked}) async {
    lastLocked = locked;
  }
}

class _ThrowingCollectionList extends CollectionList {
  @override
  Future<PaginatedState<CollectionEntity>> build() async =>
      const PaginatedState<CollectionEntity>(items: []);

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
  Future<void> deleteCollection(String id) async {
    throw Exception('Delete failed');
  }
}

class _StubCollectionList extends CollectionList {
  @override
  Future<PaginatedState<CollectionEntity>> build() async =>
      const PaginatedState<CollectionEntity>(items: []);

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

/// Zero-stats override so LnLinkCard mini badge stays un-rendered (AC-9).
// ignore: specify_nonobvious_property_types
final _zeroStatsOverride = linkReadingStatsProvider.overrideWith(
  (ref, linkId) async => const ReadingStatsEntity(linkId: ''),
);

void main() {
  final tCollection = CollectionEntity(
    id: 'c1',
    name: 'Flutter Resources',
    description: 'Best Flutter links',
    linkCount: 5,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final tLinks = [
    LinkEntity(
      id: 'l1',
      url: 'https://flutter.dev',
      title: 'Flutter Dev',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  ];

  group('CollectionDetailScreen', () {
    testWidgets('should show Collection in app bar when loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionDetailProvider.overrideWith(_LoadingCollectionDetail.new),
            collectionListProvider.overrideWith(_StubCollectionList.new),
            collectionLinksProvider.overrideWith(
              (ref, id) => Completer<List<LinkEntity>>().future,
            ),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(
            home: CollectionDetailScreen(collectionId: 'c1'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('컬렉션'), findsOneWidget);
    });

    testWidgets('should show error state with retry', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionDetailProvider.overrideWith(_ErrorCollectionDetail.new),
            collectionListProvider.overrideWith(_StubCollectionList.new),
            collectionLinksProvider.overrideWith(
              (ref, id) => Completer<List<LinkEntity>>().future,
            ),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(
            home: CollectionDetailScreen(collectionId: 'c1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('오류가 발생했습니다'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('should show collection details when data is loaded', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionDetailProvider.overrideWith(
              () => _DataCollectionDetail(tCollection),
            ),
            collectionListProvider.overrideWith(_StubCollectionList.new),
            collectionLinksProvider.overrideWith((ref, id) async => tLinks),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(
            home: CollectionDetailScreen(collectionId: 'c1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flutter Resources'), findsAtLeast(1));
      expect(find.text('Best Flutter links'), findsOneWidget);
      expect(find.text('링크 5개'), findsOneWidget);
    });

    testWidgets('should show links in the collection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionDetailProvider.overrideWith(
              () => _DataCollectionDetail(tCollection),
            ),
            collectionListProvider.overrideWith(_StubCollectionList.new),
            collectionLinksProvider.overrideWith((ref, id) async => tLinks),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(
            home: CollectionDetailScreen(collectionId: 'c1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flutter Dev'), findsOneWidget);
    });

    testWidgets('should show edit and delete buttons when data is loaded', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionDetailProvider.overrideWith(
              () => _DataCollectionDetail(tCollection),
            ),
            collectionListProvider.overrideWith(_StubCollectionList.new),
            collectionLinksProvider.overrideWith((ref, id) async => tLinks),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(
            home: CollectionDetailScreen(collectionId: 'c1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets(
      'delete tap should open confirmation dialog with destructive Delete',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              collectionDetailProvider.overrideWith(
                () => _DataCollectionDetail(tCollection),
              ),
              collectionListProvider.overrideWith(_StubCollectionList.new),
              collectionLinksProvider.overrideWith((ref, id) async => tLinks),
            ],
            child: const MaterialApp(
              home: CollectionDetailScreen(collectionId: 'c1'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        expect(find.text('컬렉션 삭제'), findsOneWidget);
        expect(find.text('삭제'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      },
    );

    testWidgets(
      'should show error snackbar when deleteCollection throws',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              collectionDetailProvider.overrideWith(
                () => _DataCollectionDetail(tCollection),
              ),
              collectionListProvider.overrideWith(_ThrowingCollectionList.new),
              collectionLinksProvider.overrideWith((ref, id) async => tLinks),
            ],
            child: const MaterialApp(
              home: CollectionDetailScreen(collectionId: 'c1'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open confirmation dialog
        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();
        // Confirm delete
        await tester.tap(find.widgetWithText(FilledButton, '삭제'));
        await tester.pumpAndSettle();

        expect(find.text('Failed to delete collection'), findsOneWidget);
      },
    );

    testWidgets('should render visibility and lock toggles when loaded', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionDetailProvider.overrideWith(
              () => _DataCollectionDetail(tCollection),
            ),
            collectionListProvider.overrideWith(_StubCollectionList.new),
            collectionLinksProvider.overrideWith((ref, id) async => tLinks),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(
            home: CollectionDetailScreen(collectionId: 'c1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('collection-visibility-toggle')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('collection-lock-toggle')),
        findsOneWidget,
      );
    });

    testWidgets('toggling visibility switch calls setVisibility(public)', (
      tester,
    ) async {
      final spy = _SpyCollectionDetail(tCollection); // defaults to private
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionDetailProvider.overrideWith(() => spy),
            collectionListProvider.overrideWith(_StubCollectionList.new),
            collectionLinksProvider.overrideWith((ref, id) async => tLinks),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(
            home: CollectionDetailScreen(collectionId: 'c1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('collection-visibility-toggle')),
      );
      await tester.pumpAndSettle();

      expect(spy.lastVisibility, CollectionVisibility.public);
    });

    testWidgets('toggling lock switch calls setLocked(true)', (tester) async {
      final spy = _SpyCollectionDetail(tCollection); // unlocked
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionDetailProvider.overrideWith(() => spy),
            collectionListProvider.overrideWith(_StubCollectionList.new),
            collectionLinksProvider.overrideWith((ref, id) async => tLinks),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(
            home: CollectionDetailScreen(collectionId: 'c1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('collection-lock-toggle')));
      await tester.pumpAndSettle();

      expect(spy.lastLocked, isTrue);
    });

    testWidgets('should show empty state when no links in collection', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionDetailProvider.overrideWith(
              () => _DataCollectionDetail(tCollection),
            ),
            collectionListProvider.overrideWith(_StubCollectionList.new),
            collectionLinksProvider.overrideWith((ref, id) async => []),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(
            home: CollectionDetailScreen(collectionId: 'c1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('이 컬렉션에 링크가 없어요'), findsOneWidget);
    });
  });
}

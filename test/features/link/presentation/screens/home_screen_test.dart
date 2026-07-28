import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/link_sort_order.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/features/link/presentation/provider/link_sort_provider.dart';
import 'package:linknote/features/link/presentation/screens/home_screen.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:linknote/features/reading_stats/presentation/provider/link_reading_stats_provider.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:linknote/shared/widgets/ln/ln_brand.dart';

/// Notifier that never completes — keeps the provider in AsyncLoading.
class _LoadingLinkList extends LinkList {
  @override
  Future<PaginatedState<LinkEntity>> build() {
    return Completer<PaginatedState<LinkEntity>>().future;
  }
}

/// Notifier that throws — puts the provider in AsyncError.
class _ErrorLinkList extends LinkList {
  @override
  Future<PaginatedState<LinkEntity>> build() async {
    throw Exception('Network error');
  }
}

/// Notifier that returns provided data — puts the provider in AsyncData.
class _DataLinkList extends LinkList {
  final PaginatedState<LinkEntity> _data;

  _DataLinkList(this._data);

  @override
  Future<PaginatedState<LinkEntity>> build() async => _data;

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> deleteLink(String id) async {}

  @override
  Future<void> toggleFavorite(String id) async {}
}

class _StubLinkSortNotifier extends LinkSortNotifier {
  _StubLinkSortNotifier(this.initialOrder);

  final LinkSortOrder initialOrder;
  int setCallCount = 0;
  LinkSortOrder get currentOrder => state;

  @override
  LinkSortOrder build() => initialOrder;

  @override
  Future<void> setSortOrder(LinkSortOrder order) async {
    if (state == order) return;
    setCallCount++;
    state = order;
  }
}

/// Provides zero-stats for linkReadingStatsProvider so mini badge
/// stays un-rendered in LnLinkCard mounts (AC-9).
// ignore: specify_nonobvious_property_types
final _zeroStatsOverride = linkReadingStatsProvider.overrideWith(
  (ref, linkId) async => const ReadingStatsEntity(linkId: ''),
);

void main() {
  group('HomeScreen', () {
    testWidgets('should show loading skeletons when state is loading', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkListProvider.overrideWith(_LoadingLinkList.new),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();

      // Assert — loading state shows skeleton items
      expect(find.byType(LinkNoteWordmark), findsOneWidget);
      // ListView.builder with 8 LinkCardSkeleton items
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should show error state with retry button on error', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkListProvider.overrideWith(_ErrorLinkList.new),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('오류가 발생했습니다'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('should show empty state when data has no links', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkListProvider.overrideWith(
              () => _DataLinkList(const PaginatedState<LinkEntity>(items: [])),
            ),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('저장된 링크가 없어요'), findsOneWidget);
      expect(find.text('링크 추가'), findsOneWidget);
    });

    testWidgets('should show link list when data has links', (tester) async {
      // Arrange
      final tLinks = [
        LinkEntity(
          id: '1',
          url: 'https://flutter.dev',
          title: 'Flutter',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
        LinkEntity(
          id: '2',
          url: 'https://dart.dev',
          title: 'Dart',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkListProvider.overrideWith(
              () => _DataLinkList(PaginatedState<LinkEntity>(items: tLinks)),
            ),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
    });

    testWidgets('should show segmented filter (전체 / ★ 즐겨찾기)', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkListProvider.overrideWith(
              () => _DataLinkList(const PaginatedState<LinkEntity>(items: [])),
            ),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('전체'), findsOneWidget);
      expect(find.text('★ 즐겨찾기'), findsOneWidget);
    });

    testWidgets('should show the current sort in the sort sheet', (
      tester,
    ) async {
      final sortNotifier = _StubLinkSortNotifier(LinkSortOrder.newest);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkListProvider.overrideWith(
              () => _DataLinkList(const PaginatedState<LinkEntity>(items: [])),
            ),
            linkSortProvider.overrideWith(() => sortNotifier),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.swap_vert_rounded));
      await tester.pumpAndSettle();

      expect(find.text('링크 정렬'), findsOneWidget);
      expect(find.text('최신순'), findsOneWidget);
      expect(find.text('최근 저장한 링크부터 표시'), findsOneWidget);
      expect(find.text('오래된순'), findsOneWidget);
      expect(find.text('먼저 저장한 링크부터 표시'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('should switch to oldest and close the sort sheet', (
      tester,
    ) async {
      final sortNotifier = _StubLinkSortNotifier(LinkSortOrder.newest);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkListProvider.overrideWith(
              () => _DataLinkList(const PaginatedState<LinkEntity>(items: [])),
            ),
            linkSortProvider.overrideWith(() => sortNotifier),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.swap_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('link-sort-oldest')));
      await tester.pumpAndSettle();

      expect(find.text('링크 정렬'), findsNothing);
      expect(sortNotifier.currentOrder, LinkSortOrder.oldest);
      expect(sortNotifier.setCallCount, 1);
    });

    testWidgets('should not update when the current sort is selected again', (
      tester,
    ) async {
      final sortNotifier = _StubLinkSortNotifier(LinkSortOrder.newest);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkListProvider.overrideWith(
              () => _DataLinkList(const PaginatedState<LinkEntity>(items: [])),
            ),
            linkSortProvider.overrideWith(() => sortNotifier),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.swap_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('link-sort-newest')));
      await tester.pumpAndSettle();

      expect(find.text('링크 정렬'), findsNothing);
      expect(sortNotifier.currentOrder, LinkSortOrder.newest);
      expect(sortNotifier.setCallCount, 0);
    });

    testWidgets('should NOT have its own FAB (shell provides global FAB)', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkListProvider.overrideWith(
              () => _DataLinkList(const PaginatedState<LinkEntity>(items: [])),
            ),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    // Notifications were deferred out of MVP (ADR-004): the bell was the only
    // entry point to `/notifications`, and the route is gone. The sort action
    // must survive so the top bar action row stays occupied — an empty
    // `actions` list would collapse the row and leave a bare band.
    testWidgets('should NOT show the notification bell (deferred, ADR-004)', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkListProvider.overrideWith(
              () => _DataLinkList(const PaginatedState<LinkEntity>(items: [])),
            ),
            _zeroStatsOverride,
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);
      expect(find.byIcon(Icons.swap_vert_rounded), findsOneWidget);

      // The remaining action shares the action row with the wordmark rather
      // than the row collapsing to an empty band.
      final wordmark = tester.getCenter(find.byType(LinkNoteWordmark));
      final sort = tester.getCenter(find.byIcon(Icons.swap_vert_rounded));
      expect((sort.dy - wordmark.dy).abs(), lessThan(4));
      expect(sort.dx, greaterThan(wordmark.dx));
    });
  });
}

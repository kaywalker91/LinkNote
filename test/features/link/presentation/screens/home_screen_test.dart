import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/features/link/presentation/screens/home_screen.dart';
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
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('전체'), findsOneWidget);
      expect(find.text('★ 즐겨찾기'), findsOneWidget);
    });

    testWidgets('should NOT have its own FAB (shell provides central FAB)', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkListProvider.overrideWith(
              () => _DataLinkList(const PaginatedState<LinkEntity>(items: [])),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}

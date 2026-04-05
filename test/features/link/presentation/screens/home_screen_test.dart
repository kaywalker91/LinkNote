import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/features/link/presentation/screens/home_screen.dart';
import 'package:linknote/shared/models/paginated_state.dart';

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
      expect(find.text('LinkNote'), findsOneWidget);
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
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
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
      expect(find.text('No links yet'), findsOneWidget);
      expect(find.text('Add Link'), findsOneWidget);
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

    testWidgets('should show filter chips (All and Favorites)', (tester) async {
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
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
    });

    testWidgets('should show FAB for adding links', (tester) async {
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
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}

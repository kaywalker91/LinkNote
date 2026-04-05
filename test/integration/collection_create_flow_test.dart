import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';
import 'package:linknote/features/collection/presentation/screens/collection_form_screen.dart';
import 'package:linknote/features/collection/presentation/screens/collection_list_screen.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------
class FakeCollectionEntity extends Fake implements CollectionEntity {}

// ---------------------------------------------------------------------------
// Mock notifiers
// ---------------------------------------------------------------------------
class _EmptyCollectionList extends CollectionList {
  @override
  Future<PaginatedState<CollectionEntity>> build() async {
    return const PaginatedState<CollectionEntity>(items: []);
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> createCollection({
    required String name,
    String? description,
  }) async {
    final current = state.value;
    if (current == null) return;
    final entity = CollectionEntity(
      id: 'new-1',
      name: name,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      description: description,
    );
    state = AsyncData(
      current.copyWith(items: [entity, ...current.items]),
    );
  }
}

class _PopulatedCollectionList extends CollectionList {
  @override
  Future<PaginatedState<CollectionEntity>> build() async {
    return PaginatedState<CollectionEntity>(
      items: [
        CollectionEntity(
          id: 'c1',
          name: 'Dev Resources',
          description: 'Useful dev links',
          linkCount: 5,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
        CollectionEntity(
          id: 'c2',
          name: 'Design Inspiration',
          linkCount: 3,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ],
    );
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadMore() async {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCollectionEntity());
  });

  group('Collection flow', () {
    testWidgets('should show empty state when no collections', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(_EmptyCollectionList.new),
          ],
          child: MaterialApp(
            home: const CollectionListScreen(),
            routes: {
              '/collections/new': (_) => const CollectionFormScreen(),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No collections yet'), findsOneWidget);
      expect(find.text('Organize your links into collections'), findsOneWidget);
    });

    testWidgets('should show collection cards with link count', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(_PopulatedCollectionList.new),
          ],
          child: const MaterialApp(home: CollectionListScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dev Resources'), findsOneWidget);
      expect(find.text('Useful dev links'), findsOneWidget);
      expect(find.text('5 links'), findsOneWidget);
      expect(find.text('Design Inspiration'), findsOneWidget);
      expect(find.text('3 links'), findsOneWidget);
    });

    testWidgets('should render new collection form', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(_EmptyCollectionList.new),
          ],
          child: const MaterialApp(home: CollectionFormScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('New Collection'), findsOneWidget);
      expect(find.text('Name *'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Create Collection'), findsOneWidget);
    });

    testWidgets('should not submit when name is empty', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(_EmptyCollectionList.new),
          ],
          child: const MaterialApp(home: CollectionFormScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Act — tap create with empty name
      await tester.tap(find.text('Create Collection'));
      await tester.pumpAndSettle();

      // Assert — still on form (name empty check in _submit returns early)
      expect(find.text('New Collection'), findsOneWidget);
    });

    testWidgets('should navigate list → form → back with new collection', (
      tester,
    ) async {
      // Arrange — GoRouter for the flow
      final router = GoRouter(
        initialLocation: '/collections',
        routes: [
          GoRoute(
            path: '/collections',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CollectionListScreen(),
            ),
          ),
          GoRoute(
            path: '/collections/new',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const CollectionFormScreen(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(_EmptyCollectionList.new),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert — on collection list with empty state
      expect(find.text('No collections yet'), findsOneWidget);

      // Act — navigate to form (do NOT await push — the Future completes on pop,
      // which would deadlock here)
      unawaited(router.push('/collections/new'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert — on form screen
      expect(find.text('New Collection'), findsOneWidget);

      // Act — fill form and create
      await tester.enterText(
        find.widgetWithText(TextField, 'Name *'),
        'My Collection',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'Test description',
      );
      await tester.tap(find.text('Create Collection'));
      // Use pump sequence instead of pumpAndSettle to avoid hanging on
      // CircularProgressIndicator (shown by PrimaryButtonWidget.isLoading)
      await tester.pump(); // start _submit(), setState(isSubmitting=true)
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // createCollection + context.pop()
      await tester.pump(); // apply navigation frame

      // Assert — back on list, new collection visible
      expect(find.text('My Collection'), findsOneWidget);
      expect(find.text('0 links'), findsOneWidget);
    });
  });
}

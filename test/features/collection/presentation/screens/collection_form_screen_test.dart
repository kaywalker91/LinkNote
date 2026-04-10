import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';
import 'package:linknote/features/collection/presentation/screens/collection_form_screen.dart';
import 'package:linknote/shared/models/paginated_state.dart';

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

void main() {
  group('CollectionFormScreen - create mode', () {
    testWidgets('should show New Collection in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(_StubCollectionList.new),
          ],
          child: const MaterialApp(home: CollectionFormScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('New Collection'), findsOneWidget);
    });

    testWidgets('should show name and description fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(_StubCollectionList.new),
          ],
          child: const MaterialApp(home: CollectionFormScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Name *'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('should show Create Collection button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(_StubCollectionList.new),
          ],
          child: const MaterialApp(home: CollectionFormScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create Collection'), findsOneWidget);
    });

    testWidgets('should show hint texts in text fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionListProvider.overrideWith(_StubCollectionList.new),
          ],
          child: const MaterialApp(home: CollectionFormScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('e.g. Dev Resources'), findsOneWidget);
      expect(find.text('What is this collection about?'), findsOneWidget);
    });
  });
}

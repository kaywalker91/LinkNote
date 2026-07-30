import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';
import 'package:linknote/features/collection/presentation/widgets/collection_picker_sheet.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class _LoadingCollectionList extends CollectionList {
  @override
  Future<PaginatedState<CollectionEntity>> build() {
    return Completer<PaginatedState<CollectionEntity>>().future;
  }
}

class _ErrorCollectionList extends CollectionList {
  int refreshCount = 0;

  @override
  Future<PaginatedState<CollectionEntity>> build() async {
    throw Exception('Network error');
  }

  @override
  Future<void> refresh() async {
    refreshCount++;
  }
}

class _DataCollectionList extends CollectionList {
  _DataCollectionList(this._items);

  final List<CollectionEntity> _items;

  @override
  Future<PaginatedState<CollectionEntity>> build() async =>
      PaginatedState<CollectionEntity>(items: _items);

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadMore() async {}
}

CollectionEntity _collection(String id, String name) {
  final now = DateTime(2026);
  return CollectionEntity(id: id, name: name, createdAt: now, updatedAt: now);
}

void main() {
  group('CollectionPickerSheet', () {
    late CollectionPick? picked;
    late bool returned;

    setUp(() {
      picked = null;
      returned = false;
    });

    Widget buildHost(CollectionList Function() createNotifier) {
      return ProviderScope(
        overrides: [collectionListProvider.overrideWith(createNotifier)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  picked = await showCollectionPickerSheet(context);
                  returned = true;
                },
                child: const Text('열기'),
              ),
            ),
          ),
        ),
      );
    }

    Future<void> openSheet(WidgetTester tester) async {
      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
    }

    testWidgets('should list 없음 plus every collection', (tester) async {
      // Arrange
      await tester.pumpWidget(
        buildHost(
          () => _DataCollectionList([
            _collection('c1', '개발'),
            _collection('c2', '디자인 레퍼런스'),
          ]),
        ),
      );

      // Act
      await openSheet(tester);

      // Assert
      expect(find.text('없음'), findsOneWidget);
      expect(find.text('개발'), findsOneWidget);
      expect(find.text('디자인 레퍼런스'), findsOneWidget);
    });

    testWidgets('should show a hint when there are no collections', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildHost(() => _DataCollectionList(const [])));

      // Act
      await openSheet(tester);

      // Assert — 없음 stays selectable, with an explanatory hint below it.
      expect(find.text('없음'), findsOneWidget);
      expect(find.text('컬렉션이 없어요'), findsOneWidget);
    });

    testWidgets('should return the tapped collection id', (tester) async {
      // Arrange
      await tester.pumpWidget(
        buildHost(() => _DataCollectionList([_collection('c1', '개발')])),
      );
      await openSheet(tester);

      // Act
      await tester.tap(find.text('개발'));
      await tester.pumpAndSettle();

      // Assert
      expect(picked?.id, 'c1');
    });

    testWidgets('should return a null id when 없음 is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(
        buildHost(() => _DataCollectionList([_collection('c1', '개발')])),
      );
      await openSheet(tester);

      // Act
      await tester.tap(find.text('없음'));
      await tester.pumpAndSettle();

      // Assert — a pick of "없음" is distinguishable from a dismissal.
      expect(returned, isTrue);
      expect(picked, isNotNull);
      expect(picked?.id, isNull);
    });

    testWidgets('should return null when dismissed without a pick', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        buildHost(() => _DataCollectionList([_collection('c1', '개발')])),
      );
      await openSheet(tester);

      // Act — tap the barrier above the sheet.
      await tester.tapAt(const Offset(400, 20));
      await tester.pumpAndSettle();

      // Assert
      expect(returned, isTrue);
      expect(picked, isNull);
    });

    testWidgets('should show a spinner while loading', (tester) async {
      // Arrange
      await tester.pumpWidget(buildHost(_LoadingCollectionList.new));

      // Act
      await tester.tap(find.text('열기'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show a retry action on error', (tester) async {
      // Arrange
      final notifier = _ErrorCollectionList();
      await tester.pumpWidget(buildHost(() => notifier));
      await openSheet(tester);

      // Assert
      expect(find.text('컬렉션을 불러오지 못했습니다'), findsOneWidget);

      // Act
      await tester.tap(find.text('다시 시도'));
      await tester.pumpAndSettle();

      // Assert
      expect(notifier.refreshCount, 1);
    });
  });
}

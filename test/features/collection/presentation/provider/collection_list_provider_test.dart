import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/usecase/create_collection_usecase.dart';
import 'package:linknote/features/collection/domain/usecase/delete_collection_usecase.dart';
import 'package:linknote/features/collection/domain/usecase/get_collection_detail_usecase.dart';
import 'package:linknote/features/collection/domain/usecase/get_collections_usecase.dart';
import 'package:linknote/features/collection/domain/usecase/update_collection_usecase.dart';
import 'package:linknote/features/collection/presentation/provider/collection_detail_provider.dart';
import 'package:linknote/features/collection/presentation/provider/collection_di_providers.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCollectionsUsecase extends Mock implements GetCollectionsUsecase {}

class MockCreateCollectionUsecase extends Mock
    implements CreateCollectionUsecase {}

class MockUpdateCollectionUsecase extends Mock
    implements UpdateCollectionUsecase {}

class MockDeleteCollectionUsecase extends Mock
    implements DeleteCollectionUsecase {}

class MockGetCollectionDetailUsecase extends Mock
    implements GetCollectionDetailUsecase {}

class FakeCollectionEntity extends Fake implements CollectionEntity {}

void main() {
  late MockGetCollectionsUsecase mockGet;
  late MockCreateCollectionUsecase mockCreate;
  late MockUpdateCollectionUsecase mockUpdate;
  late MockDeleteCollectionUsecase mockDelete;
  late MockGetCollectionDetailUsecase mockDetail;

  final tNow = DateTime(2026);
  final tCollection = CollectionEntity(
    id: 'col-1',
    name: 'Test',
    createdAt: tNow,
    updatedAt: tNow,
  );

  setUpAll(() {
    registerFallbackValue(FakeCollectionEntity());
  });

  setUp(() {
    mockGet = MockGetCollectionsUsecase();
    mockCreate = MockCreateCollectionUsecase();
    mockUpdate = MockUpdateCollectionUsecase();
    mockDelete = MockDeleteCollectionUsecase();
    mockDetail = MockGetCollectionDetailUsecase();

    when(() => mockGet.call(cursor: any(named: 'cursor'))).thenAnswer(
      (_) async => success(const PaginatedState<CollectionEntity>(items: [])),
    );
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getCollectionsUsecaseProvider.overrideWithValue(mockGet),
        createCollectionUsecaseProvider.overrideWithValue(mockCreate),
        updateCollectionUsecaseProvider.overrideWithValue(mockUpdate),
        deleteCollectionUsecaseProvider.overrideWithValue(mockDelete),
        getCollectionDetailUsecaseProvider.overrideWithValue(mockDetail),
      ],
    );
  }

  group('CollectionList', () {
    group('createCollection', () {
      test('should prepend created collection on success', () async {
        // Arrange
        when(() => mockCreate.call(any())).thenAnswer(
          (_) async => success(tCollection),
        );

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(collectionListProvider.future);

        // Act
        await container
            .read(collectionListProvider.notifier)
            .createCollection(name: 'Test');

        // Assert
        final state = container.read(collectionListProvider).value!;
        expect(state.items, [tCollection]);
      });

      test('should throw Failure on create failure', () async {
        // Arrange
        const failure = Failure.server(message: 'Create failed');
        when(() => mockCreate.call(any())).thenAnswer(
          (_) async => error(failure),
        );

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(collectionListProvider.future);

        // Act + Assert
        await expectLater(
          () => container
              .read(collectionListProvider.notifier)
              .createCollection(name: 'Test'),
          throwsA(isA<Failure>()),
        );
      });
    });

    group('updateCollection', () {
      test('should throw Failure when id is not found in state', () async {
        // Arrange — seed empty list
        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(collectionListProvider.future);

        // Act + Assert — should throw Failure instead of StateError
        await expectLater(
          () => container
              .read(collectionListProvider.notifier)
              .updateCollection(id: 'missing-id', name: 'New'),
          throwsA(isA<Failure>()),
        );
        verifyNever(() => mockUpdate.call(any()));
      });

      test('should invalidate collectionDetailProvider on success', () async {
        // Arrange — seed and wire detail provider
        final tUpdated = tCollection.copyWith(name: 'Renamed');
        when(() => mockGet.call(cursor: any(named: 'cursor'))).thenAnswer(
          (_) async => success(
            PaginatedState<CollectionEntity>(items: [tCollection]),
          ),
        );
        when(() => mockUpdate.call(any())).thenAnswer(
          (_) async => success(tUpdated),
        );
        var detailCalls = 0;
        when(() => mockDetail.call(any())).thenAnswer((_) async {
          detailCalls++;
          return success(tCollection);
        });

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(collectionListProvider.future);

        // Keep detail provider alive
        final sub = container.listen(
          collectionDetailProvider('col-1'),
          (_, __) {},
        );
        addTearDown(sub.close);
        await container.read(collectionDetailProvider('col-1').future);
        expect(detailCalls, 1);

        // Act
        await container
            .read(collectionListProvider.notifier)
            .updateCollection(id: 'col-1', name: 'Renamed');

        // Assert — invalidate should trigger rebuild on kept-alive listener
        await container.read(collectionDetailProvider('col-1').future);
        expect(detailCalls, 2);
      });

      test('should throw Failure on update failure', () async {
        // Arrange — seed one collection
        when(() => mockGet.call(cursor: any(named: 'cursor'))).thenAnswer(
          (_) async => success(
            PaginatedState<CollectionEntity>(items: [tCollection]),
          ),
        );
        const failure = Failure.server(message: 'Update failed');
        when(() => mockUpdate.call(any())).thenAnswer(
          (_) async => error(failure),
        );

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(collectionListProvider.future);

        // Act + Assert
        await expectLater(
          () => container
              .read(collectionListProvider.notifier)
              .updateCollection(id: 'col-1', name: 'New'),
          throwsA(isA<Failure>()),
        );
      });
    });
  });
}

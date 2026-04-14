import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/usecase/create_collection_usecase.dart';
import 'package:linknote/features/collection/domain/usecase/delete_collection_usecase.dart';
import 'package:linknote/features/collection/domain/usecase/get_collections_usecase.dart';
import 'package:linknote/features/collection/domain/usecase/update_collection_usecase.dart';
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

class FakeCollectionEntity extends Fake implements CollectionEntity {}

void main() {
  late MockGetCollectionsUsecase mockGet;
  late MockCreateCollectionUsecase mockCreate;
  late MockUpdateCollectionUsecase mockUpdate;
  late MockDeleteCollectionUsecase mockDelete;

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

import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';
import 'package:linknote/features/collection/domain/usecase/get_collections_usecase.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';

class MockCollectionRepository extends Mock implements ICollectionRepository {}

void main() {
  late GetCollectionsUsecase sut;
  late MockCollectionRepository mockRepository;

  setUp(() {
    mockRepository = MockCollectionRepository();
    sut = GetCollectionsUsecase(mockRepository);
  });

  final tCollections = [
    CollectionEntity(
      id: '1',
      name: 'Collection 1',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
    CollectionEntity(
      id: '2',
      name: 'Collection 2',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  ];

  group('GetCollectionsUsecase', () {
    test(
      'should return paginated collections when repository succeeds',
      () async {
        // Arrange
        final tState = PaginatedState<CollectionEntity>(
          items: tCollections,
          hasMore: true,
          nextCursor: '2026-01-01T00:00:00.000Z',
        );
        when(
          () => mockRepository.getCollections(
            cursor: any(named: 'cursor'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => success(tState));

        // Act
        final result = await sut.call();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data!.items, equals(tCollections));
        expect(result.data!.hasMore, isTrue);
        verify(() => mockRepository.getCollections()).called(1);
      },
    );

    test('should return empty list when no collections exist', () async {
      // Arrange
      const tEmptyState = PaginatedState<CollectionEntity>(items: []);
      when(
        () => mockRepository.getCollections(
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => success(tEmptyState));

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data!.items, isEmpty);
      expect(result.data!.hasMore, isFalse);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.network(message: 'No connection');
      when(
        () => mockRepository.getCollections(
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
    });

    test('should pass cursor and pageSize parameters correctly', () async {
      // Arrange
      const tState = PaginatedState<CollectionEntity>(items: []);
      when(
        () => mockRepository.getCollections(
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => success(tState));

      // Act
      await sut.call(cursor: 'some-cursor', pageSize: 10);

      // Assert
      verify(
        () => mockRepository.getCollections(
          cursor: 'some-cursor',
          pageSize: 10,
        ),
      ).called(1);
    });
  });
}

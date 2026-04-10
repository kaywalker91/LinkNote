import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';
import 'package:linknote/features/collection/domain/usecase/create_collection_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCollectionRepository extends Mock implements ICollectionRepository {}

class FakeCollectionEntity extends Fake implements CollectionEntity {}

void main() {
  late CreateCollectionUsecase sut;
  late MockCollectionRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeCollectionEntity());
  });

  setUp(() {
    mockRepository = MockCollectionRepository();
    sut = CreateCollectionUsecase(mockRepository);
  });

  final tCollection = CollectionEntity(
    id: 'test-id',
    name: 'Test Collection',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final tCreatedCollection = CollectionEntity(
    id: 'created-id',
    name: 'Test Collection',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  group('CreateCollectionUsecase', () {
    test(
      'should return CollectionEntity when repository creates successfully',
      () async {
        // Arrange
        when(
          () => mockRepository.createCollection(any()),
        ).thenAnswer((_) async => success(tCreatedCollection));

        // Act
        final result = await sut.call(tCollection);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(tCreatedCollection));
        verify(() => mockRepository.createCollection(tCollection)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Insert failed');
      when(
        () => mockRepository.createCollection(any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call(tCollection);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(() => mockRepository.createCollection(tCollection)).called(1);
    });
  });
}

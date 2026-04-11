import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';
import 'package:linknote/features/collection/domain/usecase/update_collection_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCollectionRepository extends Mock implements ICollectionRepository {}

class FakeCollectionEntity extends Fake implements CollectionEntity {}

void main() {
  late UpdateCollectionUsecase sut;
  late MockCollectionRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeCollectionEntity());
  });

  setUp(() {
    mockRepository = MockCollectionRepository();
    sut = UpdateCollectionUsecase(mockRepository);
  });

  final tCollection = CollectionEntity(
    id: 'test-id',
    name: 'Test Collection',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final tUpdatedCollection = CollectionEntity(
    id: 'test-id',
    name: 'Updated Collection',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  group('UpdateCollectionUsecase', () {
    test(
      'should return updated CollectionEntity when repository succeeds',
      () async {
        // Arrange
        when(
          () => mockRepository.updateCollection(any()),
        ).thenAnswer((_) async => success(tUpdatedCollection));

        // Act
        final result = await sut.call(tCollection);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(tUpdatedCollection));
        verify(() => mockRepository.updateCollection(tCollection)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Update failed');
      when(
        () => mockRepository.updateCollection(any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call(tCollection);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(() => mockRepository.updateCollection(tCollection)).called(1);
    });
  });
}

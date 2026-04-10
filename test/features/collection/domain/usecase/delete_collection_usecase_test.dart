import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';
import 'package:linknote/features/collection/domain/usecase/delete_collection_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCollectionRepository extends Mock implements ICollectionRepository {}

void main() {
  late DeleteCollectionUsecase sut;
  late MockCollectionRepository mockRepository;

  setUp(() {
    mockRepository = MockCollectionRepository();
    sut = DeleteCollectionUsecase(mockRepository);
  });

  const tId = 'test-id';

  group('DeleteCollectionUsecase', () {
    test('should return success when repository deletes successfully',
        () async {
      // Arrange
      when(
        () => mockRepository.deleteCollection(any()),
      ).thenAnswer((_) async => success(null));

      // Act
      final result = await sut.call(tId);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.deleteCollection(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Delete failed');
      when(
        () => mockRepository.deleteCollection(any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call(tId);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(() => mockRepository.deleteCollection(tId)).called(1);
    });
  });
}

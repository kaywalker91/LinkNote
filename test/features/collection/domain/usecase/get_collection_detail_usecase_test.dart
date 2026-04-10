import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';
import 'package:linknote/features/collection/domain/usecase/get_collection_detail_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCollectionRepository extends Mock implements ICollectionRepository {}

void main() {
  late GetCollectionDetailUsecase sut;
  late MockCollectionRepository mockRepository;

  setUp(() {
    mockRepository = MockCollectionRepository();
    sut = GetCollectionDetailUsecase(mockRepository);
  });

  const tId = 'test-id';

  final tCollection = CollectionEntity(
    id: tId,
    name: 'Test Collection',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  group('GetCollectionDetailUsecase', () {
    test('should return CollectionEntity when repository succeeds', () async {
      // Arrange
      when(
        () => mockRepository.getCollectionById(any()),
      ).thenAnswer((_) async => success(tCollection));

      // Act
      final result = await sut.call(tId);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tCollection));
      verify(() => mockRepository.getCollectionById(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Not found');
      when(
        () => mockRepository.getCollectionById(any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call(tId);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(() => mockRepository.getCollectionById(tId)).called(1);
    });
  });
}

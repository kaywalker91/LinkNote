import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';
import 'package:linknote/features/collection/domain/usecase/update_collection_visibility_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockCollectionRepository extends Mock implements ICollectionRepository {}

void main() {
  late UpdateCollectionVisibilityUsecase sut;
  late MockCollectionRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(CollectionVisibility.private);
  });

  setUp(() {
    mockRepository = MockCollectionRepository();
    sut = UpdateCollectionVisibilityUsecase(mockRepository);
  });

  final tCollection = CollectionEntity(
    id: 'test-id',
    name: 'Test Collection',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    visibility: CollectionVisibility.public,
  );

  group('UpdateCollectionVisibilityUsecase', () {
    test(
      'should forward id/visibility/lockedAt to repository on success',
      () async {
        // Arrange
        final tLockedAt = DateTime.utc(2026, 3, 15);
        when(
          () => mockRepository.updateCollectionVisibility(
            id: any(named: 'id'),
            visibility: any(named: 'visibility'),
            lockedAt: any(named: 'lockedAt'),
          ),
        ).thenAnswer((_) async => success(tCollection));

        // Act
        final result = await sut.call(
          id: 'test-id',
          visibility: CollectionVisibility.public,
          lockedAt: tLockedAt,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(tCollection));
        verify(
          () => mockRepository.updateCollectionVisibility(
            id: 'test-id',
            visibility: CollectionVisibility.public,
            lockedAt: tLockedAt,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Visibility update failed');
      when(
        () => mockRepository.updateCollectionVisibility(
          id: any(named: 'id'),
          visibility: any(named: 'visibility'),
          lockedAt: any(named: 'lockedAt'),
        ),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call(
        id: 'test-id',
        visibility: CollectionVisibility.private,
        lockedAt: null,
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
    });
  });
}

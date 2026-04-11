import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';
import 'package:linknote/features/link/domain/usecase/delete_link_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockLinkRepository extends Mock implements ILinkRepository {}

void main() {
  late DeleteLinkUsecase sut;
  late MockLinkRepository mockRepository;

  setUp(() {
    mockRepository = MockLinkRepository();
    sut = DeleteLinkUsecase(mockRepository);
  });

  const tId = 'test-id';

  group('DeleteLinkUsecase', () {
    test(
      'should return success when repository deletes successfully',
      () async {
        // Arrange
        when(
          () => mockRepository.deleteLink(any()),
        ).thenAnswer((_) async => success(null));

        // Act
        final result = await sut.call(tId);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(() => mockRepository.deleteLink(tId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Delete failed');
      when(
        () => mockRepository.deleteLink(any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call(tId);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(() => mockRepository.deleteLink(tId)).called(1);
    });
  });
}

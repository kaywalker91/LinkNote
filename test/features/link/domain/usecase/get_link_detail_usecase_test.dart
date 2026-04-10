import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';
import 'package:linknote/features/link/domain/usecase/get_link_detail_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockLinkRepository extends Mock implements ILinkRepository {}

void main() {
  late GetLinkDetailUsecase sut;
  late MockLinkRepository mockRepository;

  setUp(() {
    mockRepository = MockLinkRepository();
    sut = GetLinkDetailUsecase(mockRepository);
  });

  const tId = 'test-id';

  final tLink = LinkEntity(
    id: tId,
    url: 'https://example.com',
    title: 'Test Link',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  group('GetLinkDetailUsecase', () {
    test('should return LinkEntity when repository succeeds', () async {
      // Arrange
      when(
        () => mockRepository.getLinkById(any()),
      ).thenAnswer((_) async => success(tLink));

      // Act
      final result = await sut.call(tId);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tLink));
      verify(() => mockRepository.getLinkById(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Not found');
      when(
        () => mockRepository.getLinkById(any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call(tId);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(() => mockRepository.getLinkById(tId)).called(1);
    });
  });
}

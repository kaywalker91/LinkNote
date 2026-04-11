import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';
import 'package:linknote/features/link/domain/usecase/update_link_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockLinkRepository extends Mock implements ILinkRepository {}

class FakeLinkEntity extends Fake implements LinkEntity {}

void main() {
  late UpdateLinkUsecase sut;
  late MockLinkRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeLinkEntity());
  });

  setUp(() {
    mockRepository = MockLinkRepository();
    sut = UpdateLinkUsecase(mockRepository);
  });

  final tLink = LinkEntity(
    id: 'test-id',
    url: 'https://example.com',
    title: 'Test Link',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final tUpdatedLink = LinkEntity(
    id: 'test-id',
    url: 'https://example.com',
    title: 'Updated Link',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  group('UpdateLinkUsecase', () {
    test('should return updated LinkEntity when repository succeeds', () async {
      // Arrange
      when(
        () => mockRepository.updateLink(any()),
      ).thenAnswer((_) async => success(tUpdatedLink));

      // Act
      final result = await sut.call(tLink);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tUpdatedLink));
      verify(() => mockRepository.updateLink(tLink)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Update failed');
      when(
        () => mockRepository.updateLink(any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call(tLink);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(() => mockRepository.updateLink(tLink)).called(1);
    });
  });
}

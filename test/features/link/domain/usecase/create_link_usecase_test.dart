import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';
import 'package:linknote/features/link/domain/usecase/create_link_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockLinkRepository extends Mock implements ILinkRepository {}

class FakeLinkEntity extends Fake implements LinkEntity {}

void main() {
  late CreateLinkUsecase sut;
  late MockLinkRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeLinkEntity());
  });

  setUp(() {
    mockRepository = MockLinkRepository();
    sut = CreateLinkUsecase(mockRepository);
  });

  final tLink = LinkEntity(
    id: 'test-id',
    url: 'https://example.com',
    title: 'Test Link',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final tCreatedLink = LinkEntity(
    id: 'created-id',
    url: 'https://example.com',
    title: 'Test Link',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  group('CreateLinkUsecase', () {
    test('should return LinkEntity when repository creates successfully', () async {
      // Arrange
      when(() => mockRepository.createLink(any()))
          .thenAnswer((_) async => success(tCreatedLink));

      // Act
      final result = await sut.call(tLink);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tCreatedLink));
      verify(() => mockRepository.createLink(tLink)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Insert failed');
      when(() => mockRepository.createLink(any()))
          .thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call(tLink);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(() => mockRepository.createLink(tLink)).called(1);
    });
  });
}

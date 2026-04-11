import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/profile/domain/entity/user_profile_entity.dart';
import 'package:linknote/features/profile/domain/repository/i_profile_repository.dart';
import 'package:linknote/features/profile/domain/usecase/get_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late GetProfileUsecase sut;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    sut = GetProfileUsecase(mockRepository);
  });

  const tProfile = UserProfileEntity(
    id: 'user-123',
    email: 'test@example.com',
    displayName: 'Test User',
    linkCount: 5,
    collectionCount: 2,
  );

  group('GetProfileUsecase', () {
    test('should return UserProfileEntity when repository succeeds', () async {
      // Arrange
      when(
        () => mockRepository.getProfile(),
      ).thenAnswer((_) async => success(tProfile));

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tProfile));
      verify(() => mockRepository.getProfile()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Profile not found');
      when(
        () => mockRepository.getProfile(),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(() => mockRepository.getProfile()).called(1);
    });
  });
}

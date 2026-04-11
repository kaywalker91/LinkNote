import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/profile/domain/entity/user_profile_entity.dart';
import 'package:linknote/features/profile/domain/repository/i_profile_repository.dart';
import 'package:linknote/features/profile/domain/usecase/update_profile_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

void main() {
  late UpdateProfileUsecase sut;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    sut = UpdateProfileUsecase(mockRepository);
  });

  const tUpdatedProfile = UserProfileEntity(
    id: 'user-123',
    email: 'test@example.com',
    displayName: 'New Name',
    linkCount: 5,
    collectionCount: 2,
  );

  group('UpdateProfileUsecase', () {
    test(
      'should return updated UserProfileEntity when repository succeeds',
      () async {
        // Arrange
        when(
          () => mockRepository.updateProfile(
            displayName: any(named: 'displayName'),
            avatarUrl: any(named: 'avatarUrl'),
          ),
        ).thenAnswer((_) async => success(tUpdatedProfile));

        // Act
        final result = await sut.call(displayName: 'New Name');

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(tUpdatedProfile));
        verify(
          () => mockRepository.updateProfile(displayName: 'New Name'),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Update failed');
      when(
        () => mockRepository.updateProfile(
          displayName: any(named: 'displayName'),
          avatarUrl: any(named: 'avatarUrl'),
        ),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call(displayName: 'New Name');

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(
        () => mockRepository.updateProfile(displayName: 'New Name'),
      ).called(1);
    });
  });
}

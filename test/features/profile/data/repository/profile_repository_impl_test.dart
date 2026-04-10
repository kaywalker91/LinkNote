import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/profile/data/datasource/profile_remote_datasource.dart';
import 'package:linknote/features/profile/data/repository/profile_repository_impl.dart';
import 'package:linknote/features/profile/domain/entity/user_profile_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

void main() {
  late ProfileRepositoryImpl sut;
  late MockProfileRemoteDataSource mockRemote;

  setUp(() {
    mockRemote = MockProfileRemoteDataSource();
    sut = ProfileRepositoryImpl(mockRemote);
  });

  const tProfile = UserProfileEntity(
    id: 'user-1',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  // ---------------------------------------------------------------------------
  // getProfile
  // ---------------------------------------------------------------------------
  group('getProfile', () {
    test('should return profile on success', () async {
      // Arrange
      when(() => mockRemote.getProfile())
          .thenAnswer((_) async => success(tProfile));

      // Act
      final result = await sut.getProfile();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tProfile));
      verify(() => mockRemote.getProfile()).called(1);
    });

    test('should return failure on error', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Not found');
      when(() => mockRemote.getProfile())
          .thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.getProfile();

      // Assert
      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // updateProfile
  // ---------------------------------------------------------------------------
  group('updateProfile', () {
    test('should return updated profile on success', () async {
      // Arrange
      const tUpdated = UserProfileEntity(
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Updated Name',
      );
      when(
        () => mockRemote.updateProfile(
          displayName: any(named: 'displayName'),
          avatarUrl: any(named: 'avatarUrl'),
        ),
      ).thenAnswer((_) async => success(tUpdated));

      // Act
      final result = await sut.updateProfile(displayName: 'Updated Name');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data!.displayName, equals('Updated Name'));
    });

    test('should return failure on error', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Update failed');
      when(
        () => mockRemote.updateProfile(
          displayName: any(named: 'displayName'),
          avatarUrl: any(named: 'avatarUrl'),
        ),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.updateProfile(displayName: 'New Name');

      // Assert
      expect(result.isFailure, isTrue);
    });
  });
}

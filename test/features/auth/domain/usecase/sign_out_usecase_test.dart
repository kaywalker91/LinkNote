import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/domain/repository/i_auth_repository.dart';
import 'package:linknote/features/auth/domain/usecase/sign_out_usecase.dart';
import 'package:linknote/features/collection/data/datasource/collection_local_datasource.dart';
import 'package:linknote/features/link/data/datasource/link_local_datasource.dart';
import 'package:linknote/features/notification/data/datasource/notification_local_datasource.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockLinkLocalDataSource extends Mock implements LinkLocalDataSource {}

class MockCollectionLocalDataSource extends Mock
    implements CollectionLocalDataSource {}

class MockNotificationLocalDataSource extends Mock
    implements NotificationLocalDataSource {}

void main() {
  late SignOutUsecase sut;
  late MockAuthRepository mockRepository;
  late MockLinkLocalDataSource mockLinkLocalDs;
  late MockCollectionLocalDataSource mockCollectionLocalDs;
  late MockNotificationLocalDataSource mockNotificationLocalDs;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockLinkLocalDs = MockLinkLocalDataSource();
    mockCollectionLocalDs = MockCollectionLocalDataSource();
    mockNotificationLocalDs = MockNotificationLocalDataSource();
    sut = SignOutUsecase(
      mockRepository,
      mockLinkLocalDs,
      mockCollectionLocalDs,
      mockNotificationLocalDs,
    );
  });

  group('SignOutUsecase', () {
    test('should return success when sign out succeeds', () async {
      // Arrange
      when(
        () => mockRepository.signOut(),
      ).thenAnswer((_) async => success(null));
      when(() => mockLinkLocalDs.clearAll()).thenAnswer((_) async {});
      when(() => mockCollectionLocalDs.clearAll()).thenAnswer((_) async {});
      when(() => mockNotificationLocalDs.clearAll()).thenAnswer((_) async {});

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.signOut()).called(1);
    });

    test(
      'should call clearAll on all local data sources when sign out succeeds',
      () async {
        // Arrange
        when(
          () => mockRepository.signOut(),
        ).thenAnswer((_) async => success(null));
        when(() => mockLinkLocalDs.clearAll()).thenAnswer((_) async {});
        when(() => mockCollectionLocalDs.clearAll()).thenAnswer((_) async {});
        when(() => mockNotificationLocalDs.clearAll()).thenAnswer((_) async {});

        // Act
        await sut.call();

        // Assert
        verify(() => mockLinkLocalDs.clearAll()).called(1);
        verify(() => mockCollectionLocalDs.clearAll()).called(1);
        verify(() => mockNotificationLocalDs.clearAll()).called(1);
      },
    );

    test('should NOT call clearAll when sign out fails', () async {
      // Arrange
      const tFailure = Failure.auth(message: 'Sign out failed');
      when(
        () => mockRepository.signOut(),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(() => mockRepository.signOut()).called(1);
      verifyNever(() => mockLinkLocalDs.clearAll());
      verifyNever(() => mockCollectionLocalDs.clearAll());
      verifyNever(() => mockNotificationLocalDs.clearAll());
    });
  });
}

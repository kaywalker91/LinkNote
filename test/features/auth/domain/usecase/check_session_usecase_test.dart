import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/domain/repository/i_auth_repository.dart';
import 'package:linknote/features/auth/domain/usecase/check_session_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late CheckSessionUsecase sut;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    sut = CheckSessionUsecase(mockRepository);
  });

  group('CheckSessionUsecase', () {
    test('should return Authenticated when session exists', () async {
      // Arrange
      const tAuthState = AuthStateEntity.authenticated(
        userId: 'user-id',
        email: 'test@example.com',
      );
      when(
        () => mockRepository.getSession(),
      ).thenAnswer((_) async => tAuthState);

      // Act
      final result = await sut.call();

      // Assert
      expect(result, isA<Authenticated>());
      expect((result as Authenticated).userId, equals('user-id'));
      verify(() => mockRepository.getSession()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Unauthenticated when no session exists', () async {
      // Arrange
      when(
        () => mockRepository.getSession(),
      ).thenAnswer((_) async => const AuthStateEntity.unauthenticated());

      // Act
      final result = await sut.call();

      // Assert
      expect(result, isA<Unauthenticated>());
      verify(() => mockRepository.getSession()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate exception when repository throws', () async {
      // Arrange
      when(
        () => mockRepository.getSession(),
      ).thenThrow(Exception('Session error'));

      // Act & Assert
      expect(() => sut.call(), throwsA(isA<Exception>()));
      verify(() => mockRepository.getSession()).called(1);
    });
  });
}

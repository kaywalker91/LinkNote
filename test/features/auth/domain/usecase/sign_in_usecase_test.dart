import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/domain/repository/i_auth_repository.dart';
import 'package:linknote/features/auth/domain/usecase/sign_in_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late SignInUsecase sut;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    sut = SignInUsecase(mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tAuthState = AuthStateEntity.authenticated(
    userId: 'user-id',
    email: tEmail,
  );

  group('SignInUsecase', () {
    test('should return AuthStateEntity when sign in succeeds', () async {
      // Arrange
      when(
        () => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => success(tAuthState));

      // Act
      final result = await sut.call(email: tEmail, password: tPassword);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tAuthState));
      verify(
        () => mockRepository.signIn(email: tEmail, password: tPassword),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when sign in fails', () async {
      // Arrange
      const tFailure = Failure.auth(message: 'Invalid credentials');
      when(
        () => mockRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call(email: tEmail, password: tPassword);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(
        () => mockRepository.signIn(email: tEmail, password: tPassword),
      ).called(1);
    });
  });
}

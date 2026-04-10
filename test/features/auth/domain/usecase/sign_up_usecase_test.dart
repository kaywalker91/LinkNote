import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/domain/repository/i_auth_repository.dart';
import 'package:linknote/features/auth/domain/usecase/sign_up_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late SignUpUsecase sut;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    sut = SignUpUsecase(mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tAuthState = AuthStateEntity.authenticated(
    userId: 'user-id',
    email: tEmail,
  );

  group('SignUpUsecase', () {
    test('should return AuthStateEntity when sign up succeeds', () async {
      // Arrange
      when(
        () => mockRepository.signUp(
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
        () => mockRepository.signUp(email: tEmail, password: tPassword),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when sign up fails', () async {
      // Arrange
      const tFailure = Failure.auth(message: 'Email already exists');
      when(
        () => mockRepository.signUp(
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
        () => mockRepository.signUp(email: tEmail, password: tPassword),
      ).called(1);
    });
  });
}

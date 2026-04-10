import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/domain/repository/i_auth_repository.dart';
import 'package:linknote/features/auth/domain/usecase/sign_out_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late SignOutUsecase sut;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    sut = SignOutUsecase(mockRepository);
  });

  group('SignOutUsecase', () {
    test('should return success when sign out succeeds', () async {
      // Arrange
      when(
        () => mockRepository.signOut(),
      ).thenAnswer((_) async => success(null));

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when sign out fails', () async {
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
    });
  });
}

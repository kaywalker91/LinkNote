import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/storage/i_clearable_cache.dart';
import 'package:linknote/features/auth/domain/repository/i_auth_repository.dart';
import 'package:linknote/features/auth/domain/usecase/sign_out_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockClearableCache extends Mock implements IClearableCache {}

void main() {
  late SignOutUsecase sut;
  late MockAuthRepository mockRepository;
  late MockClearableCache mockCache1;
  late MockClearableCache mockCache2;
  late MockClearableCache mockCache3;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockCache1 = MockClearableCache();
    mockCache2 = MockClearableCache();
    mockCache3 = MockClearableCache();
    sut = SignOutUsecase(
      mockRepository,
      [mockCache1, mockCache2, mockCache3],
    );
  });

  group('SignOutUsecase', () {
    test('should return success when sign out succeeds', () async {
      // Arrange
      when(
        () => mockRepository.signOut(),
      ).thenAnswer((_) async => success(null));
      when(() => mockCache1.clearAll()).thenAnswer((_) async {});
      when(() => mockCache2.clearAll()).thenAnswer((_) async {});
      when(() => mockCache3.clearAll()).thenAnswer((_) async {});

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.signOut()).called(1);
    });

    test(
      'should call clearAll on all caches when sign out succeeds',
      () async {
        // Arrange
        when(
          () => mockRepository.signOut(),
        ).thenAnswer((_) async => success(null));
        when(() => mockCache1.clearAll()).thenAnswer((_) async {});
        when(() => mockCache2.clearAll()).thenAnswer((_) async {});
        when(() => mockCache3.clearAll()).thenAnswer((_) async {});

        // Act
        await sut.call();

        // Assert
        verify(() => mockCache1.clearAll()).called(1);
        verify(() => mockCache2.clearAll()).called(1);
        verify(() => mockCache3.clearAll()).called(1);
      },
    );

    test(
      'should ALWAYS call clearAll even when server sign out fails '
      '(401 path safety)',
      () async {
        // Arrange — 401 경로에서 서버 signOut 실패 시나리오.
        const tFailure = Failure.auth(message: 'Sign out failed');
        when(
          () => mockRepository.signOut(),
        ).thenAnswer((_) async => error(tFailure));
        when(() => mockCache1.clearAll()).thenAnswer((_) async {});
        when(() => mockCache2.clearAll()).thenAnswer((_) async {});
        when(() => mockCache3.clearAll()).thenAnswer((_) async {});

        // Act
        final result = await sut.call();

        // Assert — 서버 실패가 surface되지만 로컬은 항상 비워진다.
        expect(result.isFailure, isTrue);
        expect(result.failure, equals(tFailure));
        verify(() => mockRepository.signOut()).called(1);
        verify(() => mockCache1.clearAll()).called(1);
        verify(() => mockCache2.clearAll()).called(1);
        verify(() => mockCache3.clearAll()).called(1);
      },
    );
  });
}

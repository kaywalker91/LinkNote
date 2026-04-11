import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:linknote/features/auth/data/repository/auth_repository_impl.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

void main() {
  late AuthRepositoryImpl sut;
  late MockAuthRemoteDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockAuthRemoteDatasource();
    sut = AuthRepositoryImpl(mockDatasource);
  });

  const tAuthState = AuthStateEntity.authenticated(
    userId: 'user-1',
    email: 'test@example.com',
  );

  // ---------------------------------------------------------------------------
  // getSession
  // ---------------------------------------------------------------------------
  group('getSession', () {
    test('should delegate to datasource', () async {
      // Arrange
      when(
        () => mockDatasource.getSession(),
      ).thenAnswer((_) async => tAuthState);

      // Act
      final result = await sut.getSession();

      // Assert
      expect(result, equals(tAuthState));
      verify(() => mockDatasource.getSession()).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // signIn
  // ---------------------------------------------------------------------------
  group('signIn', () {
    test('should return success on successful sign in', () async {
      // Arrange
      when(
        () => mockDatasource.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => success(tAuthState));

      // Act
      final result = await sut.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tAuthState));
    });

    test('should return failure on failed sign in', () async {
      // Arrange
      const tFailure = Failure.auth(message: 'Invalid credentials');
      when(
        () => mockDatasource.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.signIn(
        email: 'test@example.com',
        password: 'wrong',
      );

      // Assert
      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // signUp
  // ---------------------------------------------------------------------------
  group('signUp', () {
    test('should return success on successful sign up', () async {
      // Arrange
      when(
        () => mockDatasource.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => success(tAuthState));

      // Act
      final result = await sut.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tAuthState));
    });

    test('should return failure on failed sign up', () async {
      // Arrange
      const tFailure = Failure.auth(message: 'Email already exists');
      when(
        () => mockDatasource.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.isFailure, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // signOut
  // ---------------------------------------------------------------------------
  group('signOut', () {
    test('should return success on successful sign out', () async {
      // Arrange
      when(
        () => mockDatasource.signOut(),
      ).thenAnswer((_) async => success(null));

      // Act
      final result = await sut.signOut();

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should return failure on failed sign out', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Sign out failed');
      when(
        () => mockDatasource.signOut(),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.signOut();

      // Assert
      expect(result.isFailure, isTrue);
    });
  });
}

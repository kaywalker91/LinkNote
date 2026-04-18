import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockUser extends Mock implements User {}

class MockSession extends Mock implements Session {}

void main() {
  late AuthRemoteDatasource sut;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    sut = AuthRemoteDatasource(mockClient);
  });

  // ---------------------------------------------------------------------------
  // signUp
  // ---------------------------------------------------------------------------
  group('signUp', () {
    test(
      'should return authenticated state when signUp returns user and session',
      () async {
        // Arrange
        final mockUser = MockUser();
        final mockSession = MockSession();
        final mockResponse = MockAuthResponse();
        when(() => mockUser.id).thenReturn('user-1');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockResponse.user).thenReturn(mockUser);
        when(() => mockResponse.session).thenReturn(mockSession);
        when(
          () => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await sut.signUp(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(
          result.data,
          equals(
            const AuthStateEntity.authenticated(
              userId: 'user-1',
              email: 'test@example.com',
            ),
          ),
        );
      },
    );

    test(
      'should return Failure.auth with confirmation message when signUp '
      'returns user but session is null',
      () async {
        // Arrange — Email Confirmation ON 시나리오
        final mockUser = MockUser();
        final mockResponse = MockAuthResponse();
        when(() => mockUser.id).thenReturn('user-1');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockResponse.user).thenReturn(mockUser);
        when(() => mockResponse.session).thenReturn(null);
        when(
          () => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await sut.signUp(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<AuthFailure>());
        final failure = result.failure! as AuthFailure;
        expect(failure.message, isNotNull);
        expect(failure.message, contains('verification email'));
      },
    );

    test('should return Failure.auth when signUp returns user=null', () async {
      // Arrange
      final mockResponse = MockAuthResponse();
      when(() => mockResponse.user).thenReturn(null);
      when(() => mockResponse.session).thenReturn(null);
      when(
        () => mockAuth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await sut.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<AuthFailure>());
    });

    test(
      'should return Failure.auth when AuthException thrown during signUp',
      () async {
        // Arrange
        when(
          () => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const AuthException('User already registered'));

        // Act
        final result = await sut.signUp(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<AuthFailure>());
        expect(
          (result.failure! as AuthFailure).message,
          equals('User already registered'),
        );
      },
    );
  });

  // ---------------------------------------------------------------------------
  // signIn
  // ---------------------------------------------------------------------------
  group('signIn', () {
    test(
      'should return authenticated state when signIn returns user',
      () async {
        // Arrange
        final mockUser = MockUser();
        final mockResponse = MockAuthResponse();
        when(() => mockUser.id).thenReturn('user-1');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockResponse.user).thenReturn(mockUser);
        when(
          () => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await sut.signIn(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(
          result.data,
          equals(
            const AuthStateEntity.authenticated(
              userId: 'user-1',
              email: 'test@example.com',
            ),
          ),
        );
      },
    );

    test('should return Failure.auth when signIn returns user=null', () async {
      // Arrange
      final mockResponse = MockAuthResponse();
      when(() => mockResponse.user).thenReturn(null);
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await sut.signIn(
        email: 'test@example.com',
        password: 'wrong',
      );

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<AuthFailure>());
    });
  });
}

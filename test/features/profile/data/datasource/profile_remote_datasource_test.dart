import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/profile/data/datasource/profile_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late ProfileRemoteDataSource sut;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    sut = ProfileRemoteDataSource(mockClient);
  });

  group('getProfile', () {
    test('should return Failure.auth when currentUser is null', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      final result = await sut.getProfile();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<AuthFailure>());
    });
  });

  group('updateProfile', () {
    test('should return Failure.auth when currentUser is null', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act
      final result = await sut.updateProfile(displayName: 'Test');

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<AuthFailure>());
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/data/datasource/link_remote_datasource.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late LinkRemoteDataSource sut;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    sut = LinkRemoteDataSource(mockClient);
  });

  group('updateLink', () {
    test('should return Failure.auth when currentUser is null', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);
      final link = LinkEntity(
        id: 'link-1',
        url: 'https://example.com',
        title: 'Test',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        tags: <TagEntity>[],
      );

      // Act
      final result = await sut.updateLink(link);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<AuthFailure>());
    });
  });
}

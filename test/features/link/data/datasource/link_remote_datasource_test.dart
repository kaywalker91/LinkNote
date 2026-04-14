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

  final tLink = LinkEntity(
    id: 'link-1',
    url: 'https://example.com',
    title: 'Test',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    tags: const <TagEntity>[],
  );

  group('updateLink', () {
    test('should return Failure.auth when currentUser is null', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await sut.updateLink(tLink);

      expect(result.failure, isNotNull);
      expect(result.failure, isA<AuthFailure>());
    });

    test('should include session expired message', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await sut.updateLink(tLink);

      final failure = result.failure! as AuthFailure;
      expect(failure.message, 'Session expired');
    });
  });

  group('deleteLink', () {
    test('should return Failure.server on PostgrestException', () async {
      when(() => mockClient.from('links')).thenThrow(
        const PostgrestException(message: 'Row not found', code: '404'),
      );

      final result = await sut.deleteLink('link-1');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ServerFailure>());
      expect(result.failure?.message, 'Row not found');
    });

    test('should return Failure.unknown on generic exception', () async {
      when(() => mockClient.from('links'))
          .thenThrow(Exception('Network error'));

      final result = await sut.deleteLink('link-1');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<UnknownFailure>());
    });
  });

  group('toggleFavorite', () {
    test('should return Failure.server on PostgrestException', () async {
      when(() => mockClient.from('links')).thenThrow(
        const PostgrestException(message: 'Update failed', code: '500'),
      );

      final result =
          await sut.toggleFavorite('link-1', isFavorite: true);

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ServerFailure>());
      expect(result.failure?.message, 'Update failed');
    });

    test('should return Failure.unknown on generic exception', () async {
      when(() => mockClient.from('links'))
          .thenThrow(Exception('Timeout'));

      final result =
          await sut.toggleFavorite('link-1', isFavorite: true);

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<UnknownFailure>());
    });
  });
}

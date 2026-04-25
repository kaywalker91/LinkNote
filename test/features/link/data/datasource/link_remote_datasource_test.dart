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
      when(
        () => mockClient.from('links'),
      ).thenThrow(Exception('Network error'));

      final result = await sut.deleteLink('link-1');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<UnknownFailure>());
    });

    test(
      'should return Failure.unknown on Error (Exception is not Error)',
      () async {
        // Dart `Error` subtypes (e.g. `_TypeError` from JSON cast failures)
        // are not caught by `on Exception`, so the catch block must use
        // `on Object` to avoid leaking raw Errors to AsyncValue.error.
        when(() => mockClient.from('links')).thenThrow(ArgumentError('bad'));

        final result = await sut.deleteLink('link-1');

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<UnknownFailure>());
      },
    );
  });

  group('toggleFavorite', () {
    test('should return Failure.server on PostgrestException', () async {
      when(() => mockClient.from('links')).thenThrow(
        const PostgrestException(message: 'Update failed', code: '500'),
      );

      final result = await sut.toggleFavorite('link-1', isFavorite: true);

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ServerFailure>());
      expect(result.failure?.message, 'Update failed');
    });

    test('should return Failure.unknown on generic exception', () async {
      when(() => mockClient.from('links')).thenThrow(Exception('Timeout'));

      final result = await sut.toggleFavorite('link-1', isFavorite: true);

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<UnknownFailure>());
    });
  });

  group('parseRows', () {
    Map<String, dynamic> validRow({
      required String id,
      List<Map<String, dynamic>>? linkTags,
    }) => <String, dynamic>{
      'id': id,
      'user_id': 'u-1',
      'url': 'https://example.com/$id',
      'title': 'Title $id',
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
      'link_tags': ?linkTags,
    };

    test('returns all rows when every row parses cleanly', () {
      final rows = [
        validRow(id: 'a'),
        validRow(
          id: 'b',
          linkTags: [
            {
              'tags': {'id': 't-1', 'name': 'flutter', 'color': '#2196F3'},
            },
          ],
        ),
      ];

      final entities = LinkRemoteDataSource.parseRows(rows);

      expect(entities.map((e) => e.id), ['a', 'b']);
      expect(entities[1].tags.single, isA<TagEntity>());
    });

    test('skips rows that fail to parse and reports each via onError', () {
      final errors = <Object>[];
      final rows = [
        validRow(id: 'good-1'),
        // Row with malformed nested tag (missing required `color` field).
        validRow(
          id: 'bad-1',
          linkTags: [
            {
              'tags': {'id': 't-1', 'name': 'flutter'},
            },
          ],
        ),
        validRow(id: 'good-2'),
      ];

      final entities = LinkRemoteDataSource.parseRows(
        rows,
        onError: (error, _) => errors.add(error),
      );

      expect(entities.map((e) => e.id), ['good-1', 'good-2']);
      expect(errors.length, 1);
    });

    test('returns empty list and zero errors when input is empty', () {
      final entities = LinkRemoteDataSource.parseRows(const []);
      expect(entities, isEmpty);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/data/datasource/collection_remote_datasource.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late CollectionRemoteDataSource sut;
  late MockSupabaseClient mockClient;

  setUp(() {
    mockClient = MockSupabaseClient();
    sut = CollectionRemoteDataSource(mockClient);
  });

  final tCollection = CollectionEntity(
    id: 'col-1',
    name: 'Test',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  group('getCollections', () {
    test('should return Failure.server on PostgrestException', () async {
      when(() => mockClient.from('collections')).thenThrow(
        const PostgrestException(message: 'RLS denied', code: '401'),
      );

      final result = await sut.getCollections();

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ServerFailure>());
      expect(result.failure?.message, 'RLS denied');
    });

    test('should return Failure.unknown on generic exception', () async {
      when(
        () => mockClient.from('collections'),
      ).thenThrow(Exception('Network error'));

      final result = await sut.getCollections();

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<UnknownFailure>());
    });
  });

  group('getCollectionById', () {
    test('should return Failure.server on PostgrestException', () async {
      when(() => mockClient.from('collections')).thenThrow(
        const PostgrestException(message: 'Row not found', code: '404'),
      );

      final result = await sut.getCollectionById('col-1', 'user-1');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ServerFailure>());
      expect(result.failure?.message, 'Row not found');
    });

    test('should return Failure.unknown on generic exception', () async {
      when(
        () => mockClient.from('collections'),
      ).thenThrow(Exception('Timeout'));

      final result = await sut.getCollectionById('col-1', 'user-1');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<UnknownFailure>());
    });
  });

  group('createCollection', () {
    test('should return Failure.server on PostgrestException', () async {
      when(() => mockClient.from('collections')).thenThrow(
        const PostgrestException(message: 'Insert failed', code: '500'),
      );

      final result = await sut.createCollection(tCollection, 'user-1');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ServerFailure>());
      expect(result.failure?.message, 'Insert failed');
    });

    test('should return Failure.unknown on generic exception', () async {
      when(() => mockClient.from('collections')).thenThrow(Exception('IO'));

      final result = await sut.createCollection(tCollection, 'user-1');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<UnknownFailure>());
    });
  });

  group('updateCollection', () {
    test('should return Failure.server on PostgrestException', () async {
      when(() => mockClient.from('collections')).thenThrow(
        const PostgrestException(message: 'Update denied', code: '403'),
      );

      final result = await sut.updateCollection(tCollection, 'user-1');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ServerFailure>());
      expect(result.failure?.message, 'Update denied');
    });

    test('should return Failure.unknown on generic exception', () async {
      when(
        () => mockClient.from('collections'),
      ).thenThrow(Exception('Timeout'));

      final result = await sut.updateCollection(tCollection, 'user-1');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<UnknownFailure>());
    });
  });

  group('deleteCollection', () {
    test('should return Failure.server on PostgrestException', () async {
      when(() => mockClient.from('collections')).thenThrow(
        const PostgrestException(message: 'Delete denied', code: '403'),
      );

      final result = await sut.deleteCollection('col-1', 'user-1');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ServerFailure>());
      expect(result.failure?.message, 'Delete denied');
    });

    test('should return Failure.unknown on generic exception', () async {
      when(
        () => mockClient.from('collections'),
      ).thenThrow(Exception('Network'));

      final result = await sut.deleteCollection('col-1', 'user-1');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<UnknownFailure>());
    });
  });
}

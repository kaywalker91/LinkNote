import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/data/dto/collection_dto.dart';
import 'package:linknote/features/collection/data/mapper/collection_mapper.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectionRemoteDataSource {
  const CollectionRemoteDataSource(this._client);
  final SupabaseClient _client;

  static const _selectQuery = '*, links(count)';

  Future<Result<PaginatedState<CollectionEntity>>> getCollections({
    String? cursor,
    int pageSize = 20,
  }) async {
    try {
      var query = _client.from('collections').select(_selectQuery);

      if (cursor != null) {
        query = query.lt('created_at', cursor);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(pageSize + 1);

      final hasMore = response.length > pageSize;
      final rawItems = hasMore ? response.sublist(0, pageSize) : response;
      final items = rawItems
          .map(
            (json) => CollectionMapper.toEntity(CollectionDto.fromJson(json)),
          )
          .toList();

      return success(
        PaginatedState<CollectionEntity>(
          items: items,
          hasMore: hasMore,
          nextCursor: items.isNotEmpty
              ? items.last.createdAt.toUtc().toIso8601String()
              : null,
        ),
      );
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }

  Future<Result<CollectionEntity>> getCollectionById(
    String id,
    String userId,
  ) async {
    try {
      final response = await _client
          .from('collections')
          .select(_selectQuery)
          .eq('id', id)
          .eq('user_id', userId)
          .single();

      return success(
        CollectionMapper.toEntity(CollectionDto.fromJson(response)),
      );
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }

  Future<Result<CollectionEntity>> createCollection(
    CollectionEntity collection,
    String userId,
  ) async {
    try {
      final json = CollectionMapper.toInsertJson(collection, userId);
      final response = await _client
          .from('collections')
          .insert(json)
          .select(_selectQuery)
          .single();

      return success(
        CollectionMapper.toEntity(CollectionDto.fromJson(response)),
      );
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }

  Future<Result<CollectionEntity>> updateCollection(
    CollectionEntity collection,
    String userId,
  ) async {
    try {
      final json = CollectionMapper.toUpdateJson(collection);
      final response = await _client
          .from('collections')
          .update(json)
          .eq('id', collection.id)
          .eq('user_id', userId)
          .select(_selectQuery)
          .single();

      return success(
        CollectionMapper.toEntity(CollectionDto.fromJson(response)),
      );
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }

  Future<Result<void>> deleteCollection(String id, String userId) async {
    try {
      await _client
          .from('collections')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
      return success(null);
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }
}

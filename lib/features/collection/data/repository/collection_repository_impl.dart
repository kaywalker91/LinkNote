import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/data/datasource/collection_local_datasource.dart';
import 'package:linknote/features/collection/data/datasource/collection_remote_datasource.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class CollectionRepositoryImpl implements ICollectionRepository {
  const CollectionRepositoryImpl(
    this._remote,
    this._local, {
    required this.userId,
  });

  final CollectionRemoteDataSource _remote;
  final CollectionLocalDataSource _local;
  final String userId;

  @override
  Future<Result<PaginatedState<CollectionEntity>>> getCollections({
    String? cursor,
    int pageSize = 20,
  }) async {
    final remote = await _remote.getCollections(
      cursor: cursor,
      pageSize: pageSize,
    );
    if (remote.isSuccess) {
      if (cursor == null) {
        await _local.cacheCollections(remote.data!.items);
      }
      return remote;
    }
    if (cursor == null) {
      return _local.getCachedCollections();
    }
    return remote;
  }

  @override
  Future<Result<CollectionEntity>> getCollectionById(String id) async {
    final remote = await _remote.getCollectionById(id, userId);
    if (remote.isSuccess) {
      await _local.cacheSingleCollection(remote.data!);
      return remote;
    }
    final cached = _local.getCachedCollectionById(id);
    if (cached.isSuccess) {
      return cached;
    }
    return remote;
  }

  @override
  Future<Result<CollectionEntity>> createCollection(
    CollectionEntity collection,
  ) async {
    final result = await _remote.createCollection(collection, userId);
    if (result.isSuccess) {
      await _local.cacheSingleCollection(result.data!);
    }
    return result;
  }

  @override
  Future<Result<CollectionEntity>> updateCollection(
    CollectionEntity collection,
  ) async {
    final result = await _remote.updateCollection(collection, userId);
    if (result.isSuccess) {
      await _local.cacheSingleCollection(result.data!);
    }
    return result;
  }

  @override
  Future<Result<void>> deleteCollection(String id) async {
    final result = await _remote.deleteCollection(id, userId);
    if (result.isSuccess) {
      await _local.removeCachedCollection(id);
    }
    return result;
  }
}

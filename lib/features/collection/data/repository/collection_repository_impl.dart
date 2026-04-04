import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/data/datasource/collection_remote_datasource.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class CollectionRepositoryImpl implements ICollectionRepository {
  const CollectionRepositoryImpl(this._dataSource, {required this.userId});

  final CollectionRemoteDataSource _dataSource;
  final String userId;

  @override
  Future<Result<PaginatedState<CollectionEntity>>> getCollections({
    String? cursor,
    int pageSize = 20,
  }) => _dataSource.getCollections(cursor: cursor, pageSize: pageSize);

  @override
  Future<Result<CollectionEntity>> getCollectionById(String id) =>
      _dataSource.getCollectionById(id);

  @override
  Future<Result<CollectionEntity>> createCollection(
    CollectionEntity collection,
  ) => _dataSource.createCollection(collection, userId);

  @override
  Future<Result<CollectionEntity>> updateCollection(
    CollectionEntity collection,
  ) => _dataSource.updateCollection(collection);

  @override
  Future<Result<void>> deleteCollection(String id) =>
      _dataSource.deleteCollection(id);
}

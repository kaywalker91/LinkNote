import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class GetCollectionsUsecase {
  const GetCollectionsUsecase(this._repository);
  final ICollectionRepository _repository;

  Future<Result<PaginatedState<CollectionEntity>>> call({
    String? cursor,
    int pageSize = 20,
  }) =>
      _repository.getCollections(cursor: cursor, pageSize: pageSize);
}

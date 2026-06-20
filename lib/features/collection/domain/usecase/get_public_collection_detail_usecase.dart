import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';

/// Loads a `public` collection for the read-only share view (owner-agnostic).
class GetPublicCollectionDetailUsecase {
  const GetPublicCollectionDetailUsecase(this._repository);
  final ICollectionRepository _repository;

  Future<Result<CollectionEntity>> call(String id) =>
      _repository.getPublicCollectionById(id);
}

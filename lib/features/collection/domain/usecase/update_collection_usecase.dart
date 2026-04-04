import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';

class UpdateCollectionUsecase {
  const UpdateCollectionUsecase(this._repository);
  final ICollectionRepository _repository;

  Future<Result<CollectionEntity>> call(CollectionEntity collection) =>
      _repository.updateCollection(collection);
}

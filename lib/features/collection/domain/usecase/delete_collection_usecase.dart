import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';

class DeleteCollectionUsecase {
  const DeleteCollectionUsecase(this._repository);
  final ICollectionRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteCollection(id);
}

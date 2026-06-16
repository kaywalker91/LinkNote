import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';

/// Toggles a collection's visibility/lock state without touching name or
/// description. See [ICollectionRepository.updateCollectionVisibility].
class UpdateCollectionVisibilityUsecase {
  const UpdateCollectionVisibilityUsecase(this._repository);
  final ICollectionRepository _repository;

  Future<Result<CollectionEntity>> call({
    required String id,
    required CollectionVisibility visibility,
    required DateTime? lockedAt,
  }) => _repository.updateCollectionVisibility(
    id: id,
    visibility: visibility,
    lockedAt: lockedAt,
  );
}

import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/shared/models/paginated_state.dart';

abstract interface class ICollectionRepository {
  Future<Result<PaginatedState<CollectionEntity>>> getCollections({
    String? cursor,
    int pageSize = 20,
  });
  Future<Result<CollectionEntity>> getCollectionById(String id);
  Future<Result<CollectionEntity>> createCollection(
    CollectionEntity collection,
  );
  Future<Result<CollectionEntity>> updateCollection(
    CollectionEntity collection,
  );

  /// Persists only the visibility/lock state, leaving name/description intact.
  Future<Result<CollectionEntity>> updateCollectionVisibility({
    required String id,
    required CollectionVisibility visibility,
    required DateTime? lockedAt,
  });

  Future<Result<void>> deleteCollection(String id);
}

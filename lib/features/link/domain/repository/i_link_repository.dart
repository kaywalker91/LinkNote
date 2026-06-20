import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/shared/models/paginated_state.dart';

abstract interface class ILinkRepository {
  Future<Result<PaginatedState<LinkEntity>>> getLinks({
    String? cursor,
    int pageSize = 20,
    bool favoritesOnly = false,
    String? collectionId,
  });
  Future<Result<LinkEntity>> getLinkById(String id);

  /// Reads the links of a `public` collection regardless of owner (read-only
  /// share view). Relies on the public-collection RLS policy for access.
  Future<Result<PaginatedState<LinkEntity>>> getPublicLinksByCollectionId(
    String collectionId, {
    String? cursor,
    int pageSize = 20,
  });
  Future<Result<LinkEntity>> createLink(LinkEntity link);
  Future<Result<LinkEntity>> updateLink(LinkEntity link);
  Future<Result<void>> deleteLink(String id);
  Future<Result<LinkEntity>> toggleFavorite(
    String id, {
    required bool isFavorite,
  });
}

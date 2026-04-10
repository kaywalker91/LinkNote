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
  Future<Result<LinkEntity>> createLink(LinkEntity link);
  Future<Result<LinkEntity>> updateLink(LinkEntity link);
  Future<Result<void>> deleteLink(String id);
  Future<Result<LinkEntity>> toggleFavorite(
    String id, {
    required bool isFavorite,
  });
}

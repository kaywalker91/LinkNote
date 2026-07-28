import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/link_sort_order.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class FetchLinksUsecase {
  const FetchLinksUsecase(this._repository);
  final ILinkRepository _repository;

  Future<Result<PaginatedState<LinkEntity>>> call({
    String? cursor,
    int pageSize = 20,
    bool favoritesOnly = false,
    String? collectionId,
    LinkSortOrder sortOrder = LinkSortOrder.newest,
  }) => _repository.getLinks(
    cursor: cursor,
    pageSize: pageSize,
    favoritesOnly: favoritesOnly,
    collectionId: collectionId,
    sortOrder: sortOrder,
  );
}

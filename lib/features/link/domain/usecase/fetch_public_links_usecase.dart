import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';
import 'package:linknote/shared/models/paginated_state.dart';

/// Loads the links of a `public` collection for the read-only share view
/// (owner-agnostic).
class FetchPublicLinksUsecase {
  const FetchPublicLinksUsecase(this._repository);
  final ILinkRepository _repository;

  Future<Result<PaginatedState<LinkEntity>>> call(String collectionId) =>
      _repository.getPublicLinksByCollectionId(collectionId);
}

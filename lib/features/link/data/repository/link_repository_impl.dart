import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/data/datasource/link_remote_datasource.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class LinkRepositoryImpl implements ILinkRepository {
  const LinkRepositoryImpl(this._dataSource, {required this.userId});

  final LinkRemoteDataSource _dataSource;
  final String userId;

  @override
  Future<Result<PaginatedState<LinkEntity>>> getLinks({
    String? cursor,
    int pageSize = 20,
    bool favoritesOnly = false,
  }) => _dataSource.getLinks(
    cursor: cursor,
    pageSize: pageSize,
    favoritesOnly: favoritesOnly,
  );

  @override
  Future<Result<LinkEntity>> getLinkById(String id) =>
      _dataSource.getLinkById(id);

  @override
  Future<Result<LinkEntity>> createLink(LinkEntity link) =>
      _dataSource.createLink(link, userId);

  @override
  Future<Result<LinkEntity>> updateLink(LinkEntity link) =>
      _dataSource.updateLink(link);

  @override
  Future<Result<void>> deleteLink(String id) => _dataSource.deleteLink(id);

  @override
  Future<Result<LinkEntity>> toggleFavorite(
    String id, {
    required bool isFavorite,
  }) => _dataSource.toggleFavorite(id, isFavorite: isFavorite);
}

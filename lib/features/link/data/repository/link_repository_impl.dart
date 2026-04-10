import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/data/datasource/link_local_datasource.dart';
import 'package:linknote/features/link/data/datasource/link_remote_datasource.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class LinkRepositoryImpl implements ILinkRepository {
  const LinkRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource, {
    required this.userId,
  });

  final LinkRemoteDataSource _remoteDataSource;
  final LinkLocalDataSource _localDataSource;
  final String userId;

  @override
  Future<Result<PaginatedState<LinkEntity>>> getLinks({
    String? cursor,
    int pageSize = 20,
    bool favoritesOnly = false,
    String? collectionId,
  }) async {
    final remote = await _remoteDataSource.getLinks(
      cursor: cursor,
      pageSize: pageSize,
      favoritesOnly: favoritesOnly,
      collectionId: collectionId,
    );

    if (remote.isSuccess) {
      // Cache the first page only (no cursor = initial fetch)
      if (cursor == null) {
        await _localDataSource.cacheLinks(remote.data!.items);
      } else {
        // Append subsequent pages to cache
        await _localDataSource.cacheLinks(remote.data!.items);
      }
      return remote;
    }

    // Remote failed — try local fallback (only for initial fetch)
    if (cursor == null) {
      return _localDataSource.getCachedLinks(
        favoritesOnly: favoritesOnly,
        collectionId: collectionId,
      );
    }

    return remote;
  }

  @override
  Future<Result<LinkEntity>> getLinkById(String id) async {
    final remote = await _remoteDataSource.getLinkById(id);

    if (remote.isSuccess) {
      await _localDataSource.cacheSingleLink(remote.data!);
      return remote;
    }

    // Fallback to cache
    return _localDataSource.getCachedLinkById(id);
  }

  @override
  Future<Result<LinkEntity>> createLink(LinkEntity link) async {
    final remote = await _remoteDataSource.createLink(link, userId);

    if (remote.isSuccess) {
      await _localDataSource.cacheSingleLink(remote.data!);
    }

    return remote;
  }

  @override
  Future<Result<LinkEntity>> updateLink(LinkEntity link) async {
    final remote = await _remoteDataSource.updateLink(link);

    if (remote.isSuccess) {
      await _localDataSource.cacheSingleLink(remote.data!);
    }

    return remote;
  }

  @override
  Future<Result<void>> deleteLink(String id) async {
    final remote = await _remoteDataSource.deleteLink(id);

    if (remote.isSuccess) {
      await _localDataSource.removeCachedLink(id);
    }

    return remote;
  }

  @override
  Future<Result<LinkEntity>> toggleFavorite(
    String id, {
    required bool isFavorite,
  }) async {
    final remote = await _remoteDataSource.toggleFavorite(
      id,
      isFavorite: isFavorite,
    );

    if (remote.isSuccess) {
      await _localDataSource.updateCachedFavorite(id, isFavorite: isFavorite);
    }

    return remote;
  }
}

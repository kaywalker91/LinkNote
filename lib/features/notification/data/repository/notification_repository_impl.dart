import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/notification/data/datasource/notification_local_datasource.dart';
import 'package:linknote/features/notification/data/datasource/notification_remote_datasource.dart';
import 'package:linknote/features/notification/domain/entity/notification_entity.dart';
import 'package:linknote/features/notification/domain/repository/i_notification_repository.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  const NotificationRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  final NotificationRemoteDataSource _remoteDataSource;
  final NotificationLocalDataSource _localDataSource;

  @override
  Future<Result<PaginatedState<NotificationEntity>>> getNotifications({
    String? cursor,
    int pageSize = 20,
  }) async {
    final remote = await _remoteDataSource.getNotifications(
      cursor: cursor,
      pageSize: pageSize,
    );

    if (remote.isSuccess) {
      await _localDataSource.cacheNotifications(remote.data!.items);
      return remote;
    }

    // Remote failed — try local fallback (only for initial fetch)
    if (cursor == null) {
      return _localDataSource.getCachedNotifications();
    }

    return remote;
  }

  @override
  Future<Result<void>> markAsRead(String id) async {
    final remote = await _remoteDataSource.markAsRead(id);

    if (remote.isSuccess) {
      await _localDataSource.updateCachedReadStatus(id, isRead: true);
    }

    return remote;
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    final remote = await _remoteDataSource.markAllAsRead();

    if (remote.isSuccess) {
      await _localDataSource.markAllCachedAsRead();
    }

    return remote;
  }
}

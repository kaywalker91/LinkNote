import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/notification/domain/entity/notification_entity.dart';
import 'package:linknote/features/notification/domain/repository/i_notification_repository.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class FetchNotificationsUsecase {
  const FetchNotificationsUsecase(this._repository);
  final INotificationRepository _repository;

  Future<Result<PaginatedState<NotificationEntity>>> call({
    String? cursor,
    int pageSize = 20,
  }) => _repository.getNotifications(cursor: cursor, pageSize: pageSize);
}

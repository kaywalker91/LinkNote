import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/notification/domain/entity/notification_entity.dart';
import 'package:linknote/shared/models/paginated_state.dart';

abstract interface class INotificationRepository {
  Future<Result<PaginatedState<NotificationEntity>>> getNotifications({
    String? cursor,
    int pageSize = 20,
  });
  Future<Result<void>> markAsRead(String id);
  Future<Result<void>> markAllAsRead();
}

import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/notification/domain/repository/i_notification_repository.dart';

class MarkAllNotificationsReadUsecase {
  const MarkAllNotificationsReadUsecase(this._repository);
  final INotificationRepository _repository;

  Future<Result<void>> call() => _repository.markAllAsRead();
}

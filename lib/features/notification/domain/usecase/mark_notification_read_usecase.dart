import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/notification/domain/repository/i_notification_repository.dart';

class MarkNotificationReadUsecase {
  const MarkNotificationReadUsecase(this._repository);
  final INotificationRepository _repository;

  Future<Result<void>> call(String id) => _repository.markAsRead(id);
}

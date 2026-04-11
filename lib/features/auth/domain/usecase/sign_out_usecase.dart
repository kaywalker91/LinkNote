import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/auth/domain/repository/i_auth_repository.dart';
import 'package:linknote/features/collection/data/datasource/collection_local_datasource.dart';
import 'package:linknote/features/link/data/datasource/link_local_datasource.dart';
import 'package:linknote/features/notification/data/datasource/notification_local_datasource.dart';

class SignOutUsecase {
  const SignOutUsecase(
    this._repository,
    this._linkLocalDs,
    this._collectionLocalDs,
    this._notificationLocalDs,
  );

  final IAuthRepository _repository;
  final LinkLocalDataSource _linkLocalDs;
  final CollectionLocalDataSource _collectionLocalDs;
  final NotificationLocalDataSource _notificationLocalDs;

  Future<Result<void>> call() async {
    final result = await _repository.signOut();
    if (result.isSuccess) {
      await Future.wait([
        _linkLocalDs.clearAll(),
        _collectionLocalDs.clearAll(),
        _notificationLocalDs.clearAll(),
      ]);
    }
    return result;
  }
}

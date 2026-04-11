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
    // 서버 signOut 결과와 무관하게 로컬 캐시는 항상 클리어한다.
    // 401 경로에서 서버 세션이 이미 만료된 경우 signOut이 실패할 수
    // 있지만, 그 상황에서 로컬 데이터가 남으면 사용자 전환 시 이전
    // 계정 데이터가 UI에 노출되는 Session #5 P1-3 회귀가 발생한다.
    await Future.wait([
      _linkLocalDs.clearAll(),
      _collectionLocalDs.clearAll(),
      _notificationLocalDs.clearAll(),
    ]);
    return result;
  }
}

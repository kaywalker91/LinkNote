import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/app_update/domain/entity/update_policy.dart';

// ignore: one_member_abstracts, Clean Architecture interface contract.
abstract interface class IAppUpdateRepository {
  /// Resolve the current [UpdatePolicy] from the running version + remote
  /// config. Failures surface as [Result] — the caller must not block the app.
  Future<Result<UpdatePolicy>> getUpdatePolicy();
}

import 'package:linknote/features/app_update/domain/entity/update_policy.dart';
import 'package:linknote/features/app_update/presentation/provider/app_update_di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_update_provider.g.dart';

/// Single source of truth for the current [UpdatePolicy]. Evaluated once on
/// first read (cold start) and re-evaluated on app resume via [recheck].
///
/// A check failure never blocks the app: it resolves to [UpdatePolicy.upToDate]
/// (Remote Config still returns the last activated/force value from cache, so a
/// previously-active force policy survives offline).
@Riverpod(keepAlive: true)
class AppUpdate extends _$AppUpdate {
  @override
  Future<UpdatePolicy> build() => _check();

  Future<UpdatePolicy> _check() async {
    final result = await ref.read(checkUpdatePolicyUsecaseProvider).call();
    // On failure `data` is null → treat as up to date; never block the app.
    return result.data ?? const UpdatePolicy.upToDate();
  }

  /// Re-evaluate on resume. Keeps the current value if the device is offline
  /// mid-check (Remote Config caching makes [_check] itself resilient).
  Future<void> recheck() async {
    state = AsyncData(await _check());
  }
}

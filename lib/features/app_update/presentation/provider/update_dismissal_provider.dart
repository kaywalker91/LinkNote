import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:linknote/features/app_update/app_update_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_dismissal_provider.g.dart';

/// The highest version code the user has dismissed an optional prompt for.
/// Persisted in the encrypted `settings` Hive box so an optional banner
/// re-appears only when a strictly newer version ships.
@Riverpod(keepAlive: true)
class UpdateDismissal extends _$UpdateDismissal {
  @override
  int build() {
    final stored = Hive.box<String>(
      'settings',
    ).get(AppUpdateConstants.dismissedVersionKey);
    return int.tryParse(stored ?? '') ?? 0;
  }

  Future<void> dismiss(int versionCode) async {
    await Hive.box<String>(
      'settings',
    ).put(AppUpdateConstants.dismissedVersionKey, '$versionCode');
    state = versionCode;
  }
}

import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/app_update/data/datasource/package_info_datasource.dart';
import 'package:linknote/features/app_update/data/datasource/remote_config_update_datasource.dart';
import 'package:linknote/features/app_update/domain/entity/update_policy.dart';
import 'package:linknote/features/app_update/domain/repository/i_app_update_repository.dart';

class AppUpdateRepositoryImpl implements IAppUpdateRepository {
  const AppUpdateRepositoryImpl(this._remoteConfig, this._packageInfo);

  final RemoteConfigUpdateDataSource _remoteConfig;
  final PackageInfoDataSource _packageInfo;

  @override
  Future<Result<UpdatePolicy>> getUpdatePolicy() async {
    try {
      final current = await _packageInfo.currentVersionCode();
      final config = await _remoteConfig.fetch();

      if (!config.enabled) {
        return success(const UpdatePolicy.upToDate());
      }
      if (config.minVersionCode > current) {
        return success(
          UpdatePolicy.forced(
            minVersionCode: config.minVersionCode,
            message: config.requiredMessage,
            storeUrl: config.storeUrl,
          ),
        );
      }
      if (config.latestVersionCode > current) {
        return success(
          UpdatePolicy.optional(
            latestVersionCode: config.latestVersionCode,
            message: config.optionalMessage,
            storeUrl: config.storeUrl,
          ),
        );
      }
      return success(const UpdatePolicy.upToDate());
    } on Object catch (err) {
      return error<UpdatePolicy>(
        Failure.unknown(message: 'Update check failed: $err'),
      );
    }
  }
}

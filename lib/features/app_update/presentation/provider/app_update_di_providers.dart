import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:linknote/features/app_update/data/datasource/package_info_datasource.dart';
import 'package:linknote/features/app_update/data/datasource/remote_config_update_datasource.dart';
import 'package:linknote/features/app_update/data/repository/app_update_repository_impl.dart';
import 'package:linknote/features/app_update/domain/repository/i_app_update_repository.dart';
import 'package:linknote/features/app_update/domain/usecase/check_update_policy_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_update_di_providers.g.dart';

@riverpod
FirebaseRemoteConfig firebaseRemoteConfig(Ref ref) =>
    FirebaseRemoteConfig.instance;

@riverpod
RemoteConfigUpdateDataSource remoteConfigUpdateDataSource(Ref ref) =>
    RemoteConfigUpdateDataSource(ref.watch(firebaseRemoteConfigProvider));

@riverpod
PackageInfoDataSource packageInfoDataSource(Ref ref) =>
    const PackageInfoDataSource();

@riverpod
IAppUpdateRepository appUpdateRepository(Ref ref) => AppUpdateRepositoryImpl(
  ref.watch(remoteConfigUpdateDataSourceProvider),
  ref.watch(packageInfoDataSourceProvider),
);

@riverpod
CheckUpdatePolicyUsecase checkUpdatePolicyUsecase(Ref ref) =>
    CheckUpdatePolicyUsecase(ref.watch(appUpdateRepositoryProvider));

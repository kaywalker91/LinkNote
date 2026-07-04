// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_di_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(firebaseRemoteConfig)
final firebaseRemoteConfigProvider = FirebaseRemoteConfigProvider._();

final class FirebaseRemoteConfigProvider
    extends
        $FunctionalProvider<
          FirebaseRemoteConfig,
          FirebaseRemoteConfig,
          FirebaseRemoteConfig
        >
    with $Provider<FirebaseRemoteConfig> {
  FirebaseRemoteConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseRemoteConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseRemoteConfigHash();

  @$internal
  @override
  $ProviderElement<FirebaseRemoteConfig> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseRemoteConfig create(Ref ref) {
    return firebaseRemoteConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseRemoteConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseRemoteConfig>(value),
    );
  }
}

String _$firebaseRemoteConfigHash() =>
    r'b4c6783736b8eac479413a21329664cf4f4edcb5';

@ProviderFor(remoteConfigUpdateDataSource)
final remoteConfigUpdateDataSourceProvider =
    RemoteConfigUpdateDataSourceProvider._();

final class RemoteConfigUpdateDataSourceProvider
    extends
        $FunctionalProvider<
          RemoteConfigUpdateDataSource,
          RemoteConfigUpdateDataSource,
          RemoteConfigUpdateDataSource
        >
    with $Provider<RemoteConfigUpdateDataSource> {
  RemoteConfigUpdateDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteConfigUpdateDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteConfigUpdateDataSourceHash();

  @$internal
  @override
  $ProviderElement<RemoteConfigUpdateDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoteConfigUpdateDataSource create(Ref ref) {
    return remoteConfigUpdateDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteConfigUpdateDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteConfigUpdateDataSource>(value),
    );
  }
}

String _$remoteConfigUpdateDataSourceHash() =>
    r'3e51d91ba24b24d52c8797e397d5396cd1b40d7f';

@ProviderFor(packageInfoDataSource)
final packageInfoDataSourceProvider = PackageInfoDataSourceProvider._();

final class PackageInfoDataSourceProvider
    extends
        $FunctionalProvider<
          PackageInfoDataSource,
          PackageInfoDataSource,
          PackageInfoDataSource
        >
    with $Provider<PackageInfoDataSource> {
  PackageInfoDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packageInfoDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packageInfoDataSourceHash();

  @$internal
  @override
  $ProviderElement<PackageInfoDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PackageInfoDataSource create(Ref ref) {
    return packageInfoDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PackageInfoDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PackageInfoDataSource>(value),
    );
  }
}

String _$packageInfoDataSourceHash() =>
    r'8892aae6121b167d0e7b594022bd5a8b696d18e5';

@ProviderFor(appUpdateRepository)
final appUpdateRepositoryProvider = AppUpdateRepositoryProvider._();

final class AppUpdateRepositoryProvider
    extends
        $FunctionalProvider<
          IAppUpdateRepository,
          IAppUpdateRepository,
          IAppUpdateRepository
        >
    with $Provider<IAppUpdateRepository> {
  AppUpdateRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateRepositoryHash();

  @$internal
  @override
  $ProviderElement<IAppUpdateRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IAppUpdateRepository create(Ref ref) {
    return appUpdateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IAppUpdateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IAppUpdateRepository>(value),
    );
  }
}

String _$appUpdateRepositoryHash() =>
    r'52fce9bb96fe3558b4c0db22296f39cae4ffa370';

@ProviderFor(checkUpdatePolicyUsecase)
final checkUpdatePolicyUsecaseProvider = CheckUpdatePolicyUsecaseProvider._();

final class CheckUpdatePolicyUsecaseProvider
    extends
        $FunctionalProvider<
          CheckUpdatePolicyUsecase,
          CheckUpdatePolicyUsecase,
          CheckUpdatePolicyUsecase
        >
    with $Provider<CheckUpdatePolicyUsecase> {
  CheckUpdatePolicyUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkUpdatePolicyUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkUpdatePolicyUsecaseHash();

  @$internal
  @override
  $ProviderElement<CheckUpdatePolicyUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CheckUpdatePolicyUsecase create(Ref ref) {
    return checkUpdatePolicyUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckUpdatePolicyUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckUpdatePolicyUsecase>(value),
    );
  }
}

String _$checkUpdatePolicyUsecaseHash() =>
    r'2150b6468ed8475b7d00c5d508b0f78f1e059855';

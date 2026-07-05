// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Single source of truth for the current [UpdatePolicy]. Evaluated once on
/// first read (cold start) and re-evaluated on app resume via [recheck].
///
/// A check failure never blocks the app: it resolves to [UpdatePolicy.upToDate]
/// (Remote Config still returns the last activated/force value from cache, so a
/// previously-active force policy survives offline).

@ProviderFor(AppUpdate)
final appUpdateProvider = AppUpdateProvider._();

/// Single source of truth for the current [UpdatePolicy]. Evaluated once on
/// first read (cold start) and re-evaluated on app resume via [recheck].
///
/// A check failure never blocks the app: it resolves to [UpdatePolicy.upToDate]
/// (Remote Config still returns the last activated/force value from cache, so a
/// previously-active force policy survives offline).
final class AppUpdateProvider
    extends $AsyncNotifierProvider<AppUpdate, UpdatePolicy> {
  /// Single source of truth for the current [UpdatePolicy]. Evaluated once on
  /// first read (cold start) and re-evaluated on app resume via [recheck].
  ///
  /// A check failure never blocks the app: it resolves to [UpdatePolicy.upToDate]
  /// (Remote Config still returns the last activated/force value from cache, so a
  /// previously-active force policy survives offline).
  AppUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateHash();

  @$internal
  @override
  AppUpdate create() => AppUpdate();
}

String _$appUpdateHash() => r'09d2c6a5c85d79ca345407426064ad09509d5189';

/// Single source of truth for the current [UpdatePolicy]. Evaluated once on
/// first read (cold start) and re-evaluated on app resume via [recheck].
///
/// A check failure never blocks the app: it resolves to [UpdatePolicy.upToDate]
/// (Remote Config still returns the last activated/force value from cache, so a
/// previously-active force policy survives offline).

abstract class _$AppUpdate extends $AsyncNotifier<UpdatePolicy> {
  FutureOr<UpdatePolicy> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UpdatePolicy>, UpdatePolicy>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UpdatePolicy>, UpdatePolicy>,
              AsyncValue<UpdatePolicy>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

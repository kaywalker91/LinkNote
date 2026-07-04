// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_dismissal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The highest version code the user has dismissed an optional prompt for.
/// Persisted in the encrypted `settings` Hive box so an optional banner
/// re-appears only when a strictly newer version ships.

@ProviderFor(UpdateDismissal)
final updateDismissalProvider = UpdateDismissalProvider._();

/// The highest version code the user has dismissed an optional prompt for.
/// Persisted in the encrypted `settings` Hive box so an optional banner
/// re-appears only when a strictly newer version ships.
final class UpdateDismissalProvider
    extends $NotifierProvider<UpdateDismissal, int> {
  /// The highest version code the user has dismissed an optional prompt for.
  /// Persisted in the encrypted `settings` Hive box so an optional banner
  /// re-appears only when a strictly newer version ships.
  UpdateDismissalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateDismissalProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateDismissalHash();

  @$internal
  @override
  UpdateDismissal create() => UpdateDismissal();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$updateDismissalHash() => r'b0d134fba9dcf1b5bfeb8bbbd35018a629899143';

/// The highest version code the user has dismissed an optional prompt for.
/// Persisted in the encrypted `settings` Hive box so an optional banner
/// re-appears only when a strictly newer version ships.

abstract class _$UpdateDismissal extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

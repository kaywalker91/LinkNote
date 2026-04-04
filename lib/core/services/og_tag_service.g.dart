// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'og_tag_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ogTagService)
final ogTagServiceProvider = OgTagServiceProvider._();

final class OgTagServiceProvider
    extends $FunctionalProvider<OgTagService, OgTagService, OgTagService>
    with $Provider<OgTagService> {
  OgTagServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ogTagServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ogTagServiceHash();

  @$internal
  @override
  $ProviderElement<OgTagService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OgTagService create(Ref ref) {
    return ogTagService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OgTagService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OgTagService>(value),
    );
  }
}

String _$ogTagServiceHash() => r'519281549508ebeaed1645eff8e2794e741d1000';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AutoDispose (default): detail screens are per-link; release memory when popped.

@ProviderFor(LinkDetail)
final linkDetailProvider = LinkDetailFamily._();

/// AutoDispose (default): detail screens are per-link; release memory when popped.
final class LinkDetailProvider
    extends $AsyncNotifierProvider<LinkDetail, LinkEntity> {
  /// AutoDispose (default): detail screens are per-link; release memory when popped.
  LinkDetailProvider._({
    required LinkDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'linkDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$linkDetailHash();

  @override
  String toString() {
    return r'linkDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LinkDetail create() => LinkDetail();

  @override
  bool operator ==(Object other) {
    return other is LinkDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$linkDetailHash() => r'2d6001e669a689053ecfeeb9f614f81c37fd8526';

/// AutoDispose (default): detail screens are per-link; release memory when popped.

final class LinkDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          LinkDetail,
          AsyncValue<LinkEntity>,
          LinkEntity,
          FutureOr<LinkEntity>,
          String
        > {
  LinkDetailFamily._()
    : super(
        retry: null,
        name: r'linkDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// AutoDispose (default): detail screens are per-link; release memory when popped.

  LinkDetailProvider call(String linkId) =>
      LinkDetailProvider._(argument: linkId, from: this);

  @override
  String toString() => r'linkDetailProvider';
}

/// AutoDispose (default): detail screens are per-link; release memory when popped.

abstract class _$LinkDetail extends $AsyncNotifier<LinkEntity> {
  late final _$args = ref.$arg as String;
  String get linkId => _$args;

  FutureOr<LinkEntity> build(String linkId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LinkEntity>, LinkEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LinkEntity>, LinkEntity>,
              AsyncValue<LinkEntity>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

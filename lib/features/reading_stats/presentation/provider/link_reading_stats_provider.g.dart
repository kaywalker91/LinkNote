// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_reading_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(linkReadingStats)
final linkReadingStatsProvider = LinkReadingStatsFamily._();

final class LinkReadingStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReadingStatsEntity>,
          ReadingStatsEntity,
          FutureOr<ReadingStatsEntity>
        >
    with
        $FutureModifier<ReadingStatsEntity>,
        $FutureProvider<ReadingStatsEntity> {
  LinkReadingStatsProvider._({
    required LinkReadingStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'linkReadingStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$linkReadingStatsHash();

  @override
  String toString() {
    return r'linkReadingStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ReadingStatsEntity> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReadingStatsEntity> create(Ref ref) {
    final argument = this.argument as String;
    return linkReadingStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LinkReadingStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$linkReadingStatsHash() => r'17c5a8d1028176df05214a9d1a6bd60a085ebf14';

final class LinkReadingStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ReadingStatsEntity>, String> {
  LinkReadingStatsFamily._()
    : super(
        retry: null,
        name: r'linkReadingStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LinkReadingStatsProvider call(String linkId) =>
      LinkReadingStatsProvider._(argument: linkId, from: this);

  @override
  String toString() => r'linkReadingStatsProvider';
}

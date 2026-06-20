// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_media_stream_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Warm/foreground share-intent stream.
///
/// `getInitialMedia()` (read once in bootstrap) only covers the cold-start
/// case; shares delivered while the app is already running arrive here. The
/// plugin intentionally does NOT replay the cold-start intent on this stream,
/// so there is no double-handling with the bootstrap path.
///
/// Exposed as a provider so widget tests can inject a fake stream instead of
/// touching the platform channel.

@ProviderFor(sharedMediaStream)
final sharedMediaStreamProvider = SharedMediaStreamProvider._();

/// Warm/foreground share-intent stream.
///
/// `getInitialMedia()` (read once in bootstrap) only covers the cold-start
/// case; shares delivered while the app is already running arrive here. The
/// plugin intentionally does NOT replay the cold-start intent on this stream,
/// so there is no double-handling with the bootstrap path.
///
/// Exposed as a provider so widget tests can inject a fake stream instead of
/// touching the platform channel.

final class SharedMediaStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SharedMediaFile>>,
          List<SharedMediaFile>,
          Stream<List<SharedMediaFile>>
        >
    with
        $FutureModifier<List<SharedMediaFile>>,
        $StreamProvider<List<SharedMediaFile>> {
  /// Warm/foreground share-intent stream.
  ///
  /// `getInitialMedia()` (read once in bootstrap) only covers the cold-start
  /// case; shares delivered while the app is already running arrive here. The
  /// plugin intentionally does NOT replay the cold-start intent on this stream,
  /// so there is no double-handling with the bootstrap path.
  ///
  /// Exposed as a provider so widget tests can inject a fake stream instead of
  /// touching the platform channel.
  SharedMediaStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedMediaStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedMediaStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<SharedMediaFile>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SharedMediaFile>> create(Ref ref) {
    return sharedMediaStream(ref);
  }
}

String _$sharedMediaStreamHash() => r'ea84c2fb286568214d2caa555ab75c1aa614f06f';

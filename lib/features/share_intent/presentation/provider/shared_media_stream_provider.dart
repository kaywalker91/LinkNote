import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shared_media_stream_provider.g.dart';

/// Warm/foreground share-intent stream.
///
/// `getInitialMedia()` (read once in bootstrap) only covers the cold-start
/// case; shares delivered while the app is already running arrive here. The
/// plugin intentionally does NOT replay the cold-start intent on this stream,
/// so there is no double-handling with the bootstrap path.
///
/// Exposed as a provider so widget tests can inject a fake stream instead of
/// touching the platform channel.
@Riverpod(keepAlive: true)
Stream<List<SharedMediaFile>> sharedMediaStream(Ref ref) {
  return ReceiveSharingIntent.instance.getMediaStream();
}

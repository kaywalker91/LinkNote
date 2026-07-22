import 'package:linknote/features/share_intent/data/android_share_extras.dart';
import 'package:linknote/features/share_intent/domain/service/shared_intent_service.dart';

/// Resolves a savable web URL from plugin media + native share extras.
///
/// receive_sharing_intent maps `path` to either the shared text **or** a
/// local file path when Intent.EXTRA_STREAM is present. YouTube often sends
/// both a thumbnail stream and the video URL in EXTRA_TEXT — the plugin then
/// delivers only the file path. We fall back to native extras in that case.
class SharePayloadResolver {
  SharePayloadResolver({AndroidShareExtrasReader? extrasReader})
    : _extrasReader = extrasReader ?? AndroidShareExtrasReader();

  final AndroidShareExtrasReader _extrasReader;

  /// `pluginPath` is SharedMediaFile.path from receive_sharing_intent.
  Future<String?> resolveUrl(String? pluginPath) async {
    final fromPlugin = SharedIntentService.extractUrl(pluginPath);
    if (fromPlugin != null) return fromPlugin;

    final extras = await _extrasReader.read();
    return resolveFromExtras(pluginPath, extras);
  }

  /// Pure resolution from an already-read [extras]. Prefers the plugin path;
  /// falls back to the extras' URL candidates (EXTRA_TEXT / subject / ClipData).
  /// `boot` pre-reads extras (to gate on ACTION_SEND) and passes them here to
  /// avoid a second platform round-trip.
  String? resolveFromExtras(String? pluginPath, AndroidShareExtras? extras) {
    final fromPlugin = SharedIntentService.extractUrl(pluginPath);
    if (fromPlugin != null) return fromPlugin;
    if (extras == null) return null;
    return SharedIntentService.extractUrlFromCandidates(extras.urlCandidates);
  }
}

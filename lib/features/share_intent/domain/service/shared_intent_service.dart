import 'package:linknote/shared/utils/url_sanitizer.dart';

/// Domain service that extracts a savable URL from a raw share-intent payload.
///
/// Delegates to [UrlSanitizer] so cold-start intents and in-form paste input
/// share the same rules (YouTube "title + URL", hidden Unicode, etc.).
abstract final class SharedIntentService {
  /// Returns a usable URL from [payload], or `null` when none can be salvaged.
  static String? extractUrl(String? payload) {
    if (payload == null) return null;
    return UrlSanitizer.extract(payload);
  }

  /// Returns the collection id when [payload] is a public-collection deep link
  /// (`linknote:///collections/public/<id>`), else `null`.
  ///
  /// `linknote://` VIEW intents are delivered through `receive_sharing_intent`
  /// alongside shared URLs, so the share-intent pipeline must distinguish an
  /// internal deep link (open the read-only view) from a shared web URL (save
  /// it). The canonical share link uses an empty authority (triple slash), so
  /// the path segments are `[collections, public, <id>]`.
  static String? extractPublicCollectionId(String? payload) {
    if (payload == null) return null;
    final uri = Uri.tryParse(payload.trim());
    if (uri == null || uri.scheme != 'linknote') return null;
    final segments = uri.pathSegments;
    if (segments.length == 3 &&
        segments[0] == 'collections' &&
        segments[1] == 'public' &&
        segments[2].isNotEmpty) {
      return segments[2];
    }
    return null;
  }
}

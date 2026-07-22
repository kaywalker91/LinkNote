import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Raw extras from the current Android Activity intent (share sheet).
class AndroidShareExtras {
  const AndroidShareExtras({
    this.action,
    this.type,
    this.text,
    this.subject,
    this.htmlText,
    this.clip0Text,
    this.clip0Uri,
  });

  final String? action;
  final String? type;
  final String? text;
  final String? subject;
  final String? htmlText;

  /// First `ClipData` item text/uri — some share sources (e.g. YouTube) put the
  /// URL only here, not in EXTRA_TEXT.
  final String? clip0Text;
  final String? clip0Uri;

  /// Candidates to run through URL extraction, in priority order.
  List<String?> get urlCandidates => [
    text,
    subject,
    htmlText,
    clip0Text,
    clip0Uri,
  ];
}

/// Reads Android Intent EXTRA_TEXT / subject from the host Activity.
///
/// Used when receive_sharing_intent returns a stream/file path instead of
/// the shared URL (YouTube thumbnail + text case).
class AndroidShareExtrasReader {
  AndroidShareExtrasReader({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('app.kaywalker.linknote/share');

  final MethodChannel _channel;

  /// No-op on non-Android platforms.
  Future<AndroidShareExtras?> read() async {
    if (kIsWeb) return null;
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final raw = await _channel.invokeMethod<dynamic>('getShareExtras');
      if (raw is! Map) return null;
      return AndroidShareExtras(
        action: raw['action'] as String?,
        type: raw['type'] as String?,
        text: raw['text'] as String?,
        subject: raw['subject'] as String?,
        htmlText: raw['htmlText'] as String?,
        clip0Text: raw['clip0Text'] as String?,
        clip0Uri: raw['clip0Uri'] as String?,
      );
    } on Object {
      return null;
    }
  }
}

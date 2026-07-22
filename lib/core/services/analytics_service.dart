import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_service.g.dart';

/// Thin wrapper over [FirebaseAnalytics] so screen-view logging can be unit
/// tested without a live Firebase instance.
///
/// The root [FirebaseAnalyticsObserver] only captures pushes/pops on the root
/// navigator, so `StatefulShellRoute.indexedStack` tab switches (which merely
/// swap the indexed stack) never emit a `screen_view`. Tab switches log through
/// this service instead.
///
/// Share-intent funnel events never include raw URLs, titles, or query
/// strings — only coarse enums / reason codes (see PRD share-intent §11).
class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  Future<void> logScreenView(String screenName) {
    return _analytics.logScreenView(screenName: screenName);
  }

  /// Generic event sink used by feature code and tests.
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> logShareIntentReceived({
    required String appState,
    required String payloadType,
  }) {
    return logEvent(
      'share_intent_received',
      parameters: {
        'app_state': appState,
        'payload_type': payloadType,
      },
    );
  }

  Future<void> logShareUrlExtracted({
    required String appState,
    required String sourceCategory,
  }) {
    return logEvent(
      'share_url_extracted',
      parameters: {
        'app_state': appState,
        'source_category': sourceCategory,
      },
    );
  }

  Future<void> logShareUrlRejected({required String reasonCode}) {
    return logEvent(
      'share_url_rejected',
      parameters: {'reason_code': reasonCode},
    );
  }

  Future<void> logShareAddFormOpened({required String entryState}) {
    return logEvent(
      'share_add_form_opened',
      parameters: {'entry_state': entryState},
    );
  }

  Future<void> logShareMetadataResult({
    required bool success,
    String? failureCode,
  }) {
    return logEvent(
      'share_metadata_result',
      parameters: {
        'success': success ? 'true' : 'false',
        'failure_code': ?failureCode,
      },
    );
  }

  Future<void> logShareSaveResult({
    required bool success,
    String? failureCode,
  }) {
    return logEvent(
      'share_save_result',
      parameters: {
        'success': success ? 'true' : 'false',
        'failure_code': ?failureCode,
      },
    );
  }

  /// Coarse source bucket only — never the full host or URL.
  static String sourceCategoryForUrl(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    if (host == 'youtu.be' ||
        host == 'youtube.com' ||
        host.endsWith('.youtube.com')) {
      return 'youtube';
    }
    if (host == 'x.com' ||
        host == 'twitter.com' ||
        host == 't.co' ||
        host.endsWith('.x.com') ||
        host.endsWith('.twitter.com')) {
      return 'x';
    }
    return 'browser_other';
  }
}

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) => AnalyticsService();

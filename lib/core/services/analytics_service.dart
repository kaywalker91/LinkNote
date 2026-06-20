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
class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  Future<void> logScreenView(String screenName) {
    return _analytics.logScreenView(screenName: screenName);
  }
}

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) => AnalyticsService();

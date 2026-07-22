import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/app.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/core/config/app_config.dart';
import 'package:linknote/core/logger/app_logger.dart';
import 'package:linknote/core/services/analytics_service.dart';
import 'package:linknote/core/storage/storage_service.dart';
import 'package:linknote/features/app_update/data/datasource/remote_config_update_datasource.dart';
import 'package:linknote/features/collection/presentation/provider/pending_public_collection_provider.dart';
import 'package:linknote/features/share_intent/data/android_share_extras.dart';
import 'package:linknote/features/share_intent/domain/service/share_payload_resolver.dart';
import 'package:linknote/features/share_intent/domain/service/shared_intent_service.dart';
import 'package:linknote/features/share_intent/presentation/provider/pending_shared_url_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 앱 공통 부트스트랩. [appEnv] 전역 설정 후 초기화 실행.
Future<void> boot(
  AppEnv env, {
  required FirebaseOptions firebaseOptions,
}) async {
  appEnv = env;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  // 디버그 빌드에서는 Crashlytics 수집 비활성화 (로컬 노이즈 방지).
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );
  // Seed Remote Config defaults + fetch policy for the in-app update gate.
  // Never throws — a failure leaves the gate on inert defaults (no forced UI).
  await configureUpdateRemoteConfig(isDev: env.isDev);
  await initHive();
  _setup();
  await Supabase.initialize(
    url: env.supabaseUrl,
    anonKey: env.supabaseAnonKey,
  );

  final initialPayload = await _readInitialSharedPayload();
  // Always inspect native extras: this recovers the URL when the plugin
  // delivered no media at all (getInitialMedia() empty), a case the
  // EXTRA_TEXT/ClipData fallback could never repair when it was gated behind a
  // non-null plugin path.
  final extras = await AndroidShareExtrasReader().read();

  final container = ProviderContainer();
  final isShareLaunch =
      initialPayload != null || extras?.action == 'android.intent.action.SEND';
  if (isShareLaunch) {
    // A `linknote://collections/public/<id>` deep link and a shared web URL
    // both arrive here via receive_sharing_intent. Classify: the former opens
    // the read-only public view, the latter seeds the link-add prefill.
    final analytics = container.read(analyticsServiceProvider);
    final publicCollectionId = SharedIntentService.extractPublicCollectionId(
      initialPayload,
    );
    if (publicCollectionId != null) {
      unawaited(
        analytics.logShareIntentReceived(
          appState: 'cold',
          payloadType: 'deep_link',
        ),
      );
      container
          .read(pendingPublicCollectionProvider.notifier)
          .setInitial(Routes.publicCollectionDetailPath(publicCollectionId));
    } else {
      unawaited(
        analytics.logShareIntentReceived(
          appState: 'cold',
          payloadType: 'text',
        ),
      );
      // Prefer plugin path; fall back to EXTRA_TEXT / ClipData when the path is
      // a file or the plugin delivered nothing (YouTube stream case).
      final url = SharePayloadResolver().resolveFromExtras(
        initialPayload,
        extras,
      );
      if (url != null) {
        unawaited(
          analytics.logShareUrlExtracted(
            appState: 'cold',
            sourceCategory: AnalyticsService.sourceCategoryForUrl(url),
          ),
        );
        container.read(pendingSharedUrlProvider.notifier).setInitial(url);
      } else {
        appLogger.w(
          'Share intent: no URL from plugin path or EXTRA_TEXT',
        );
        unawaited(
          analytics.logShareUrlRejected(reasonCode: 'no_url'),
        );
      }
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LinkNoteApp(),
    ),
  );
}

/// Read the cold-start share-intent payload once and reset the native buffer
/// so warm-resume streams are not replayed. Returns the raw `path` payload
/// (a shared URL or a `linknote://` deep link), or `null` when the plugin
/// delivered nothing. Classification happens in [boot].
Future<String?> _readInitialSharedPayload() async {
  try {
    final media = await ReceiveSharingIntent.instance.getInitialMedia();
    if (media.isEmpty) return null;
    // `path` carries the shared text/URL or deep-link payload.
    final payload = media.first.path;
    await ReceiveSharingIntent.instance.reset();
    return payload;
  } on Object catch (error, stack) {
    appLogger.w(
      'ReceiveSharingIntent initial read failed',
      error: error,
      stackTrace: stack,
    );
    return null;
  }
}

void _setup() {
  FlutterError.onError = _onFE;
  PlatformDispatcher.instance.onError = _onPE;
}

void _onFE(
  FlutterErrorDetails d,
) {
  FlutterError.presentError(d);
  appLogger.e(
    'FlutterError',
    error: d.exception,
    stackTrace: d.stack,
  );
  unawaited(FirebaseCrashlytics.instance.recordFlutterError(d));
}

bool _onPE(
  Object error,
  StackTrace stack,
) {
  appLogger.e(
    'PlatformError',
    error: error,
    stackTrace: stack,
  );
  unawaited(
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
  );
  return true;
}

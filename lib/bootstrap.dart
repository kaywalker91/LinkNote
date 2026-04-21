import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/app.dart';
import 'package:linknote/core/config/app_config.dart';
import 'package:linknote/core/logger/app_logger.dart';
import 'package:linknote/core/storage/storage_service.dart';
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
  await initHive();
  _setup();
  await Supabase.initialize(
    url: env.supabaseUrl,
    anonKey: env.supabaseAnonKey,
  );

  final initialSharedUrl = await _readInitialSharedUrl();

  final container = ProviderContainer();
  if (initialSharedUrl != null) {
    container
        .read(pendingSharedUrlProvider.notifier)
        .setInitial(initialSharedUrl);
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LinkNoteApp(),
    ),
  );
}

/// Read a cold-start share-intent payload once, extract a URL if present,
/// and reset the native buffer so warm-resume streams are not replayed.
Future<String?> _readInitialSharedUrl() async {
  try {
    final media = await ReceiveSharingIntent.instance.getInitialMedia();
    if (media.isEmpty) return null;
    // Phase 1: URL-only. `path` carries the shared text/URL payload.
    final payload = media.first.path;
    final url = SharedIntentService.extractUrl(payload);
    await ReceiveSharingIntent.instance.reset();
    return url;
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

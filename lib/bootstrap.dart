import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/app.dart';
import 'package:linknote/core/config/app_config.dart';
import 'package:linknote/core/logger/app_logger.dart';
import 'package:linknote/core/storage/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 앱 공통 부트스트랩. [appEnv] 전역 설정 후 초기화 실행.
Future<void> boot(
  AppEnv env,
) async {
  appEnv = env;
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  _setup();
  await Supabase.initialize(
    url: env.supabaseUrl,
    anonKey: env.supabaseAnonKey,
  );
  runApp(
    const ProviderScope(child: LinkNoteApp()),
  );
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
  return true;
}

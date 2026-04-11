import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/app.dart';
import 'package:linknote/core/constants/env.dart';
import 'package:linknote/core/logger/app_logger.dart';
import 'package:linknote/core/storage/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO(linknote): Uncomment after running `flutterfire configure`.
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await initHive();

  // TODO(linknote): Initialize Firebase after running `flutterfire configure`.
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // if (!kDebugMode) {
  //   FlutterError.onError =
  //       FirebaseCrashlytics.instance.recordFlutterFatalError;
  //   PlatformDispatcher.instance.onError = (error, stack) {
  //     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //     return true;
  //   };
  // }

  // Global error handlers (active before Firebase is configured)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    appLogger.e(
      'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    appLogger.e('PlatformError', error: error, stackTrace: stack);
    return true;
  };

  // Initialize Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: LinkNoteApp()));
}

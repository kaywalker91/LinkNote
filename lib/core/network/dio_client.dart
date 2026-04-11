import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:linknote/core/config/app_config.dart';
import 'package:linknote/core/constants/app_constants.dart';
import 'package:linknote/core/network/auth_interceptor.dart';
import 'package:linknote/core/network/logging_interceptor.dart';
import 'package:linknote/shared/providers/session_expired_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'dio_client.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: appEnv.supabaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'apikey': appEnv.supabaseAnonKey,
      },
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      onUnauthorized: () async {
        ref.read(sessionExpiredProvider.notifier).trigger();
        await Supabase.instance.client.auth.signOut();
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(LoggingInterceptor());
  }

  return dio;
}

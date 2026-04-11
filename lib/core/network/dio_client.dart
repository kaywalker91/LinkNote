import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:linknote/core/config/app_config.dart';
import 'package:linknote/core/constants/app_constants.dart';
import 'package:linknote/core/network/auth_interceptor.dart';
import 'package:linknote/core/network/logging_interceptor.dart';
import 'package:linknote/features/auth/presentation/provider/auth_di_providers.dart';
import 'package:linknote/shared/providers/session_expired_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
        // 401 경로는 SignOutUsecase를 통과시켜 세션 무효화 + 모든
        // 로컬 캐시(Link/Collection/Notification)의 clearAll을 강제한다.
        // Supabase 직접 signOut은 clearAll 단계를 건너뛰어 사용자
        // 전환 시 이전 계정 데이터가 누출될 수 있으므로 금지.
        ref.read(sessionExpiredProvider.notifier).trigger();
        await ref.read(signOutUsecaseProvider).call();
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(LoggingInterceptor());
  }

  return dio;
}

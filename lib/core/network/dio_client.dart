import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:linknote/core/constants/app_constants.dart';
import 'package:linknote/core/constants/env.dart';
import 'package:linknote/core/network/auth_interceptor.dart';
import 'package:linknote/core/network/logging_interceptor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_client.g.dart';

@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.supabaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'apikey': Env.supabaseAnonKey,
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor());

  if (kDebugMode) {
    dio.interceptors.add(LoggingInterceptor());
  }

  return dio;
}

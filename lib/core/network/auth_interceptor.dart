import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO(linknote): Attach access token from SecureStorage/Supabase session.
    // final token = ...;
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO(linknote): Handle 401 - refresh token or redirect to login.
    handler.next(err);
  }
}

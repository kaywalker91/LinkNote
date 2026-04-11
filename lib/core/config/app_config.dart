/// 앱 빌드 플레이버.
enum Flavor { dev, staging, prod }

const Map<Flavor, String> _names = {
  Flavor.dev: 'LinkNote DEV',
  Flavor.staging: 'LinkNote STG',
  Flavor.prod: 'LinkNote',
};

/// 환경별 앱 설정.
class AppEnv {
  const AppEnv({
    required this.flavor,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  final Flavor flavor;
  final String supabaseUrl;
  final String supabaseAnonKey;

  bool get isDev => flavor == Flavor.dev;
  bool get isProd => flavor == Flavor.prod;

  String get appName => _names[flavor] ?? 'LinkNote';
}

/// 앱 전역 설정. 엔트리포인트에서 초기화.
late final AppEnv appEnv;

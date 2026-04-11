import 'package:envied/envied.dart';

part 'env_dev.g.dart';

@Envied(path: '.env.dev', obfuscate: true)
class EnvDev {
  @EnviedField(varName: 'SUPABASE_URL', defaultValue: '')
  static String supabaseUrl = _EnvDev.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', defaultValue: '')
  static String supabaseAnonKey = _EnvDev.supabaseAnonKey;
}

import 'package:envied/envied.dart';

part 'env_staging.g.dart';

@Envied(path: '.env.staging', obfuscate: true)
class EnvStg {
  @EnviedField(varName: 'SUPABASE_URL', defaultValue: '')
  static String supabaseUrl = _EnvStg.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', defaultValue: '')
  static String supabaseAnonKey = _EnvStg.supabaseAnonKey;
}

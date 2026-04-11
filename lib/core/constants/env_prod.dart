import 'package:envied/envied.dart';

part 'env_prod.g.dart';

@Envied(path: '.env.prod', obfuscate: true)
class EnvProd {
  @EnviedField(varName: 'SUPABASE_URL', defaultValue: '')
  static String supabaseUrl = _EnvProd.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', defaultValue: '')
  static String supabaseAnonKey = _EnvProd.supabaseAnonKey;
}

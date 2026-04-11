import 'package:linknote/bootstrap.dart';
import 'package:linknote/core/config/app_config.dart';
import 'package:linknote/core/constants/env_prod.dart';
import 'package:linknote/firebase_options_prod.dart';

Future<void> main(
  List<String> args,
) async {
  await boot(
    AppEnv(
      flavor: Flavor.prod,
      supabaseUrl: EnvProd.supabaseUrl,
      supabaseAnonKey: EnvProd.supabaseAnonKey,
    ),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}

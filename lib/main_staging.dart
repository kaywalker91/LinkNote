import 'package:linknote/bootstrap.dart';
import 'package:linknote/core/config/app_config.dart';
import 'package:linknote/core/constants/env_staging.dart';
import 'package:linknote/firebase_options_staging.dart';

Future<void> main(
  List<String> args,
) async {
  await boot(
    AppEnv(
      flavor: Flavor.staging,
      supabaseUrl: EnvStg.supabaseUrl,
      supabaseAnonKey: EnvStg.supabaseAnonKey,
    ),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}

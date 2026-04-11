import 'package:linknote/bootstrap.dart';
import 'package:linknote/core/config/app_config.dart';
import 'package:linknote/core/constants/env_dev.dart';

Future<void> main(
  List<String> args,
) async {
  await boot(
    AppEnv(
      flavor: Flavor.dev,
      supabaseUrl: EnvDev.supabaseUrl,
      supabaseAnonKey: EnvDev.supabaseAnonKey,
    ),
  );
}

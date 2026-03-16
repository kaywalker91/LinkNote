import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/app.dart';
import 'package:linknote/core/storage/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await initHive();

  // TODO(linknote): Initialize Firebase.
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // TODO(linknote): Initialize Supabase.
  // await Supabase.initialize(
  //   url: Env.supabaseUrl,
  //   anonKey: Env.supabaseAnonKey,
  // );

  runApp(const ProviderScope(child: LinkNoteApp()));
}

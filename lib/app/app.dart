import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/router/app_router.dart';
import 'package:linknote/app/theme/app_theme.dart';
import 'package:linknote/core/constants/app_constants.dart';

class LinkNoteApp extends ConsumerWidget {
  const LinkNoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/router/app_router.dart';
import 'package:linknote/app/theme/app_theme.dart';
import 'package:linknote/core/constants/app_constants.dart';
import 'package:linknote/shared/providers/theme_mode_provider.dart';

class LinkNoteApp extends ConsumerWidget {
  const LinkNoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModePro);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeInOut,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/router/app_router.dart';
import 'package:linknote/app/theme/app_theme.dart';
import 'package:linknote/core/constants/app_constants.dart';
import 'package:linknote/features/share_intent/presentation/widget/share_intent_listener.dart';
import 'package:linknote/shared/providers/theme_mode_provider.dart';

/// Stable key so the share-intent listener can surface snackbars from above
/// the messenger in [MaterialApp.router]'s `builder`.
final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class LinkNoteApp extends ConsumerWidget {
  const LinkNoteApp({super.key});

  static const List<LocalizationsDelegate<Object?>> localizationsDelegates =
      <LocalizationsDelegate<Object?>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ko'),
    Locale('en'),
  ];

  static const Locale defaultLocale = Locale('ko');

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
      scaffoldMessengerKey: _scaffoldMessengerKey,
      // Warm/foreground share intents arrive on a stream (cold-start is handled
      // in bootstrap). The listener sits above the Navigator so its
      // subscription and snackbar context survive route changes.
      builder: (context, child) => ShareIntentListener(
        messengerKey: _scaffoldMessengerKey,
        child: child!,
      ),
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales,
      locale: defaultLocale,
      debugShowCheckedModeBanner: false,
    );
  }
}

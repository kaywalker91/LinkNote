import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/app/theme/app_radius.dart';
import 'package:linknote/app/theme/app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      primary: AppColors.forest,
      onPrimary: Colors.white,
      surface: AppColors.bg,
      onSurface: AppColors.ink,
      error: AppColors.error,
    ),
    scaffoldBackground: AppColors.bgAlt,
    appBarBackground: AppColors.bg,
    appBarForeground: AppColors.ink,
    cardColor: AppColors.bg,
    dividerColor: AppColors.line,
    inputBorder: AppColors.lineStrong,
    navBarBackground: AppColors.bg,
    navBarIndicator: AppColors.forestSoft,
    navBarSelectedIcon: AppColors.forest,
    navBarUnselectedIcon: AppColors.ink4,
    chipBackground: AppColors.bgSunk,
    chipBorder: AppColors.line,
    fabBackground: AppColors.forest,
    fabForeground: Colors.white,
    snackBarBackground: AppColors.ink,
    snackBarForeground: AppColors.bg,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      brightness: Brightness.dark,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
    ),
    scaffoldBackground: AppColors.backgroundDark,
    appBarBackground: AppColors.surfaceDark,
    appBarForeground: AppColors.textPrimaryDark,
    cardColor: AppColors.surfaceDark,
    dividerColor: AppColors.borderDark,
    inputBorder: AppColors.borderDark,
    navBarBackground: AppColors.surfaceDark,
    navBarIndicator: AppColors.forestSoft.withValues(alpha: 0.16),
    navBarSelectedIcon: AppColors.forestSoft,
    navBarUnselectedIcon: AppColors.textSecondaryDark,
    chipBackground: AppColors.surfaceVariantDark,
    chipBorder: AppColors.borderDark,
    fabBackground: AppColors.forest,
    fabForeground: Colors.white,
    snackBarBackground: AppColors.surfaceVariantDark,
    snackBarForeground: AppColors.textPrimaryDark,
  );

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color appBarBackground,
    required Color appBarForeground,
    required Color cardColor,
    required Color dividerColor,
    required Color inputBorder,
    required Color navBarBackground,
    required Color navBarIndicator,
    required Color navBarSelectedIcon,
    required Color navBarUnselectedIcon,
    required Color chipBackground,
    required Color chipBorder,
    required Color fabBackground,
    required Color fabForeground,
    required Color snackBarBackground,
    required Color snackBarForeground,
    Brightness brightness = Brightness.light,
  }) {
    final textTheme =
        GoogleFonts.interTextTheme(
          ThemeData(brightness: brightness).textTheme,
        ).copyWith(
          displayLarge: AppTextStyles.displaySans,
          displayMedium: AppTextStyles.displaySerif,
          headlineLarge: AppTextStyles.heading1,
          headlineMedium: AppTextStyles.heading2,
          headlineSmall: AppTextStyles.heading3,
          titleLarge: AppTextStyles.titleL,
          titleMedium: AppTextStyles.titleM,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.label,
          labelMedium: AppTextStyles.caption,
          labelSmall: AppTextStyles.caption,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleL.copyWith(color: appBarForeground),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(
            color: AppColors.forest,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navBarBackground,
        indicatorColor: navBarIndicator,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: navBarSelectedIcon);
          }
          return IconThemeData(color: navBarUnselectedIcon);
        }),
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: chipBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
          side: BorderSide(color: chipBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: fabBackground,
        foregroundColor: fabForeground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.fab),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBarBackground,
        contentTextStyle: TextStyle(color: snackBarForeground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

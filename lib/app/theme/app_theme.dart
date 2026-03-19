import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        scaffoldBackground: AppColors.background,
        appBarBackground: AppColors.surface,
        appBarForeground: AppColors.textPrimary,
        cardColor: AppColors.surface,
        dividerColor: AppColors.border,
        inputBorder: AppColors.border,
        navBarBackground: AppColors.surface,
        navBarIndicator: AppColors.primary.withValues(alpha: 0.12),
        navBarSelectedIcon: AppColors.primary,
        navBarUnselectedIcon: AppColors.textSecondary,
        chipBackground: AppColors.surfaceVariant,
        chipBorder: AppColors.border,
        fabBackground: AppColors.primary,
        fabForeground: Colors.white,
        snackBarBackground: AppColors.textPrimary,
        snackBarForeground: AppColors.surface,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
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
        navBarIndicator: AppColors.primaryLight.withValues(alpha: 0.16),
        navBarSelectedIcon: AppColors.primaryLight,
        navBarUnselectedIcon: AppColors.textSecondaryDark,
        chipBackground: AppColors.surfaceVariantDark,
        chipBorder: AppColors.borderDark,
        fabBackground: AppColors.primary,
        fabForeground: Colors.white,
        snackBarBackground: AppColors.surfaceVariantDark,
        snackBarForeground: AppColors.textPrimaryDark,
      );

  static ThemeData _build({
    Brightness brightness = Brightness.light,
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
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: chipBorder),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: fabBackground,
        foregroundColor: fabForeground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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

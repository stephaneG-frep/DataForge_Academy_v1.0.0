import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Theme definitions. Uses Material 3 with a custom seed to keep the
/// "Database Laboratory + Terminal" developer identity.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandCyan,
        brightness: Brightness.light,
        surface: AppColors.lightSurface,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightSurface,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.lightSurface,
        primary: AppColors.brandCyan,
        secondary: AppColors.terminalAmber,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightCard,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.lightText,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.lightBorder),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandCyan,
        brightness: Brightness.dark,
        surface: AppColors.darkSurface,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkSurface,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.darkSurface,
        primary: AppColors.terminalGreen,
        secondary: AppColors.terminalAmber,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.darkText,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCardAlt,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
    );
  }
}

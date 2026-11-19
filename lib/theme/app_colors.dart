import 'package:flutter/material.dart';

/// Central color palette for the "Database Laboratory + Terminal" aesthetic.
class AppColors {
  AppColors._();

  // Terminal accents
  static const Color terminalGreen = Color(0xFF00E676);
  static const Color terminalAmber = Color(0xFFFFC107);
  static const Color terminalRed = Color(0xFFFF5252);
  static const Color terminalBlue = Color(0xFF40C4FF);
  static const Color terminalPurple = Color(0xFFB388FF);

  // Brand
  static const Color brandCyan = Color(0xFF00BCD4);
  static const Color brandIndigo = Color(0xFF3F51B5);
  static const Color brandNavy = Color(0xFF0D1B2A);

  // Light background tints
  static const Color lightSurface = Color(0xFFF5F7FA);
  static const Color lightCard = Colors.white;
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightText = Color(0xFF111827);
  static const Color lightMuted = Color(0xFF6B7280);

  // Dark background tints
  static const Color darkSurface = Color(0xFF0A0F16);
  static const Color darkCard = Color(0xFF121A26);
  static const Color darkCardAlt = Color(0xFF1A2434);
  static const Color darkBorder = Color(0xFF223043);
  static const Color darkText = Color(0xFFE6EDF5);
  static const Color darkMuted = Color(0xFF8A97A8);

  // Level colors
  static const List<Color> levelColors = [
    Color(0xFF00C853), // Débutant - green
    Color(0xFF00BCD4), // Fondamentaux - cyan
    Color(0xFF2979FF), // Intermédiaire - blue
    Color(0xFFAA00FF), // Avancé - purple
    Color(0xFFFF6D00), // Expert - orange
    Color(0xFFD50000), // Database Engineer - red
  ];

  // SGBD colors
}

class ThemeModeSettings {
  ThemeModeSettings._();
  static const String light = 'light';
  static const String dark = 'dark';
  static const String system = 'system';
}

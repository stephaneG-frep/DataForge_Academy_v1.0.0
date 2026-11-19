import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_colors.dart';

/// Persists user settings (theme, targets, search preferences).
class SettingsService extends ChangeNotifier {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _kTheme = 'settings.themeMode';
  static const _kTargetXp = 'settings.targetXp';
  static const _kPlaygroundFontSize = 'settings.playgroundFontSize';

  String _themeMode = ThemeModeSettings.system;
  int _targetXp = 2000;
  double _playgroundFontSize = 14;

  String get themeMode => _themeMode;
  int get targetXp => _targetXp;
  double get playgroundFontSize => _playgroundFontSize;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = prefs.getString(_kTheme) ?? ThemeModeSettings.system;
    _targetXp = prefs.getInt(_kTargetXp) ?? 2000;
    _playgroundFontSize = prefs.getDouble(_kPlaygroundFontSize) ?? 14;
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, mode);
    notifyListeners();
  }

  Future<void> setTargetXp(int xp) async {
    _targetXp = xp;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTargetXp, xp);
  }

  Future<void> setPlaygroundFontSize(double size) async {
    _playgroundFontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kPlaygroundFontSize, size);
  }
}

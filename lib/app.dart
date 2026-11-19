import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'services/progress_service.dart';
import 'services/settings_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class DataForgeApp extends StatefulWidget {
  const DataForgeApp({super.key});

  @override
  State<DataForgeApp> createState() => _DataForgeAppState();
}

class _DataForgeAppState extends State<DataForgeApp> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    SettingsService.instance.addListener(_onSettingsChanged);
    _init();
  }

  @override
  void dispose() {
    SettingsService.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _init() async {
    await SettingsService.instance.load();
    await ProgressService.instance.init();
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    final mode = SettingsService.instance.themeMode;
    return MaterialApp(
      title: 'DataForge Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode == ThemeModeSettings.light
          ? ThemeMode.light
          : mode == ThemeModeSettings.dark
              ? ThemeMode.dark
              : ThemeMode.system,
      home: _ready ? const MainShell() : const _Splash(),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? AppColors.darkSurface : AppColors.lightSurface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storage, size: 72, color: AppColors.terminalGreen),
            const SizedBox(height: 16),
            Text('DataForge Academy',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('SQL & Database Mastery',
                style: TextStyle(
                    color: dark ? AppColors.darkMuted : AppColors.lightMuted)),
            const SizedBox(height: 24),
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}

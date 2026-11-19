import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import 'glossary_screen.dart';
import 'manual_screen.dart';
import 'notes_screen.dart';
import 'reference_screens.dart';
import 'main_shell.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Références & paramètres', subtitle: 'Toutes les aides et options'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuCard(context, Icons.help_outline, AppColors.terminalBlue,
              'Mode d\'emploi', 'Comment utiliser l\'application',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManualScreen()))),
          _menuCard(context, Icons.fact_check, AppColors.terminalGreen,
              'Cheatsheets', 'Les commandes SQL essentielles',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheatsheetsScreen()))),
          _menuCard(context, Icons.grid_view, AppColors.terminalPurple,
              'Comparateur SGBD', 'Même requête, plusieurs SGBD',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComparatorScreen()))),
          _menuCard(context, Icons.terminal, AppColors.terminalAmber,
              'SQL + Programmation', 'Connecter une base dans chaque langage',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgrammingScreen()))),
          _menuCard(context, Icons.bookmark_outline, AppColors.terminalRed,
              'Glossaire', 'Les termes clés',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlossaryScreen()))),
          _menuCard(context, Icons.note_alt_outlined, AppColors.terminalGreen,
              'Notes personnelles', '${ProgressService.instance.notes.length} note(s)',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesScreen()))),
          const Divider(height: 28),
          const Text('Paramètres', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 8),
          _themeTile(context),
          _targetTile(context),
          _fontTile(context),
        ],
      ),
    );
  }

  Widget _menuCard(BuildContext context, IconData icon, Color color, String title,
      String subtitle, VoidCallback onTap) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _themeTile(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.palette_outlined, color: AppColors.terminalBlue),
        title: const Text('Thème'),
        subtitle: Text(_themeName(SettingsService.instance.themeMode)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final choice = await showDialog<String>(
            context: context,
            builder: (_) => SimpleDialog(
              title: const Text('Thème'),
              children: [
                SimpleDialogOption(onPressed: () => Navigator.pop(context, 'light'), child: const Text('Clair')),
                SimpleDialogOption(onPressed: () => Navigator.pop(context, 'dark'), child: const Text('Sombre')),
                SimpleDialogOption(onPressed: () => Navigator.pop(context, 'system'), child: const Text('Système')),
              ],
            ),
          );
          if (choice != null) await SettingsService.instance.setThemeMode(choice);
        },
      ),
    );
  }

  Widget _targetTile(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.flag_outlined, color: AppColors.terminalAmber),
        title: const Text('Objectif XP'),
        subtitle: Text('${SettingsService.instance.targetXp} XP'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final c = TextEditingController(text: '${SettingsService.instance.targetXp}');
          final r = await showDialog<int>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Objectif XP'),
              content: TextField(
                  controller: c,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'XP')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                FilledButton(onPressed: () => Navigator.pop(context, int.tryParse(c.text) ?? 2000), child: const Text('OK')),
              ],
            ),
          );
          if (r != null && r > 0) await SettingsService.instance.setTargetXp(r);
        },
      ),
    );
  }

  Widget _fontTile(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.font_download, color: AppColors.terminalGreen),
        title: const Text('Taille du texte Playground'),
        subtitle: Text('${SettingsService.instance.playgroundFontSize.toStringAsFixed(0)} px'),
        onTap: () async {
          final sizes = [11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 18.0];
          final cur = SettingsService.instance.playgroundFontSize;
          final choice = await showDialog<double>(
            context: context,
            builder: (_) => SimpleDialog(
              title: const Text('Taille du texte'),
              children: [
                for (final s in sizes)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, s),
                    child: Text('${s.toStringAsFixed(0)} px'
                        '${s == cur ? '  ✓' : ''}'),
                  ),
              ],
            ),
          );
          if (choice != null) await SettingsService.instance.setPlaygroundFontSize(choice);
        },
      ),
    );
  }

  String _themeName(String m) {
    switch (m) {
      case 'light':
        return 'Clair';
      case 'dark':
        return 'Sombre';
      default:
        return 'Système';
    }
  }
}

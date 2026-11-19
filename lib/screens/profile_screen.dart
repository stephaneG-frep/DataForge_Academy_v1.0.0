import 'package:flutter/material.dart';

import '../data/content_repository.dart';
import '../data/challenge_data.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'settings_screen.dart';
import 'main_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prog = ProgressService.instance;
    final xp = prog.xp;
    final maxXp = SettingsService.instance.targetXp;
    final repo = ContentRepository.instance;

    final totalLessons = repo.totalLessons;
    final completed = prog.completedLessons.length;
    final challenges = ChallengeData.all.length;
    final resolvedCh = prog.resolvedChallenges.length;
    final queries = prog.queriesCount;

    // Level name from XP
    final levelName = _levelFromXp(xp);

    return Scaffold(
      appBar: AppHeader(title: 'Profil', subtitle: 'XP, badges & statistiques'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _avatarHeader(context, levelName, xp, maxXp),
          const SizedBox(height: 16),
          _statsGrid(
            context,
            totalLessons,
            completed,
            challenges,
            resolvedCh,
            queries,
          ),
          const SizedBox(height: 20),
          const SectionHeading('Badges', icon: Icons.workspace_premium),
          _badgesGrid(context),
          const SizedBox(height: 20),
          const SectionHeading('Paramètres', icon: Icons.settings),
          _settingsMenu(context),
        ],
      ),
    );
  }

  String _levelFromXp(int xp) {
    if (xp >= 1000) return 'Database Engineer';
    if (xp >= 700) return 'Database Architect';
    if (xp >= 450) return 'Database Designer';
    if (xp >= 300) return 'SQL Ninja';
    if (xp >= 150) return 'JOIN Master';
    if (xp >= 50) return 'Query Hunter';
    return 'SELECT Rookie';
  }

  Widget _avatarHeader(
    BuildContext context,
    String levelName,
    int xp,
    int maxXp,
  ) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [AppColors.darkCard, const Color(0xFF122238)]
              : [const Color(0xFFE0F7FA), const Color(0xFFE3F2FD)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.terminalGreen.withValues(alpha: 0.2),
            child: const Icon(
              Icons.person,
              size: 44,
              color: AppColors.terminalGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Data Apprentice',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: dark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            levelName,
            style: const TextStyle(
              color: AppColors.terminalGreen,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          XpBar(xp: xp, maxXp: maxXp),
          const SizedBox(height: 6),
          Text(
            '$xp / $maxXp XP pour le niveau supérieur',
            style: TextStyle(fontSize: 12, color: AppColors.lightMuted),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid(
    BuildContext context,
    int tl,
    int done,
    int ch,
    int rc,
    int q,
  ) {
    final items = [
      ('Leçons', '$done/$tl', Icons.menu_book, AppColors.terminalBlue),
      ('Défis', '$rc/$ch', Icons.flag, AppColors.terminalRed),
      ('Requêtes', '$q', Icons.terminal, AppColors.terminalGreen),
      ('Quiz', '${_solvedQuizzes()}', Icons.quiz, AppColors.terminalPurple),
    ];
    // Two tiles per row; row height follows the content (no fixed aspect
    // ratio, so large system fonts don't overflow).
    final dark = Theme.of(context).brightness == Brightness.dark;
    Widget tile((String, String, IconData, Color) e) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(e.$3, color: e.$4, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      e.$2,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      e.$1,
                      style: TextStyle(
                        fontSize: 12,
                        color: dark
                            ? AppColors.darkMuted
                            : AppColors.lightMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < items.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < items.length ? 10 : 0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tile(items[i])),
                  const SizedBox(width: 10),
                  Expanded(
                    child: i + 1 < items.length
                        ? tile(items[i + 1])
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  int _solvedQuizzes() => ProgressService.instance.solvedQuizzes.length;

  Widget _badgesGrid(BuildContext context) {
    return Column(
      children: [
        for (final b in _badges())
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (b.earned ? AppColors.terminalAmber : AppColors.lightMuted)
                  .withValues(alpha: b.earned ? 0.12 : 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    (b.earned ? AppColors.terminalAmber : AppColors.lightMuted)
                        .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  b.earned ? Icons.workspace_premium : Icons.lock_outline,
                  color: b.earned
                      ? AppColors.terminalAmber
                      : Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkMuted
                      : AppColors.lightMuted,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        b.description,
                        style: const TextStyle(fontSize: 11.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (b.earned)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.terminalGreen,
                    size: 18,
                  ),
              ],
            ),
          ),
      ],
    );
  }

  List<_Badge> _badges() {
    final prog = ProgressService.instance;
    final xp = prog.xp;
    return [
      _Badge(
        'SELECT Rookie',
        'Exécute ta première requête SELECT.',
        prog.queriesCount > 0,
      ),
      _Badge(
        'Query Hunter',
        'Exécute 25 requêtes dans le Playground.',
        prog.queriesCount >= 25,
      ),
      _Badge(
        'JOIN Master',
        'Étudie les leçons sur les jointures.',
        _joinMaster(),
      ),
      _Badge(
        'SQL Ninja',
        'Réussis 3 challenges.',
        prog.resolvedChallenges.length >= 3,
      ),
      _Badge(
        'Database Designer',
        'Démarre un projet de schéma.',
        prog.completedProjects.isNotEmpty,
      ),
      _Badge(
        'Database Architect',
        'Termine 2 projets.',
        prog.completedProjects.length >= 2,
      ),
      _Badge('Database Engineer', 'Atteins 1000 XP.', xp >= 1000),
    ];
  }

  bool _joinMaster() {
    final joined = ContentRepository.instance.allLessons.where((e) {
      final t = '${e.lesson.title} ${e.lesson.id}'.toLowerCase();
      return t.contains('join') || t.contains('jointure') || t.contains('lier');
    }).length;
    return joined > 0;
  }

  Widget _settingsMenu(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.tune, color: AppColors.terminalGreen),
            title: const Text('Références & paramètres'),
            subtitle: const Text('Thèmes, guides, cheatsheets, notes...'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.palette_outlined,
              color: AppColors.terminalBlue,
            ),
            title: const Text('Apparence'),
            subtitle: Text(_themeModeName()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openThemeDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.flag_outlined,
              color: AppColors.terminalAmber,
            ),
            title: const Text('Objectif XP'),
            subtitle: Text('${SettingsService.instance.targetXp} XP'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openTargetDialog(context),
          ),
        ],
      ),
    );
  }

  String _themeModeName() {
    switch (SettingsService.instance.themeMode) {
      case 'light':
        return 'Clair';
      case 'dark':
        return 'Sombre';
      default:
        return 'Système';
    }
  }

  Future<void> _openThemeDialog(BuildContext context) async {
    final current = SettingsService.instance.themeMode;
    final choice = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Thème'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'light'),
            child: Text('Clair${current == 'light' ? ' ✓' : ''}'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'dark'),
            child: Text('Sombre${current == 'dark' ? ' ✓' : ''}'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'system'),
            child: Text('Système${current == 'system' ? ' ✓' : ''}'),
          ),
        ],
      ),
    );
    if (choice != null) {
      await SettingsService.instance.setThemeMode(choice);
      if (context.mounted) _rebuild(context);
    }
  }

  void _rebuild(BuildContext context) {
    // Trigger a rebuild so the new theme applies at app level.
    // Theme change requires app-level setState; a no-op rebuild here lets
    // the theme picker dialog close. The MaterialApp rebuilds via themeChange.
  }

  Future<void> _openTargetDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: SettingsService.instance.targetXp.toString(),
    );
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Objectif XP'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'XP à atteindre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text) ?? 2000),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      await SettingsService.instance.setTargetXp(result);
      if (context.mounted) _rebuild(context);
    }
  }
}

class _Badge {
  final String name;
  final String description;
  final bool earned;
  _Badge(this.name, this.description, this.earned);
}

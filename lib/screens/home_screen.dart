import 'package:flutter/material.dart';

import '../data/content_repository.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'glossary_screen.dart';
import 'challenges_screen.dart';
import 'learn_screen.dart';
import 'lesson_view_screen.dart';
import 'playground_screen.dart';
import 'search_screen.dart';
import 'main_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _levelNames = ['Débutant', 'Fondamentaux', 'Intermédiaire', 'Avancé', 'Expert', 'Engineer'];

  @override
  Widget build(BuildContext context) =>
      ProgressBuilder(builder: _build);

  Widget _build(BuildContext context) {
    final prog = ProgressService.instance;
    final repo = ContentRepository.instance;
    final xp = prog.xp;
    final maxXp = SettingsService.instance.targetXp;
    final last = prog.lastLesson;

    // Compute level progress (completed lessons per level index)
    final totalByLevel = <int, int>{};
    final doneByLevel = <int, int>{};
    for (final t in repo.tracks) {
      for (final l in t.lessons) {
        totalByLevel[l.levelIndex] = (totalByLevel[l.levelIndex] ?? 0) + 1;
        if (prog.completedLessons.contains(l.id)) {
          doneByLevel[l.levelIndex] = (doneByLevel[l.levelIndex] ?? 0) + 1;
        }
      }
    }

    return Scaffold(
      appBar: AppHeader(
        title: 'Accueil',
        subtitle: 'DataForge Academy',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Recherche globale',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SearchScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _heroCard(context, xp, maxXp),
          const SizedBox(height: 16),

          if (last != null) _resumeCard(context, last),
          const SizedBox(height: 16),

          Text('Parcours', style: _titleStyle(context)),
          const SizedBox(height: 10),
          _quickTracks(context),
          const SizedBox(height: 20),

          Text('Ta progression', style: _titleStyle(context)),
          const SizedBox(height: 10),
          _levelProgress(context, totalByLevel, doneByLevel),
          const SizedBox(height: 20),

          Text('Explorer', style: _titleStyle(context)),
          const SizedBox(height: 10),
          _exploreGrid(context),
        ],
      ),
    );
  }

  TextStyle _titleStyle(BuildContext ctx) => TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w800,
      color: Theme.of(ctx).brightness == Brightness.dark
          ? AppColors.darkText
          : AppColors.lightText);

  Widget _heroCard(BuildContext context, int xp, int maxXp) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [AppColors.darkCard, const Color(0xFF122238)]
              : [const Color(0xFFE0F7FA), const Color(0xFFE3F2FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.terminalGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storage, color: AppColors.terminalGreen, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bon retour !',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: dark ? AppColors.darkText : AppColors.lightText)),
                    const Text('Devient Database Engineer',
                        style: TextStyle(fontSize: 12, color: AppColors.lightMuted)),
                  ],
                ),
              ),
              Pill('$xp XP', color: AppColors.terminalGreen, icon: Icons.bolt),
            ],
          ),
          const SizedBox(height: 16),
          XpBar(xp: xp, maxXp: maxXp),
        ],
      ),
    );
  }

  Widget _resumeCard(BuildContext context, Map<String, String> last) {
    return _tapCard(
      context,
      icon: Icons.play_circle_fill,
      color: AppColors.terminalBlue,
      title: 'Reprendre : ${last['title']}',
      subtitle: 'Track ${last['track']}',
      onTap: () {
        final l = ContentRepository.instance.lessonById(last['lesson']!);
        if (l != null) {
          final t = ContentRepository.instance.trackById(l.trackId);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => LessonViewScreen(track: t!, lesson: l)));
        }
      },
    );
  }

  Widget _quickTracks(BuildContext context) {
    final repo = ContentRepository.instance;
    // Shortcuts to the main tracks: icon and label come from the track itself,
    // so they always match the "Cours" tab.
    const ids = ['sql', 'sqlite', 'postgres', 'mysql', 'mongodb', 'design'];
    const shortTitles = {'design': 'Conception'};
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final id in ids)
          if (repo.trackById(id) case final track?)
            ActionChip(
              avatar: Icon(track.icon, size: 16, color: AppColors.terminalGreen),
              label: Text(shortTitles[id] ?? track.title),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TrackLessonsScreen(track: track))),
            ),
      ],
    );
  }

  Widget _levelProgress(
      BuildContext context, Map<int, int> total, Map<int, int> done) {
    return Column(
      children: List.generate(6, (i) {
        final t = total[i] ?? 0;
        final d = done[i] ?? 0;
        final ratio = t == 0 ? 0.0 : d / t;
        final color = AppColors.levelColors[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                  width: 90,
                  child: Text(_levelNames[i],
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 10,
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                  width: 60,
                  child: Text('$d / $t',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12, color: AppColors.terminalGreen))),
            ],
          ),
        );
      }),
    );
  }

  Widget _exploreGrid(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      (_e(Icons.terminal, 'Playground', AppColors.terminalGreen),
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PlaygroundScreen()))),
      (_e(Icons.flag, 'Défis', AppColors.terminalRed),
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ChallengesScreen()))),
      (_e(Icons.menu_book, 'Apprendre', AppColors.terminalBlue),
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const LearnScreen()))),
      (_e(Icons.book, 'Glossaire', AppColors.terminalPurple),
          () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const GlossaryScreen()))),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: items.map((e) {
        final entry = e.$1;
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: e.$2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(entry.$1, color: entry.$3, size: 26),
                  Text(entry.$2,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: dark ? AppColors.darkText : AppColors.lightText)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  (IconData, String, Color) _e(IconData ic, String s, Color c) => (ic, s, c);

  Widget _tapCard(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      String? subtitle,
      required VoidCallback onTap}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: const TextStyle(fontSize: 12))
            : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../data/content_repository.dart';
import '../data/levels_data.dart';
import '../models/lesson_models.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import 'lesson_view_screen.dart';
import 'main_shell.dart';

Color _colorOf(String name) {
  switch (name) {
    case 'green':
      return AppColors.terminalGreen;
    case 'cyan':
      return AppColors.brandCyan;
    case 'blue':
      return AppColors.terminalBlue;
    case 'purple':
      return AppColors.terminalPurple;
    case 'orange':
      return AppColors.terminalAmber;
    case 'red':
      return AppColors.terminalRed;
    case 'teal':
      return const Color(0xFF26A69A);
    case 'indigo':
      return AppColors.brandIndigo;
    case 'brown':
      return const Color(0xFF8D6E63);
    case 'amber':
      return AppColors.terminalAmber;
    case 'navy':
      return AppColors.brandNavy;
    default:
      return AppColors.terminalBlue;
  }
}

Color trackColor(Track t) => _colorOf(t.color.name);

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = ContentRepository.instance;
    final prog = ProgressService.instance;

    return Scaffold(
      appBar: const AppHeader(
          title: 'Apprendre',
          subtitle: 'SQL, SGBD et conception — du débutant à l\'expert'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${repo.totalLessons} leçons · 6 niveaux',
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkMuted
                          : AppColors.lightMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final track in repo.tracks)
            _trackCard(context, track, prog),
        ],
      ),
    );
  }

  Widget _trackCard(BuildContext context, Track track, ProgressService prog) {
    final color = trackColor(track);
    final total = track.lessons.length;
    final done = track.lessons
        .where((l) => prog.completedLessons.contains(l.id))
        .length;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TrackLessonsScreen(track: track))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(track.icon,
                    color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track.title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(track.subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkMuted
                                : AppColors.lightMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : done / total,
                              minHeight: 6,
                              color: color,
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$done/$total',
                            style: TextStyle(fontSize: 12, color: color)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class TrackLessonsScreen extends StatelessWidget {
  final Track track;
  const TrackLessonsScreen({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final prog = ProgressService.instance;
    final color = trackColor(track);

    return Scaffold(
      appBar: AppHeader(title: track.title, subtitle: track.subtitle),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          for (var i = 0; i < 6; i++)
            _levelSection(context, i, color, prog),
        ],
      ),
    );
  }

  Widget _levelSection(
      BuildContext context, int lvl, Color color, ProgressService prog) {
    final lessons = track.lessons.where((l) => l.levelIndex == lvl).toList();
    if (lessons.isEmpty) return const SizedBox.shrink();
    final level = LevelsData.all[lvl];
    final done = lessons
        .where((l) => prog.completedLessons.contains(l.id))
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.levelColors[lvl].withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Niveau ${lvl + 1} · ${level.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppColors.levelColors[lvl],
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('$done/${lessons.length}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.terminalGreen)),
            ],
          ),
        ),
        for (final lesson in lessons)
          _lessonTile(context, lesson, color, prog),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _lessonTile(BuildContext context, Lesson lesson, Color color,
      ProgressService prog) {
    final done = prog.completedLessons.contains(lesson.id);
    final fav = prog.isFavorite(lesson.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => LessonViewScreen(track: track, lesson: lesson))),
        leading: Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done ? AppColors.terminalGreen : color.withValues(alpha: 0.6),
        ),
        title: Text(lesson.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(lesson.objective,
            style: const TextStyle(fontSize: 12), maxLines: 2,
            overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (fav)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.star, size: 16, color: AppColors.terminalAmber),
              ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

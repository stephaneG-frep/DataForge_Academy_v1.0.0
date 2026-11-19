import 'package:flutter/material.dart';

import '../data/content_repository.dart';
import '../data/challenge_data.dart';
import '../data/reference_data.dart';
import '../theme/app_colors.dart';
import 'challenges_screen.dart';
import 'lesson_view_screen.dart';

/// Global search across lessons, tracks, challenges and glossary.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _c = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final repo = ContentRepository.instance;

    List<({String section, String title, String subtitle, VoidCallback? onTap, IconData icon})> results = [];
    if (q.isNotEmpty) {
      for (final e in repo.allLessons) {
        final t = '${e.lesson.title} ${e.lesson.objective}'.toLowerCase();
        final track = e.track.title.toLowerCase();
        if (t.contains(q) || track.contains(q)) {
          results.add((
            section: 'Leçons · ${e.track.title}',
            title: e.lesson.title,
            subtitle: e.lesson.objective,
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => LessonViewScreen(track: e.track, lesson: e.lesson))),
            icon: Icons.menu_book,
          ));
        }
      }
      for (final c in ChallengeData.all) {
        final t = '${c.title} ${c.description}'.toLowerCase();
        if (t.contains(q)) {
          results.add((
            section: 'Challenges',
            title: c.title,
            subtitle: c.description,
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ChallengeViewScreen(challenge: c))),
            icon: Icons.flag,
          ));
        }
      }
      for (final e in GlossaryData.entries.entries) {
        if (e.key.toLowerCase().contains(q) || e.value.toLowerCase().contains(q)) {
          results.add((
            section: 'Glossaire',
            title: e.key,
            subtitle: e.value,
            onTap: null,
            icon: Icons.bookmark,
          ));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _c,
          autofocus: true,
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Rechercher une leçon, un mot...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _c.clear();
                  setState(() => _query = '');
                }),
        ],
      ),
      body: q.isEmpty
          ? const Center(child: Text('Tape un mot-clé pour chercher',
              style: TextStyle(color: AppColors.lightMuted)))
          : results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off, size: 48, color: AppColors.lightMuted),
                      const SizedBox(height: 8),
                      const Text('Aucun résultat', style: TextStyle(color: AppColors.lightMuted)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    for (final r in results)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(r.icon, color: AppColors.terminalGreen),
                          title: Text(r.title,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.section,
                                  style: const TextStyle(fontSize: 11, color: AppColors.terminalBlue)),
                              Text(r.subtitle,
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          onTap: r.onTap,
                        ),
                      ),
                  ],
                ),
    );
  }
}

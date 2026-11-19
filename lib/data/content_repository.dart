import 'package:flutter/material.dart' show IconData, Icons;

import '../models/lesson_models.dart';
import 'design_track_lessons.dart';
import 'sgbd_extra_lessons.dart';
import 'sgbd_track_lessons.dart';
import 'sql_track_lessons.dart';

/// Central access to all course tracks and their lessons.
class ContentRepository {
  ContentRepository._();
  static final ContentRepository instance = ContentRepository._();

  late final List<Track> _tracks = _build();

  List<Track> get tracks => _tracks;

  List<Track> _build() {
    final t = <Track>[
      _track('sql', 'SQL', 'Le langage universel des bases relationnelles',
          Icons.code, 'indigo', SqlTrackLessons.all()),
      _track('sqlite', 'SQLite', 'Base embarquée, zéro serveur',
          Icons.storage, 'cyan', _byLevel(SgbdTrackLessons.sqlite(), SgbdExtraLessons.sqlite())),
      _track('postgres', 'PostgreSQL', 'SGBD open source avancé',
          Icons.dns, 'blue', _byLevel(SgbdTrackLessons.postgres(), SgbdExtraLessons.postgres())),
      _track('mysql', 'MySQL', 'Le SGBD du web',
          Icons.cloud_queue, 'teal', _byLevel(SgbdTrackLessons.mysql(), SgbdExtraLessons.mysql())),
      _track('mariadb', 'MariaDB', 'Le fork communautaire de MySQL',
          Icons.lan, 'purple', _byLevel(SgbdTrackLessons.mariadb(), SgbdExtraLessons.mariadb())),
      _track('sqlserver', 'SQL Server / T-SQL', 'Le SGBD de Microsoft',
          Icons.window, 'red', _byLevel(SgbdTrackLessons.sqlserver(), SgbdExtraLessons.sqlserver())),
      _track('oracle', 'Oracle / PL-SQL', 'Le SGBD des grandes entreprises',
          Icons.account_balance, 'brown', _byLevel(SgbdTrackLessons.oracle(), SgbdExtraLessons.oracle())),
      _track('mongodb', 'MongoDB', 'NoSQL orienté document',
          Icons.dataset, 'green', _byLevel(SgbdTrackLessons.mongodb(), SgbdExtraLessons.mongodb())),
      _track('redis', 'Redis', 'Base clé-valeur en mémoire',
          Icons.bolt, 'amber', _byLevel(SgbdTrackLessons.redis(), SgbdExtraLessons.redis())),
      _track('design', 'Conception & modélisation',
          'ER, clés, relations, normalisation, sauvegarde',
          Icons.account_tree, 'cyan', DesignTrackLessons.design()),
      _track('programming', 'SQL + Programmation',
          'API REST, ORM, requêtes préparées, sécurité',
          Icons.integration_instructions, 'blue', DesignTrackLessons.programming()),
    ];
    return t;
  }

  /// Merges two lesson lists, ordered by level. Lessons of the same level
  /// keep their original order (base lessons first).
  static List<Lesson> _byLevel(List<Lesson> base, List<Lesson> extra) {
    final all = [...base, ...extra];
    final indexed = all.asMap().entries.toList()
      ..sort((a, b) {
        final byLevel = a.value.levelIndex.compareTo(b.value.levelIndex);
        return byLevel != 0 ? byLevel : a.key.compareTo(b.key);
      });
    return [for (final e in indexed) e.value];
  }

  Track _track(String id, String title, String subtitle, IconData icon,
      String color, List<Lesson> lessons) {
    return Track(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: ColorName(color),
      lessons: lessons,
    );
  }

  Track? trackById(String id) {
    for (final t in tracks) {
      if (t.id == id) return t;
    }
    return null;
  }

  Lesson? lessonById(String id) {
    for (final t in tracks) {
      for (final l in t.lessons) {
        if (l.id == id) return l;
      }
    }
    return null;
  }

  int get totalLessons =>
      tracks.fold(0, (s, t) => s + t.lessons.length);

  /// All lessons flattened with their owning track, for search & progress.
  List<({Track track, Lesson lesson})> get allLessons {
    final out = <({Track track, Lesson lesson})>[];
    for (final t in tracks) {
      for (final l in t.lessons) {
        out.add((track: t, lesson: l));
      }
    }
    return out;
  }
}

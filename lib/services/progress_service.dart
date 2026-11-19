import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central persistence for progression: XP, badges, completed lessons,
/// favorites, notes, query history, resolved challenges, solved quizzes.
///
/// Screens listen to it (ListenableBuilder) so that XP, counters and
/// checkmarks refresh everywhere as soon as progress changes.
class ProgressService extends ChangeNotifier {
  ProgressService._();
  static final ProgressService instance = ProgressService._();

  SharedPreferences? _prefs;

  static const _kXp = 'prog.xp';
  static const _kCompletedLessons = 'prog.completedLessons';
  static const _kResolvedChallenges = 'prog.resolvedChallenges';
  static const _kSolvedQuizzes = 'prog.solvedQuizzes';
  static const _kAttemptedQuizzes = 'prog.attemptedQuizzes';
  static const _kQueriesCount = 'prog.queriesCount';
  static const _kFavorites = 'prog.favorites';
  static const _kNotes = 'prog.notes';
  static const _kHistory = 'prog.history';
  static const _kCompletedProjects = 'prog.completedProjects';
  static const _kLastLesson = 'prog.lastLesson';
  static const _kPlaygroundPrefs = 'prog.playgroundPrefs';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get p => _prefs!;

  // All writes go through these helpers so listeners are notified.
  Future<void> _setInt(String k, int v) async {
    await p.setInt(k, v);
    notifyListeners();
  }

  Future<void> _setString(String k, String v) async {
    await p.setString(k, v);
    notifyListeners();
  }

  Future<void> _setStringList(String k, List<String> v) async {
    await p.setStringList(k, v);
    notifyListeners();
  }

  /// Keys erased by [resetProgress]: everything that measures progress.
  /// Notes, favorites, query history and Console preferences are kept.
  static const progressKeys = [
    _kXp,
    _kCompletedLessons,
    _kResolvedChallenges,
    _kSolvedQuizzes,
    _kAttemptedQuizzes,
    _kQueriesCount,
    _kCompletedProjects,
    _kLastLesson,
  ];

  /// Erases XP, completed lessons/projects, solved quizzes and challenges,
  /// the query counter and the « resume » lesson.
  Future<void> resetProgress() async {
    for (final k in progressKeys) {
      await p.remove(k);
    }
    notifyListeners();
  }

  // ---- XP ----
  int get xp => p.getInt(_kXp) ?? 0;

  Future<void> addXp(int amount) async {
    await _setInt(_kXp, (xp + amount).clamp(0, 1 << 31));
  }

  // ---- Completed lessons ----
  Set<String> get completedLessons =>
      (p.getStringList(_kCompletedLessons) ?? []).toSet();

  Future<void> completeLesson(String id) async {
    final s = completedLessons..add(id);
    await _setStringList(_kCompletedLessons, s.toList());
  }

  Set<String> get completedProjects =>
      (p.getStringList(_kCompletedProjects) ?? []).toSet();

  Future<void> completeProject(String id) async {
    final s = completedProjects..add(id);
    await _setStringList(_kCompletedProjects, s.toList());
  }

  // ---- Challenges ----
  Set<String> get resolvedChallenges =>
      (p.getStringList(_kResolvedChallenges) ?? []).toSet();

  Future<void> resolveChallenge(String id) async {
    final s = resolvedChallenges..add(id);
    await _setStringList(_kResolvedChallenges, s.toList());
  }

  // ---- Quizzes ----
  Set<String> get solvedQuizzes =>
      (p.getStringList(_kSolvedQuizzes) ?? []).toSet();

  Future<void> solveQuiz(String id) async {
    final s = solvedQuizzes..add(id);
    await _setStringList(_kSolvedQuizzes, s.toList());
  }

  /// Quizzes the user has already answered at least once. XP is only granted
  /// when the very first answer is correct, so guessing until right earns
  /// nothing.
  Set<String> get attemptedQuizzes =>
      (p.getStringList(_kAttemptedQuizzes) ?? []).toSet();

  /// Records an answer to quiz [id]. Returns the XP granted (0 if the quiz
  /// was already attempted or the answer is wrong).
  Future<int> answerQuiz(String id, {required bool correct, int xp = 5}) async {
    final attempted = attemptedQuizzes;
    if (attempted.contains(id) || solvedQuizzes.contains(id)) return 0;
    await _setStringList(_kAttemptedQuizzes, (attempted..add(id)).toList());
    if (!correct) return 0;
    await solveQuiz(id);
    await addXp(xp);
    return xp;
  }

  // ---- Query count ----
  int get queriesCount => p.getInt(_kQueriesCount) ?? 0;

  Future<void> incrementQueries() async {
    await _setInt(_kQueriesCount, queriesCount + 1);
  }

  // ---- Favorites ----
  List<String> get favorites => p.getStringList(_kFavorites) ?? [];

  Future<void> toggleFavorite(String id) async {
    final list = List<String>.from(favorites);
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    await _setStringList(_kFavorites, list);
  }

  bool isFavorite(String id) => favorites.contains(id);

  // ---- Notes ----
  List<Map<String, String>> get notes {
    final raw = p.getStringList(_kNotes) ?? [];
    return raw.map((e) => (jsonDecode(e) as Map).cast<String, String>()).toList();
  }

  Future<void> saveNote(String id, String title, String body) async {
    final list = List<Map<String, String>>.from(notes)
      ..removeWhere((n) => n['id'] == id)
      ..add({
        'id': id,
        'title': title,
        'body': body,
        'date': DateTime.now().toIso8601String(),
      });
    await _setStringList(
        _kNotes, list.map((e) => jsonEncode(e)).toList());
  }

  Future<void> deleteNote(String id) async {
    final list = List<Map<String, String>>.from(notes)
      ..removeWhere((n) => n['id'] == id);
    await _setStringList(_kNotes, list.map((e) => jsonEncode(e)).toList());
  }

  // ---- Query history ----
  List<Map<String, String>> get history {
    final raw = p.getStringList(_kHistory) ?? [];
    return raw.map((e) => (jsonDecode(e) as Map).cast<String, String>()).toList();
  }

  Future<void> addHistory(String sql) async {
    final list = List<Map<String, String>>.from(history)
      ..removeWhere((h) => h['sql'] == sql)
      ..insert(0, {
        'sql': sql,
        'date': DateTime.now().toIso8601String(),
      });
    if (list.length > 100) list.removeRange(100, list.length);
    await _setStringList(_kHistory, list.map((e) => jsonEncode(e)).toList());
  }

  Future<void> clearHistory() async {
    await _setStringList(_kHistory, []);
  }

  // ---- Last lesson (resume) ----
  Map<String, String>? get lastLesson {
    final raw = p.getString(_kLastLesson);
    if (raw == null) return null;
    return (jsonDecode(raw) as Map).cast<String, String>();
  }

  Future<void> setLastLesson(String lessonId, String trackTitle,
      String lessonTitle) async {
    await _setString(_kLastLesson,
        jsonEncode({'lesson': lessonId, 'track': trackTitle, 'title': lessonTitle}));
  }

  // ---- Playground prefs (favorite DB etc.) ----
  Map<String, String> get playgroundPrefs {
    final raw = p.getString(_kPlaygroundPrefs);
    if (raw == null) return {};
    return (jsonDecode(raw) as Map).cast<String, String>();
  }

  Future<void> setPlaygroundPref(String key, String value) async {
    final m = Map<String, String>.from(playgroundPrefs)..[key] = value;
    await _setString(_kPlaygroundPrefs, jsonEncode(m));
  }
}

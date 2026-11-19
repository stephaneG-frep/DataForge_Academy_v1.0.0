import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Central persistence for progression: XP, badges, completed lessons,
/// favorites, notes, query history, resolved challenges, solved quizzes.
class ProgressService {
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

  // ---- XP ----
  int get xp => p.getInt(_kXp) ?? 0;

  Future<void> addXp(int amount) async {
    await p.setInt(_kXp, (xp + amount).clamp(0, 1 << 31));
  }

  // ---- Completed lessons ----
  Set<String> get completedLessons =>
      (p.getStringList(_kCompletedLessons) ?? []).toSet();

  Future<void> completeLesson(String id) async {
    final s = completedLessons..add(id);
    await p.setStringList(_kCompletedLessons, s.toList());
  }

  Set<String> get completedProjects =>
      (p.getStringList(_kCompletedProjects) ?? []).toSet();

  Future<void> completeProject(String id) async {
    final s = completedProjects..add(id);
    await p.setStringList(_kCompletedProjects, s.toList());
  }

  // ---- Challenges ----
  Set<String> get resolvedChallenges =>
      (p.getStringList(_kResolvedChallenges) ?? []).toSet();

  Future<void> resolveChallenge(String id) async {
    final s = resolvedChallenges..add(id);
    await p.setStringList(_kResolvedChallenges, s.toList());
  }

  // ---- Quizzes ----
  Set<String> get solvedQuizzes =>
      (p.getStringList(_kSolvedQuizzes) ?? []).toSet();

  Future<void> solveQuiz(String id) async {
    final s = solvedQuizzes..add(id);
    await p.setStringList(_kSolvedQuizzes, s.toList());
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
    await p.setStringList(_kAttemptedQuizzes, (attempted..add(id)).toList());
    if (!correct) return 0;
    await solveQuiz(id);
    await addXp(xp);
    return xp;
  }

  // ---- Query count ----
  int get queriesCount => p.getInt(_kQueriesCount) ?? 0;

  Future<void> incrementQueries() async {
    await p.setInt(_kQueriesCount, queriesCount + 1);
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
    await p.setStringList(_kFavorites, list);
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
    await p.setStringList(
        _kNotes, list.map((e) => jsonEncode(e)).toList());
  }

  Future<void> deleteNote(String id) async {
    final list = List<Map<String, String>>.from(notes)
      ..removeWhere((n) => n['id'] == id);
    await p.setStringList(_kNotes, list.map((e) => jsonEncode(e)).toList());
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
    await p.setStringList(_kHistory, list.map((e) => jsonEncode(e)).toList());
  }

  Future<void> clearHistory() async {
    await p.setStringList(_kHistory, []);
  }

  // ---- Last lesson (resume) ----
  Map<String, String>? get lastLesson {
    final raw = p.getString(_kLastLesson);
    if (raw == null) return null;
    return (jsonDecode(raw) as Map).cast<String, String>();
  }

  Future<void> setLastLesson(String lessonId, String trackTitle,
      String lessonTitle) async {
    await p.setString(_kLastLesson,
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
    await p.setString(_kPlaygroundPrefs, jsonEncode(m));
  }
}

import 'package:flutter/material.dart';

import '../database/practice_data.dart';
import '../screens/playground_editor_screen.dart';

/// Links lesson content to the Console: runnable examples start with
/// `-- base : <id>`, runnable exercises end with `(base <id>)`.
class ConsoleLink {
  ConsoleLink._();

  static final _codeTag = RegExp(r'^-- base : (\w+)');
  static final _exerciseTag = RegExp(r'\s*\(base (\w+)\)\s*$');

  /// Practice database of a runnable example, or null.
  static String? baseOfCode(String code) => _valid(_codeTag.firstMatch(code)?.group(1));

  /// Practice database of a runnable exercise, or null.
  static String? baseOfExercise(String question) =>
      _valid(_exerciseTag.firstMatch(question)?.group(1));

  /// The exercise question without its trailing « (base …) » tag.
  static String exerciseText(String question) =>
      question.replaceFirst(_exerciseTag, '');

  static String? _valid(String? id) =>
      id != null && PracticeData.ids.contains(id) ? id : null;

  /// Opens the full-screen Console on [dbId], pre-filled with [sql].
  static Future<void> open(BuildContext context, String dbId, String sql) {
    return Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => PlaygroundEditorScreen(dbId: dbId, initialSql: sql)),
    );
  }
}

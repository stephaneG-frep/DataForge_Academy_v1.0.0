import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:dataforge_academy/data/content_repository.dart';
import 'package:dataforge_academy/data/sql_core_lessons.dart';
import 'package:dataforge_academy/database/playground_database.dart';
import 'package:dataforge_academy/database/practice_data.dart';
import 'package:dataforge_academy/models/table_models.dart';

final _baseTag = RegExp(r'^-- base : (\w+)');
final _exerciseBase = RegExp(r'\(base (\w+)\)\s*$');

/// Runs every statement of [sql] on [db]. Fails with a readable message.
/// Returns the result of the last statement.
Future<QueryResult> _run(String db, String sql, String where) async {
  QueryResult? last;
  for (final st in PlaygroundDatabase.splitStatements(sql)) {
    try {
      last = await PlaygroundDatabase.instance.execute(db, st);
    } on SqlError catch (e) {
      fail('$where\n  SQL: $st\n  Erreur: ${e.message}');
    }
  }
  return last!;
}

bool _isRead(String sql) =>
    RegExp(r'^\s*(select|with)\b', caseSensitive: false).hasMatch(sql);

void main() {
  setUpAll(sqfliteFfiInit);

  group('Structure de tout le contenu', () {
    final all = ContentRepository.instance.allLessons;

    test('identifiants uniques et niveaux valides', () {
      final ids = <String>{};
      for (final e in all) {
        expect(ids.add(e.lesson.id), isTrue, reason: 'doublon ${e.lesson.id}');
        expect(e.lesson.levelIndex, inInclusiveRange(0, 5), reason: e.lesson.id);
        expect(e.lesson.trackId, e.track.id, reason: e.lesson.id);
      }
    });

    test('chaque bonne réponse de quiz figure parmi les choix', () {
      for (final e in all) {
        for (final q in e.lesson.quiz) {
          expect(q.options, contains(q.correctAnswer),
              reason: '${e.lesson.id} : ${q.question}');
          expect(q.options.toSet().length, q.options.length,
              reason: 'choix en double dans ${e.lesson.id}');
        }
      }
    });
  });

  group('Parcours SQL', () {
    final lessons = ContentRepository.instance.trackById('sql')!.lessons;
    final coreIds = SqlCoreLessons.all().map((l) => l.id).toSet();

    test('contient les leçons fondamentales', () {
      expect(lessons.map((l) => l.id), containsAll(coreIds));
    });

    test('chaque leçon a un contenu complet', () {
      for (final l in lessons) {
        expect(l.content.length, greaterThanOrEqualTo(5), reason: l.id);
        expect(l.codeBlocks.length, greaterThanOrEqualTo(3), reason: l.id);
        expect(l.commonMistakes.length, greaterThanOrEqualTo(3), reason: l.id);
        expect(l.exercises.length, greaterThanOrEqualTo(2), reason: l.id);
        expect(l.quiz.length, greaterThanOrEqualTo(3), reason: l.id);
        expect(
            l.codeBlocks.where((cb) => _baseTag.hasMatch(cb.code)).length,
            greaterThanOrEqualTo(1),
            reason: '${l.id} : aucun exemple exécutable dans la Console');
        expect(l.exercises.where((e) => _exerciseBase.hasMatch(e.question)).length,
            greaterThanOrEqualTo(1),
            reason: '${l.id} : aucun exercice pratique');
        for (final cb in l.codeBlocks.where((cb) => _baseTag.hasMatch(cb.code))) {
          expect(PracticeData.ids, contains(_baseTag.firstMatch(cb.code)!.group(1)),
              reason: l.id);
        }
      }
    });

    test('les leçons fondamentales sont entièrement pratiques', () {
      for (final l in lessons.where((l) => coreIds.contains(l.id))) {
        for (final cb in l.codeBlocks) {
          expect(_baseTag.hasMatch(cb.code), isTrue,
              reason: '${l.id} : exemple sans « -- base : »');
        }
        for (final ex in l.exercises) {
          expect(_exerciseBase.hasMatch(ex.question), isTrue,
              reason: '${l.id} : exercice sans « (base …) »');
        }
      }
    });

    for (final l in lessons) {
      test('${l.id} : les exemples s\'exécutent dans l\'ordre', () async {
        await PlaygroundDatabase.instance.closeAll();
        for (var i = 0; i < l.codeBlocks.length; i++) {
          final cb = l.codeBlocks[i];
          final m = _baseTag.firstMatch(cb.code);
          if (m == null) continue; // exemple illustratif (autre SGBD, schéma…)
          final r = await _run(m.group(1)!, cb.code, '${l.id} exemple ${i + 1}');
          final last = PlaygroundDatabase.splitStatements(cb.code).last;
          if (_isRead(last)) {
            expect(r.rowCount, greaterThan(0),
                reason: '${l.id} exemple ${i + 1} : résultat vide');
          }
        }
      });

      test('${l.id} : les corrigés des exercices s\'exécutent', () async {
        for (var i = 0; i < l.exercises.length; i++) {
          final ex = l.exercises[i];
          final m = _exerciseBase.firstMatch(ex.question);
          if (m == null) continue; // question de cours
          await PlaygroundDatabase.instance.closeAll(); // base neuve
          final r = await _run(m.group(1)!, ex.answer, '${l.id} exercice ${i + 1}');
          if (_isRead(ex.answer)) {
            expect(r.rowCount, greaterThan(0),
                reason: '${l.id} exercice ${i + 1} : résultat vide');
          }
        }
      });
    }
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:dataforge_academy/app.dart';
import 'package:dataforge_academy/data/challenge_data.dart';
import 'package:dataforge_academy/database/playground_database.dart';
import 'package:dataforge_academy/models/lesson_models.dart';
import 'package:dataforge_academy/screens/challenges_screen.dart';
import 'package:dataforge_academy/screens/lesson_view_screen.dart';
import 'package:dataforge_academy/screens/main_shell.dart';
import 'package:dataforge_academy/services/progress_service.dart';

final _lesson = Lesson(
  id: 'test_lesson',
  trackId: 'sql',
  levelIndex: 0,
  title: 'Leçon de test',
  objective: 'Tester la progression',
  content: const ['Contenu.'],
  codeBlocks: const [],
  commonMistakes: const [],
  exercises: const [],
  quiz: const [
    QuizItem(
      type: QuizType.qcm,
      question: 'Question test ?',
      options: ['Réponse juste', 'Réponse fausse'],
      correctAnswer: 'Réponse juste',
      explanation: 'Explication test.',
    ),
  ],
  xp: 25,
);

final _track = Track(
  id: 'sql',
  title: 'SQL',
  subtitle: 'test',
  icon: Icons.code,
  color: const ColorName('indigo'),
  lessons: [_lesson],
);

Future<void> _resetProgress() async {
  SharedPreferences.setMockInitialValues({});
  await ProgressService.instance.init();
}

Future<void> _tapVisible(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    PlaygroundDatabase.instance.factoryOverride = databaseFactoryFfiNoIsolate;
  });

  setUp(() async {
    await _resetProgress();
    await PlaygroundDatabase.instance.closeAll();
  });

  group('ProgressService.answerQuiz', () {
    test('XP only when the first answer is correct', () async {
      final p = ProgressService.instance;
      expect(await p.answerQuiz('q1', correct: true), 5);
      expect(await p.answerQuiz('q1', correct: true), 0);
      expect(await p.answerQuiz('q2', correct: false), 0);
      expect(await p.answerQuiz('q2', correct: true), 0, reason: 'second try');
      expect(p.xp, 5);
      expect(p.solvedQuizzes, {'q1'});
    });
  });

  group('LessonViewScreen', () {
    Future<void> pumpLesson(WidgetTester tester) => tester.pumpWidget(
        MaterialApp(home: LessonViewScreen(track: _track, lesson: _lesson)));

    testWidgets('completing twice grants XP once', (tester) async {
      await pumpLesson(tester);
      await _tapVisible(tester, find.text('Marquer comme terminée'));
      expect(ProgressService.instance.xp, 25);
      expect(find.text('Leçon terminée'), findsOneWidget);
      await _tapVisible(tester, find.text('Leçon terminée'));
      expect(ProgressService.instance.xp, 25);
    });

    testWidgets('quiz answer is locked after a wrong first answer',
        (tester) async {
      await pumpLesson(tester);
      await _tapVisible(tester, find.text('Réponse fausse'));
      await _tapVisible(tester, find.text('Réponse juste'));
      expect(ProgressService.instance.xp, 0);
      expect(find.byIcon(Icons.cancel), findsOneWidget,
          reason: 'the wrong choice stays selected');
    });

    testWidgets('correct first answer grants 5 XP', (tester) async {
      await pumpLesson(tester);
      await _tapVisible(tester, find.text('Réponse juste'));
      expect(ProgressService.instance.xp, 5);
    });
  });

  group('ChallengeViewScreen', () {
    final ch = ChallengeData.all.firstWhere((c) => c.id == 'ch_02');

    // Open the DB in the real zone: a DB created inside a test's fake-async
    // zone cannot be closed from the next test's setUp.
    Future<void> pumpChallenge(WidgetTester tester) async {
      await tester.runAsync(
          () => PlaygroundDatabase.instance.openDatabase(ch.databaseId));
      await tester.pumpWidget(
          MaterialApp(home: ChallengeViewScreen(challenge: ch)));
    }

    Future<void> submit(WidgetTester tester, String sql) async {
      await tester.enterText(find.byType(TextField), sql);
      await tester.tap(find.text('Vérifier ma réponse'));
      // The check shows an endless spinner, so pumpAndSettle would never
      // return: pump until the button label comes back.
      for (var i = 0; i < 100; i++) {
        await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 10)));
        await tester.pump(const Duration(milliseconds: 20));
        if (find.text('Vérifier ma réponse').evaluate().isNotEmpty) break;
      }
      await tester.pump();
    }

    testWidgets('destructive query is refused and grants nothing',
        (tester) async {
      await pumpChallenge(tester);
      await submit(tester, 'DELETE FROM products;');
      expect(find.textContaining('requête de lecture'), findsOneWidget);
      expect(ProgressService.instance.xp, 0);
      // The practice database is untouched.
      final r = await tester.runAsync(() => PlaygroundDatabase.instance
          .execute('boutique', 'SELECT COUNT(*) FROM products;'));
      expect(r!.rows.first.first, 12);
    });

    testWidgets('right rows in the wrong order are rejected', (tester) async {
      await pumpChallenge(tester);
      await submit(tester,
          'SELECT name, price FROM products WHERE price < 50 ORDER BY price ASC;');
      expect(find.textContaining('pas dans l\'ordre demandé'), findsOneWidget);
      expect(ProgressService.instance.xp, 0);
    });

    testWidgets('correct query passes once', (tester) async {
      await pumpChallenge(tester);
      await submit(tester,
          'select p.name, p.price from products p where p.price < 50 order by p.price desc');
      expect(find.text('Réussi ! Bravo 🎉'), findsOneWidget);
      expect(ProgressService.instance.xp, ch.xp);
      await submit(tester,
          'SELECT name, price FROM products WHERE price < 50 ORDER BY price DESC;');
      expect(ProgressService.instance.xp, ch.xp, reason: 'no XP twice');
    });
  });

  testWidgets('app boots and every tab renders', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DataForgeApp());
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();
    expect(find.byType(MainShell), findsOneWidget);

    for (final label in ['Apprendre', 'Playground', 'Défis', 'Projets', 'Profil', 'Accueil']) {
      await tester.tap(find.descendant(
          of: find.byType(NavigationBar), matching: find.text(label)));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: label);
    }
  });
}

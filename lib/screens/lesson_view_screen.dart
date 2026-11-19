import 'package:flutter/material.dart';

import '../data/levels_data.dart';
import '../models/lesson_models.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class LessonViewScreen extends StatefulWidget {
  final Track track;
  final Lesson lesson;
  const LessonViewScreen({super.key, required this.track, required this.lesson});

  @override
  State<LessonViewScreen> createState() => _LessonViewScreenState();
}

class _LessonViewScreenState extends State<LessonViewScreen> {
  final Map<int, int> _selectedAnswers = {};
  final Map<int, bool> _revealedQuiz = {};
  final Set<String> _revealedExercises = {};
  ProgressService get _prog => ProgressService.instance;

  @override
  void initState() {
    super.initState();
    _prog.setLastLesson(
        widget.lesson.id, widget.track.title, widget.lesson.title);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final level = LevelsData.all[lesson.levelIndex];
    final done = _prog.completedLessons.contains(lesson.id);
    final fav = _prog.isFavorite(lesson.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.track.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(fav ? Icons.star : Icons.star_border,
                color: fav ? AppColors.terminalAmber : null),
            tooltip: 'Favori',
            onPressed: () {
              setState(() => _prog.toggleFavorite(lesson.id));
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'note') _openNote(context);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'note', child: Text('Ajouter une note')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          Row(
            children: [
              Pill('Niveau ${level.index + 1} · ${level.name}',
                  color: AppColors.levelColors[level.index]),
              const SizedBox(width: 6),
              Pill('+${lesson.xp} XP', color: AppColors.terminalGreen,
                  icon: Icons.bolt),
            ],
          ),
          const SizedBox(height: 12),
          Text(lesson.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.2)),
          const SizedBox(height: 8),
          _objectiveBox(context, lesson.objective),

          // COURSE
          const SectionHeading('Cours', icon: Icons.menu_book),
          for (final para in lesson.content)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(para,
                  style: TextStyle(
                      fontSize: 15,
                      height: 1.55,
                      color: dark ? AppColors.darkText : AppColors.lightText)),
            ),

          // CODE BLOCKS
          if (lesson.codeBlocks.isNotEmpty) ...[
            const SectionHeading('Syntaxe & exemples', icon: Icons.terminal),
            for (final cb in lesson.codeBlocks)
              TerminalCode(cb.code,
                  title: cb.language, caption: cb.explanation),
          ],

          // MISTAKES
          if (lesson.commonMistakes.isNotEmpty) ...[
            const SectionHeading('Erreurs fréquentes', icon: Icons.warning_amber),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.terminalRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.terminalRed.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  for (final m in lesson.commonMistakes)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 16, color: AppColors.terminalRed),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(m, style: const TextStyle(fontSize: 13, height: 1.4)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],

          // EXERCISES
          if (lesson.exercises.isNotEmpty) ...[
            const SectionHeading('Exercices', icon: Icons.fitness_center),
            for (var i = 0; i < lesson.exercises.length; i++)
              _exerciseCard(context, i, lesson.exercises[i]),
          ],

          // QUIZ
          if (lesson.quiz.isNotEmpty) ...[
            const SectionHeading('Mini-quiz', icon: Icons.quiz),
            for (var i = 0; i < lesson.quiz.length; i++)
              _quizCard(context, i, lesson.quiz[i]),
          ],

          const SizedBox(height: 24),
          _completeButton(context, done),
        ],
      ),
    );
  }

  Widget _objectiveBox(BuildContext context, String text) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: dark
            ? [AppColors.darkCardAlt, AppColors.darkCard]
            : [const Color(0xFFE0F7FA), const Color(0xFFF1F8FF)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.track_changes, color: AppColors.terminalBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Objectif : $text',
                style: const TextStyle(fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _exerciseCard(BuildContext context, int i, ExerciseItem ex) {
    final revealed = _revealedExercises.contains(ex.question);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26, height: 26,
                  decoration: const BoxDecoration(
                      color: AppColors.terminalBlue, shape: BoxShape.circle),
                  child: const Center(
                      child: Text('${1}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Exercice ${_indexFor(context, ex)}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(ex.question, style: const TextStyle(fontSize: 14, height: 1.4)),
            const SizedBox(height: 8),
            if (revealed) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.terminalGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Solution :',
                        style: TextStyle(
                            color: AppColors.terminalGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(ex.answer,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(ex.explanation, style: const TextStyle(fontSize: 12, height: 1.4)),
                  ],
                ),
              ),
            ] else
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: const Text('Voir la correction'),
                  onPressed: () => setState(() => _revealedExercises.add(ex.question)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _indexFor(BuildContext context, ExerciseItem ex) {
    return widget.lesson.exercises.indexOf(ex) + 1;
  }

  Widget _quizCard(BuildContext context, int i, QuizItem q) {
    final answered = _selectedAnswers.containsKey(i);
    final reversed = (q.type == QuizType.trueFalse);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Pill(_quizTypeLabel(q.type), color: AppColors.terminalPurple),
                const Spacer(),
                if (reversed)
                  IconButton(
                    icon: const Icon(Icons.sync, size: 18),
                    onPressed: () => setState(() {
                      _selectedAnswers.remove(i);
                      _revealedQuiz.remove(i);
                      // flip for true/false
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(q.question,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3)),
            const SizedBox(height: 12),
            if (reversed && q.options.length == 2)
              _trueFalseChoices(context, i, q)
            else
              for (var o = 0; o < q.options.length; o++)
                _choiceTile(context, i, o, q),
            if (answered || _revealedQuiz.containsKey(i))
              _feedback(context, i, q),
          ],
        ),
      ),
    );
  }

  String _quizTypeLabel(QuizType t) {
    switch (t) {
      case QuizType.qcm:
        return 'QCM';
      case QuizType.trueFalse:
        return 'Vrai / Faux';
      case QuizType.completeQuery:
        return 'Complète la requête';
      case QuizType.findError:
        return 'Trouve l\'erreur';
      case QuizType.predictResult:
        return 'Prédit le résultat';
      case QuizType.writeQuery:
        return 'Écris la requête';
    }
  }

  Widget _trueFalseChoices(BuildContext context, int i, QuizItem q) {
    return Row(
      children: [
        Expanded(child: _tfButton(context, i, q, q.options[0], q.options[0] == q.correctAnswer)),
        const SizedBox(width: 10),
        Expanded(child: _tfButton(context, i, q, q.options[1], q.options[1] == q.correctAnswer)),
      ],
    );
  }

  Widget _tfButton(BuildContext context, int i, QuizItem q, String label, bool isCorrect) {
    final selected = _selectedAnswers[i] == q.options.indexOf(label);
    final correct = label == q.correctAnswer;
    Color? bg;
    Color? border;
    if (selected) {
      bg = correct ? AppColors.terminalGreen.withValues(alpha: 0.15) : AppColors.terminalRed.withValues(alpha: 0.15);
      border = correct ? AppColors.terminalGreen : AppColors.terminalRed;
    }
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: selected && correct ? AppColors.terminalGreen : null,
        backgroundColor: bg,
        side: border != null ? BorderSide(color: border) : null,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: () => _select(i, q, label),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget _choiceTile(BuildContext context, int i, int o, QuizItem q) {
    final selected = _selectedAnswers[i] == o;
    final isCorrectOption = q.options[o] == q.correctAnswer;
    final answered = _selectedAnswers.containsKey(i) || _revealedQuiz.containsKey(i);
    Color? borderColor;
    if (selected) {
      borderColor = isCorrectOption ? AppColors.terminalGreen : AppColors.terminalRed;
    } else if (answered && isCorrectOption) {
      borderColor = AppColors.terminalGreen;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor ?? Colors.transparent, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _select(i, q, q.options[o]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                selected
                    ? (isCorrectOption ? Icons.check_circle : Icons.cancel)
                    : Icons.radio_button_unchecked,
                color: selected
                    ? (isCorrectOption ? AppColors.terminalGreen : AppColors.terminalRed)
                    : AppColors.lightMuted,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(q.options[o],
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: q.type == QuizType.completeQuery ||
                                q.type == QuizType.writeQuery
                            ? 'monospace'
                            : null,
                        height: 1.3)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _select(int i, QuizItem q, String answer) {
    // One answer per question: the choice is locked once made.
    if (_selectedAnswers.containsKey(i)) return;
    setState(() {
      _selectedAnswers[i] = q.options.indexOf(answer);
      _revealedQuiz[i] = true;
    });
    // XP only if this is the first answer ever given to this question.
    _prog
        .answerQuiz('${widget.lesson.id}#q$i',
            correct: answer == q.correctAnswer)
        .then((xp) {
      if (xp > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('+$xp XP'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ));
      }
    });
  }

  Widget _feedback(BuildContext context, int i, QuizItem q) {
    final answered = _selectedAnswers[i];
    final correct = answered != null && q.options[answered] == q.correctAnswer;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (correct ? AppColors.terminalGreen : AppColors.terminalAmber)
              .withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  correct ? Icons.check_circle : Icons.lightbulb,
                  color: correct ? AppColors.terminalGreen : AppColors.terminalAmber,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  correct ? 'Bonne réponse !' : 'Indice',
                  style: TextStyle(
                      color: correct ? AppColors.terminalGreen : AppColors.terminalAmber,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(q.explanation, style: const TextStyle(fontSize: 13, height: 1.4)),
            if (!correct)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Réponse : ${q.correctAnswer}',
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppColors.terminalGreen),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _completeButton(BuildContext context, bool done) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.terminalGreen,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () async {
          // Re-read the state at tap time: `done` was captured at build time.
          final already = _prog.completedLessons.contains(widget.lesson.id);
          if (!already) {
            await _prog.completeLesson(widget.lesson.id);
            await _prog.addXp(widget.lesson.xp);
          }
          if (!context.mounted) return;
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(already
                  ? 'Leçon déjà terminée 👍'
                  : 'Leçon terminée ! +${widget.lesson.xp} XP'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: Icon(done ? Icons.check_circle : Icons.done_all),
        label: Text(done ? 'Leçon terminée' : 'Marquer comme terminée'),
      ),
    );
  }

  Future<void> _openNote(BuildContext context) async {
    final existing = _prog.notes
        .firstWhere((n) => n['id'] == widget.lesson.id, orElse: () => {});
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _NoteSheet(
          lessonId: widget.lesson.id,
          lessonTitle: widget.lesson.title,
          initialTitle: existing['title'] ?? widget.lesson.title,
          initialBody: existing['body'] ?? '',
        ),
      ),
    );
  }
}

class _NoteSheet extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;
  final String initialTitle;
  final String initialBody;
  const _NoteSheet(
      {required this.lessonId,
      required this.lessonTitle,
      required this.initialTitle,
      required this.initialBody});

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final TextEditingController _title;
  late final TextEditingController _body;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initialTitle);
    _body = TextEditingController(text: widget.initialBody);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Note personnelle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextField(
              controller: _title,
              decoration: const InputDecoration(
                  labelText: 'Titre', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
              controller: _body,
              maxLines: 5,
              decoration: const InputDecoration(
                  labelText: 'Contenu', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                ProgressService.instance.saveNote(
                    widget.lessonId, _title.text.trim(), _body.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Note enregistrée'),
                    behavior: SnackBarBehavior.floating));
              },
              child: const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }
}

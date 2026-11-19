import 'package:flutter/widgets.dart' show IconData;

/// A conceptual course "track" grouping lessons for one technology or topic.
class Track {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final ColorName color;
  final List<Lesson> lessons;

  Track({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.lessons,
  });
}

/// Simple color wrapper to keep model decoupled from Flutter types.
class ColorName {
  final String name;
  const ColorName(this.name);
}

/// A level (Débutant → Database Engineer).
class Level {
  final String id;
  final String name;
  final String description;
  final int index;

  const Level(this.id, this.name, this.description, this.index);
}

/// One lesson with real pedagogical content.
class Lesson {
  final String id;
  final String trackId;
  final int levelIndex;
  final String title;
  final String objective;
  final List<String> content; // paragraphs
  final List<CodeBlock> codeBlocks;
  final List<String> commonMistakes;
  final List<ExerciseItem> exercises;
  final List<QuizItem> quiz;
  final int xp;

  Lesson({
    required this.id,
    required this.trackId,
    required this.levelIndex,
    required this.title,
    required this.objective,
    required this.content,
    required this.codeBlocks,
    required this.commonMistakes,
    required this.exercises,
    required this.quiz,
    this.xp = 25,
  });
}

class CodeBlock {
  final String language;
  final String code;
  final String? explanation;

  CodeBlock(this.language, this.code, {this.explanation});
}

class ExerciseItem {
  final String question;
  final String answer;
  final String explanation;

  ExerciseItem(this.question, this.answer, this.explanation);
}

enum QuizType { qcm, trueFalse, completeQuery, findError, predictResult, writeQuery }

class QuizItem {
  final QuizType type;
  final String question;
  final List<String> options; // for qcm / complete query options
  final String correctAnswer; // matching option text or expected SQL
  final String explanation;

  const QuizItem({
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });
}

/// A coding challenge where the user writes SQL and it's auto-checked.
class Challenge {
  final String id;
  final String databaseId; // which practice DB to run against
  final String title;
  final String description;
  final String hint;
  final String solution;
  final String explanation;
  final int level; // 1..6 difficulty
  final int xp;
  final List<String> tags;

  /// When the mission requires a specific order, the result column the rows
  /// must be sorted on (as named in the solution's output). Rows that tie on
  /// this column may appear in any order.
  final String? orderByColumn;
  final bool orderDescending;

  const Challenge({
    required this.id,
    required this.databaseId,
    required this.title,
    required this.description,
    required this.hint,
    required this.solution,
    required this.explanation,
    required this.level,
    required this.xp,
    required this.tags,
    this.orderByColumn,
    this.orderDescending = false,
  });
}

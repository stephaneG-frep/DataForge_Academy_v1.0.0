import '../models/challenge_models.dart';
import '../models/table_models.dart';
import 'sql_util.dart';

enum CheckVerdict { passed, wrongRows, wrongOrder }

/// Compares the user's result with the solution's result for a challenge.
///
/// - Rows must match as a multiset (values compared position by position,
///   case-insensitive for text, 5 == 5.0 for numbers).
/// - If the challenge requires an order ([Challenge.orderByColumn]), the
///   user's rows must also be sorted on that column (ties in any order). If
///   the user's result has no column with that name, rows must appear in
///   exactly the solution's order.
class ChallengeChecker {
  ChallengeChecker._();

  static CheckVerdict check(
      Challenge c, QueryResult user, QueryResult solution) {
    final userRows = user.rows.map(SqlUtil.rowKeys).toList();
    final solRows = solution.rows.map(SqlUtil.rowKeys).toList();
    if (!SqlUtil.datasetsEqual(solRows, userRows)) return CheckVerdict.wrongRows;

    final orderCol = c.orderByColumn;
    if (orderCol == null) return CheckVerdict.passed;
    final idx = user.columns
        .indexWhere((col) => col.name.toLowerCase() == orderCol.toLowerCase());
    final sorted = idx >= 0
        ? SqlUtil.isSortedOn(user.rows, idx, descending: c.orderDescending)
        : SqlUtil.datasetsEqualOrdered(solRows, userRows);
    return sorted ? CheckVerdict.passed : CheckVerdict.wrongOrder;
  }
}

/// Utilities to compare SQL result sets (used to check challenges).
class SqlUtil {
  SqlUtil._();

  /// Convert a row of values to stable comparison keys:
  /// handles numeric/string and NULL consistently.
  static List<String> rowKeys(List<Object?> row) {
    return row.map((v) {
      if (v == null) return '__NULL__';
      if (v is int) return 'I$v';
      if (v is double) {
        if (v == v.roundToDouble()) return 'I${v.round()}';
        return 'D$v';
      }
      return 'S${v.toString().trim().toLowerCase()}';
    }).toList();
  }

  /// Compare two result row sets regardless of column order (by aligned index).
  static bool datasetsEqual(
      List<List<String>> expected, List<List<String>> actual) {
    if (expected.length != actual.length) return false;
    final sortedExpected = List<List<String>>.from(expected)
      ..sort((a, b) => a.join('|').compareTo(b.join('|')));
    final sortedActual = List<List<String>>.from(actual)
      ..sort((a, b) => a.join('|').compareTo(b.join('|')));
    for (var i = 0; i < sortedExpected.length; i++) {
      if (sortedExpected[i].join('|') != sortedActual[i].join('|')) {
        return false;
      }
    }
    return true;
  }

  /// Same rows in the same order (row-by-row comparison).
  static bool datasetsEqualOrdered(
      List<List<String>> expected, List<List<String>> actual) {
    if (expected.length != actual.length) return false;
    for (var i = 0; i < expected.length; i++) {
      if (expected[i].join('|') != actual[i].join('|')) return false;
    }
    return true;
  }

  /// True if [rows] are sorted on column [col] (ASC or DESC), using SQLite's
  /// ordering: NULL < numbers < text. Ties may appear in any order.
  static bool isSortedOn(List<List<Object?>> rows, int col,
      {bool descending = false}) {
    for (var i = 1; i < rows.length; i++) {
      final cmp = compareSqlValues(rows[i - 1][col], rows[i][col]);
      if (descending ? cmp < 0 : cmp > 0) return false;
    }
    return true;
  }

  static int compareSqlValues(Object? a, Object? b) {
    int rank(Object? v) => v == null ? 0 : (v is num ? 1 : 2);
    final ra = rank(a), rb = rank(b);
    if (ra != rb) return ra.compareTo(rb);
    if (a == null) return 0;
    if (a is num && b is num) return a.compareTo(b);
    return a.toString().compareTo(b.toString());
  }
}

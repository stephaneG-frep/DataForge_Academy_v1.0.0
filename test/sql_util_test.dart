import 'package:flutter_test/flutter_test.dart';

import 'package:dataforge_academy/utils/sql_util.dart';

void main() {
  group('SqlUtil', () {
    test('rowKeys distinguish NULL, int and string', () {
      expect(SqlUtil.rowKeys([null]), ['__NULL__']);
      expect(SqlUtil.rowKeys([5]), ['I5']);
      expect(SqlUtil.rowKeys([5.0]), ['I5']);
      expect(SqlUtil.rowKeys([5.5]), ['D5.5']);
      expect(SqlUtil.rowKeys(['HELLO']), ['Shello']);
    });

    test('datasetsEqual ignores row order but respects count', () {
      final a = [['I1'], ['I2']];
      final b = [['I2'], ['I1']];
      expect(SqlUtil.datasetsEqual(a, b), isTrue);

      final c = [['I1']];
      expect(SqlUtil.datasetsEqual(a, c), isFalse);
    });

    test('isSortedOn tolerates ties and detects wrong order', () {
      final rows = [
        ['A', 2014], ['B', 2008], ['C', 2008], ['D', 1999],
      ];
      expect(SqlUtil.isSortedOn(rows, 1, descending: true), isTrue);
      final tiesSwapped = [rows[0], rows[2], rows[1], rows[3]];
      expect(SqlUtil.isSortedOn(tiesSwapped, 1, descending: true), isTrue);
      expect(SqlUtil.isSortedOn(rows.reversed.toList(), 1, descending: true), isFalse);
      expect(SqlUtil.isSortedOn([[null], [1], ['x']], 0), isTrue);
    });

  });
}

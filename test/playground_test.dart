import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:dataforge_academy/data/challenge_data.dart';
import 'package:dataforge_academy/database/playground_database.dart';
import 'package:dataforge_academy/models/table_models.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    await PlaygroundDatabase.instance.closeAll();
  });

  group('PlaygroundDatabase', () {
    test('seeds boutique database with products', () async {
      final db = PlaygroundDatabase.instance;
      final tables = await db.listTables('boutique');
      final names = tables.map((t) => t['name']).toSet();
      expect(names, contains('products'));
      expect(names, contains('categories'));
      expect(names, contains('clients'));
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('runs a SELECT and returns rows', () async {
      final r = await PlaygroundDatabase.instance
          .execute('boutique', 'SELECT name, price FROM products WHERE price < 50 ORDER BY price DESC;');
      expect(r.columns.isNotEmpty, isTrue);
      expect(r.rowCount, greaterThan(0));
      // Verify all returned prices < 50
      for (final row in r.rows) {
        final price = (row[1] as num).toDouble();
        expect(price, lessThan(50));
      }
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('runs a JOIN', () async {
      final r = await PlaygroundDatabase.instance
          .execute('employes', 'SELECT e.nom, d.nom FROM employes e JOIN departements d ON e.departement_id = d.id;');
      expect(r.rowCount, 12);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('runs GROUP BY with HAVING', () async {
      final r = await PlaygroundDatabase.instance
          .execute('ecole', 'SELECT cours_id, AVG(note) m FROM notes GROUP BY cours_id HAVING AVG(note) > 10;');
      expect(r.rowCount, greaterThan(0));
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('raises friendly error for unknown table', () async {
      expect(
        () => PlaygroundDatabase.instance
            .execute('boutique', 'SELECT * FROM inconnue;'),
        throwsA(isA<SqlError>()),
      );
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('INSERT reports exactly one affected row', () async {
      final r = await PlaygroundDatabase.instance
          .execute('boutique', "INSERT INTO products (name, price, category_id, stock) VALUES ('Test', 1.0, 1, 5);");
      expect(r.affectedRows, 1);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('UPDATE reports the real number of affected rows', () async {
      final pg = PlaygroundDatabase.instance;
      final r = await pg.execute('boutique', 'UPDATE products SET stock = 0;');
      expect(r.affectedRows, 12);
      final d = await pg.execute('boutique', 'DELETE FROM products WHERE price > 100;');
      expect(d.affectedRows, 1);
      final ddl = await pg.execute('boutique', 'CREATE TABLE t (x INTEGER);');
      expect(ddl.affectedRows, 0);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('each practice database is independent', () async {
      final pg = PlaygroundDatabase.instance;
      await pg.execute('boutique', 'SELECT * FROM products;');
      final emp = await pg.listTables('employes');
      expect(emp.map((t) => t['name']).toSet(), {'departements', 'employes'});
      // Every challenge solution runs, in any order, in the same session.
      for (final c in ChallengeData.all) {
        final r = await pg.execute(c.databaseId, c.solution);
        expect(r.rowCount, greaterThan(0), reason: c.id);
      }
      // A change in one database does not leak into another.
      await pg.execute('films', 'DELETE FROM films;');
      final b = await pg.execute('boutique', 'SELECT COUNT(*) FROM products;');
      expect(b.rows.first.first, 12);
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('rejects multiple statements, accepts comments and trailing ;', () async {
      final pg = PlaygroundDatabase.instance;
      expect(() => pg.execute('boutique', 'SELECT 1; DELETE FROM products;'),
          throwsA(isA<SqlError>()));
      final r = await pg.execute('boutique',
          "-- commentaire\nSELECT 'a;b' AS s /* ; */ ;  -- fin");
      expect(r.rows.first.first, 'a;b');
      expect(() => pg.execute('boutique', '  -- rien  '),
          throwsA(isA<SqlError>()));
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('CREATE TRIGGER with a multi-statement body is one statement', () {
      final st = PlaygroundDatabase.splitStatements(
          'CREATE TRIGGER tr AFTER INSERT ON t BEGIN UPDATE t SET x = 1; '
          'UPDATE t SET x = 2; END; SELECT 1;');
      expect(st.length, 2);
    });

    test('read-only execution refuses writes and never modifies data', () async {
      final pg = PlaygroundDatabase.instance;
      for (final sql in [
        'DELETE FROM employes;',
        'DROP TABLE employes;',
        'WITH x AS (SELECT 1) DELETE FROM employes;',
      ]) {
        await expectLater(pg.executeReadOnly('employes', sql),
            throwsA(isA<SqlError>()), reason: sql);
      }
      final r = await pg.executeReadOnly('employes', 'SELECT COUNT(*) FROM employes;');
      expect(r.rows.first.first, 12);
      // The normal engine still accepts writes afterwards (query_only reset).
      final d = await pg.execute('employes', 'DELETE FROM employes WHERE id = 1;');
      expect(d.affectedRows, 1);
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}

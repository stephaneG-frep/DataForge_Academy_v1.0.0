import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/table_models.dart';
import 'practice_data.dart';

/// Manages the local SQLite engines used by the Playground.
///
/// - On Android/iOS it uses the device sqflite implementation.
/// - Everywhere else (VM tests, desktop, web) it uses the FFI engine so that
///   the SQL playground stays fully functional and testable.
///
/// Each practice database lives in its own, independent in-memory SQLite
/// database.
class PlaygroundDatabase {
  PlaygroundDatabase._();
  static final PlaygroundDatabase instance = PlaygroundDatabase._();

  /// Lets tests inject a database factory (e.g. databaseFactoryFfiNoIsolate).
  @visibleForTesting
  DatabaseFactory? factoryOverride;

  DatabaseFactory get _factory {
    final override = factoryOverride;
    if (override != null) return override;
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return databaseFactory;
    }
    return databaseFactoryFfi;
  }

  final Map<String, Future<Database>> _openDbs = {};

  /// Seed and open a practice database by id.
  Future<Database> openDatabase(String dbId) async {
    final pending = _openDbs[dbId];
    if (pending != null) {
      final db = await pending;
      if (db.isOpen) return db;
    }
    final future = _open(dbId);
    _openDbs[dbId] = future;
    try {
      return await future;
    } catch (_) {
      _openDbs.remove(dbId);
      rethrow;
    }
  }

  Future<Database> _open(String dbId) {
    return _factory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        // Without this, sqflite hands back the same instance for every
        // ':memory:' open, so all practice databases would share one DB.
        singleInstance: false,
        onCreate: (db, version) async {
          final def = PracticeData.database(dbId);
          final batch = db.batch();
          for (final table in def.tables) {
            batch.execute(table.createSql);
            for (final row in table.rows) {
              batch.insert(
                table.name,
                {
                  for (var i = 0; i < table.columns.length; i++)
                    table.columns[i].name: row.values[i],
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
          await batch.commit(noResult: true);
        },
        onOpen: (db) => db.execute('PRAGMA foreign_keys = ON;'),
        version: 1,
      ),
    );
  }

  /// Execute a single SQL statement.
  /// Returns a [QueryResult] or throws [SqlError].
  Future<QueryResult> execute(String dbId, String sql) async {
    final stmt = singleStatement(sql);
    final db = await openDatabase(dbId);
    return _executeOne(db, stmt);
  }

  /// Execute a script of one or more statements, in order (used by the
  /// Console, so lesson examples can be run as written).
  ///
  /// Returns the result of the last statement, with [QueryResult.statementCount]
  /// set and [QueryResult.affectedRows] summed over all statements. On error,
  /// the message says which statement failed, and a transaction opened by the
  /// script and left unfinished is rolled back.
  Future<QueryResult> executeScript(String dbId, String sql) async {
    final statements = splitStatements(sql);
    if (statements.isEmpty) singleStatement(sql); // throws the "empty" error
    final db = await openDatabase(dbId);
    final total = statements.length;
    final stopwatch = Stopwatch()..start();
    var affected = 0;
    var inTransaction = false;
    QueryResult? last;
    for (var i = 0; i < total; i++) {
      final stmt = statements[i];
      try {
        last = await _executeOne(db, stmt);
      } on SqlError catch (e) {
        var msg = e.displayMessage;
        if (inTransaction) {
          try {
            await db.execute('ROLLBACK');
            msg += ' La transaction ouverte par le script a été annulée.';
          } catch (_) {}
        }
        throw SqlError(e.message,
            displayMessage: total > 1 ? 'Instruction ${i + 1}/$total : $msg' : msg);
      }
      affected += last.affectedRows;
      final kw = _firstKeyword(stmt);
      final lower = stmt.toLowerCase();
      if (kw == 'begin' || kw == 'start') inTransaction = true;
      if (kw == 'commit' || kw == 'end' ||
          (kw == 'rollback' && !RegExp(r'^\s*rollback\s+to\b').hasMatch(lower))) {
        inTransaction = false;
      }
    }
    stopwatch.stop();
    return QueryResult(
      columns: last!.columns,
      rows: last.rows,
      affectedRows: affected,
      elapsedMs: stopwatch.elapsedMilliseconds.toDouble(),
      executedSql: sql.trim(),
      returnsRows: last.returnsRows,
      statementCount: total,
    );
  }

  Future<QueryResult> _executeOne(Database db, String stmt) async {
    final stopwatch = Stopwatch()..start();
    try {
      if (_returnsRows(stmt)) {
        final rows = await db.rawQuery(stmt);
        stopwatch.stop();
        return _toResult(rows, stopwatch, stmt);
      }

      // DML / DDL: total_changes() delta = rows touched by this statement.
      final before = await _totalChanges(db);
      await db.execute(stmt);
      final after = await _totalChanges(db);
      stopwatch.stop();
      return QueryResult(
        columns: const [],
        rows: const [],
        affectedRows: after - before,
        elapsedMs: stopwatch.elapsedMilliseconds.toDouble(),
        executedSql: stmt,
      );
    } on SqlError {
      rethrow;
    } catch (e) {
      throw SqlError(e.toString());
    }
  }

  /// Execute a read-only query (SELECT / WITH / VALUES) without any
  /// possibility of modifying the database. Used to check challenges.
  Future<QueryResult> executeReadOnly(String dbId, String sql) async {
    final stmt = singleStatement(sql);
    if (!_isReadQuery(stmt)) {
      throw SqlError(
        'not a read query',
        displayMessage:
            'Ce défi attend une requête de lecture (SELECT). Les requêtes qui '
            'modifient la base (INSERT, UPDATE, DELETE, DROP…) ne sont pas acceptées ici.',
      );
    }
    final db = await openDatabase(dbId);
    final stopwatch = Stopwatch()..start();
    List<Map<String, Object?>>? rows;
    try {
      await db.transaction((txn) async {
        await txn.execute('PRAGMA query_only = ON');
        try {
          rows = await txn.rawQuery(stmt);
        } finally {
          await txn.execute('PRAGMA query_only = OFF');
        }
        // Always roll back, even for a pure read.
        throw const _Rollback();
      });
    } on _Rollback {
      // expected
    } on SqlError {
      rethrow;
    } catch (e) {
      throw SqlError(e.toString());
    }
    stopwatch.stop();
    return _toResult(rows ?? const [], stopwatch, stmt);
  }

  QueryResult _toResult(
      List<Map<String, Object?>> result, Stopwatch stopwatch, String stmt) {
    final cols = result.isNotEmpty
        ? result.first.keys.map((k) {
            final v = result.first[k];
            return QueryColumn(
                k,
                v is int
                    ? 'INTEGER'
                    : v is double
                        ? 'REAL'
                        : v is String
                            ? 'TEXT'
                            : 'NULL');
          }).toList()
        : <QueryColumn>[];
    return QueryResult(
      columns: cols,
      rows: result.map((r) => r.values.toList()).toList(),
      affectedRows: 0,
      elapsedMs: stopwatch.elapsedMilliseconds.toDouble(),
      executedSql: stmt,
      returnsRows: true,
    );
  }

  Future<int> _totalChanges(Database db) async =>
      Sqflite.firstIntValue(await db.rawQuery('SELECT total_changes()')) ?? 0;

  static String _firstKeyword(String stmt) {
    final m = RegExp(r'^[\s(]*([a-zA-Z]+)').firstMatch(stmt);
    return m?.group(1)?.toLowerCase() ?? '';
  }

  static bool _returnsRows(String stmt) => const {
        'select', 'with', 'values', 'pragma', 'explain',
      }.contains(_firstKeyword(stmt));

  static bool _isReadQuery(String stmt) {
    final kw = _firstKeyword(stmt);
    if (kw == 'select' || kw == 'values') return true;
    if (kw == 'with') {
      // A CTE can wrap INSERT/UPDATE/DELETE; query_only blocks those anyway,
      // but reject them early with a clear message.
      return !RegExp(r'\b(insert|update|delete|replace)\b',
              caseSensitive: false)
          .hasMatch(_blankStrings(stmt));
    }
    return false;
  }

  /// Replace string literal contents so keyword checks ignore them.
  static String _blankStrings(String s) =>
      s.replaceAll(RegExp(r"'(?:[^']|'')*'"), "''");

  /// Validate that [sql] contains exactly one statement and return it,
  /// with comments and the trailing semicolon removed.
  static String singleStatement(String sql) {
    final statements = splitStatements(sql);
    if (statements.isEmpty) {
      throw SqlError('empty query',
          displayMessage: 'Requête vide. Tape un SQL puis appuie sur Exécuter.');
    }
    if (statements.length > 1) {
      throw SqlError(
        'multiple statements',
        displayMessage:
            'Une seule requête à la fois : ${statements.length} instructions '
            'détectées. Exécute-les une par une.',
      );
    }
    return statements.single;
  }

  /// Split a script into statements on top-level ';', ignoring semicolons
  /// inside string literals, quoted identifiers, comments and
  /// CREATE TRIGGER ... BEGIN ... END bodies. Comments are stripped and
  /// blank statements dropped.
  static List<String> splitStatements(String script) {
    final out = <String>[];
    final buf = StringBuffer();
    var i = 0;
    final n = script.length;

    void flush() {
      final s = buf.toString().trim();
      if (s.isNotEmpty) out.add(s);
      buf.clear();
    }

    while (i < n) {
      final c = script[i];
      final next = i + 1 < n ? script[i + 1] : '';

      // -- line comment
      if (c == '-' && next == '-') {
        while (i < n && script[i] != '\n') {
          i++;
        }
        buf.write(' ');
        continue;
      }
      // /* block comment */
      if (c == '/' && next == '*') {
        final end = script.indexOf('*/', i + 2);
        i = end < 0 ? n : end + 2;
        buf.write(' ');
        continue;
      }
      // quoted string / identifier
      if (c == "'" || c == '"' || c == '`' || c == '[') {
        final close = c == '[' ? ']' : c;
        buf.write(c);
        i++;
        while (i < n) {
          final d = script[i];
          buf.write(d);
          i++;
          if (d == close) {
            if (close != ']' && i < n && script[i] == close) {
              buf.write(script[i]); // escaped quote ('' or "")
              i++;
              continue;
            }
            break;
          }
        }
        continue;
      }
      if (c == ';') {
        final current = buf.toString();
        final isTrigger = RegExp(
                r'^\s*create\s+(temp\s+|temporary\s+)?trigger\b',
                caseSensitive: false)
            .hasMatch(current);
        if (isTrigger &&
            !RegExp(r'\bend\s*$', caseSensitive: false).hasMatch(current)) {
          buf.write(c); // ';' inside the trigger body
        } else {
          flush();
        }
        i++;
        continue;
      }
      buf.write(c);
      i++;
    }
    flush();
    return out;
  }

  /// List tables + sample stats for the DB explorer.
  Future<List<Map<String, Object?>>> listTables(String dbId) async {
    final db = await openDatabase(dbId);
    final res = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name;");
    final out = <Map<String, Object?>>[];
    for (final r in res) {
      final name = r['name'] as String;
      final count = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM "$name"')) ??
          0;
      out.add({'name': name, 'count': count});
    }
    return out;
  }

  Future<List<Map<String, Object?>>> tableData(
      String dbId, String table, int limit) async {
    final db = await openDatabase(dbId);
    return db.rawQuery('SELECT * FROM "$table" LIMIT $limit;');
  }

  Future<void> closeAll() async {
    final pending = List<Future<Database>>.from(_openDbs.values);
    _openDbs.clear();
    for (final f in pending) {
      try {
        final db = await f;
        if (db.isOpen) await db.close();
      } catch (_) {}
    }
  }
}

class _Rollback implements Exception {
  const _Rollback();
}

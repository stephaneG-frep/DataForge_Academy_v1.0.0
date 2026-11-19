/// A column definition for a practice database table.
class ColumnDef {
  final String name;
  final String type;

  ColumnDef(this.name, this.type);

  @override
  String toString() => '$name $type';
}

/// A row of data (values per column) for a table.
class RowDef {
  final List<Object?> values;

  RowDef(this.values);
}

/// A full table definition used to seed playground databases.
class TableDef {
  final String name;
  final List<ColumnDef> columns;
  final List<RowDef> rows;

  TableDef(this.name, this.columns, this.rows);

  String get createSql {
    final cols = columns.map((c) => '"${c.name}" ${c.type}').join(', ');
    return 'CREATE TABLE "$name" ($cols);';
  }
}

/// One practice database (BIBLIOTHEQUE, FILMS, EMPLOYES, BOUTIQUE, ECOLE).
class PracticeDatabase {
  final String id;
  final String name;
  final String description;
  final List<TableDef> tables;

  PracticeDatabase({
    required this.id,
    required this.name,
    required this.description,
    required this.tables,
  });
}

/// A result row returned by the playground executor.
class QueryColumn {
  final String name;
  final String type;

  QueryColumn(this.name, this.type);
}

class QueryResult {
  final List<QueryColumn> columns;
  final List<List<Object?>> rows;
  final int affectedRows;
  final double elapsedMs;
  final String executedSql;

  /// True when the (last) statement was a query (SELECT, WITH, PRAGMA…),
  /// even if it returned no row.
  final bool returnsRows;

  /// Number of statements executed (> 1 for a script run from the Console).
  final int statementCount;

  QueryResult({
    required this.columns,
    required this.rows,
    required this.affectedRows,
    required this.elapsedMs,
    required this.executedSql,
    this.returnsRows = false,
    this.statementCount = 1,
  });

  int get rowCount => rows.length;

  /// Has a result table to display.
  bool get isQuery => columns.isNotEmpty;

  bool get isEmpty => rows.isEmpty && columns.isEmpty && affectedRows == 0;

  /// Text shown when there is no table to display.
  String get summary {
    final prefix = statementCount > 1 ? '$statementCount instructions exécutées. ' : '';
    if (returnsRows && rows.isEmpty) {
      return '${prefix}Aucune ligne ne correspond à la requête.';
    }
    return '${prefix}Requête exécutée avec succès — $affectedRows ligne(s) affectée(s).';
  }
}

class SqlError {
  final String message;
  final String displayMessage;

  SqlError(this.message, {String? displayMessage})
      : displayMessage = displayMessage ?? _friendly(message);

  static String _friendly(String raw) {
    var m = raw;
    if (m.contains('no such table')) {
      final name = _extract(m, 'no such table:');
      return 'Table "$name" introuvable. Vérifie le nom de la table, ou liste les tables avec : SELECT name FROM sqlite_master WHERE type = \'table\';';
    }
    if (m.contains('no such column')) {
      final name = _extract(m, 'no such column:');
      return 'Colonne "$name" introuvable. Vérifie le nom des colonnes (sensible à la casse) ou utilise PRAGMA table_info(nom_table).';
    }
    if (m.contains('near "')) {
      return 'Erreur de syntaxe SQL près de "${_extractQuote(m)}". Vérifie la fin de ta requête (point-virgule, apostrophes, parenthèses).';
    }
    if (m.contains('readonly database')) {
      return 'Cette requête tente de modifier la base, ce qui n\'est pas autorisé ici.';
    }
    if (m.contains('ambiguous column name')) {
      return 'Nom de colonne ambigu. Précise avec le nom de la table : table.colonne.';
    }
    if (m.contains('syntax error')) {
      return 'Erreur de syntaxe SQL. Vérifie les mots-clés et la structure de la requête.';
    }
    return _capitalize(m);
  }

  static String _extract(String msg, String token) {
    final idx = msg.indexOf(token);
    if (idx < 0) return '';
    var rest = msg.substring(idx + token.length).trim();
    final space = rest.indexOf(' ');
    if (space > 0) rest = rest.substring(0, space);
    return rest.replaceAll('"', '').replaceAll("'", '');
  }

  static String _extractQuote(String msg) {
    final idx = msg.indexOf('"');
    if (idx < 0) return '';
    var rest = msg.substring(idx + 1);
    final end = rest.indexOf('"');
    if (end > 0) rest = rest.substring(0, end);
    return rest;
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

import 'package:flutter/material.dart';

import '../data/reference_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

class CheatsheetsScreen extends StatelessWidget {
  const CheatsheetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cats = CheatSheetData.categories;
    return Scaffold(
      appBar: const AppHeader(title: 'Cheatsheets', subtitle: 'Les commandes SQL essentielles'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final entry in cats.entries)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: const Icon(Icons.fact_check, color: AppColors.terminalGreen),
                title: Text(entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                children: [
                  for (final item in entry.value)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 150,
                            child: Text(item[0],
                                style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: AppColors.terminalGreen,
                                    fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(item[1],
                                style: const TextStyle(fontSize: 12.5, height: 1.3)),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ComparatorScreen extends StatelessWidget {
  const ComparatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Comparateur SGBD', subtitle: 'Même requête, plusieurs SGBD'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Flavor descriptions
          const SectionHeading('Les SGBD', icon: Icons.grid_view),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in ComparatorData.dbFlavors.entries)
                Tooltip(
                  message: e.value,
                  child: Chip(label: Text(e.key)),
                ),
            ],
          ),
          const SizedBox(height: 8),

          _section(context, 'Limiter les résultats',
              ComparatorData.limitQuery, ComparatorData.limitByDb),
          _section(context, 'Auto-incrément',
              ComparatorData.autoIncrementQuery, ComparatorData.autoIncrementByDb),
          _section(context, 'Concaténation',
              ComparatorData.concatQuery, ComparatorData.concatByDb),
          _section(context, 'Casse des chaînes',
              ComparatorData.stringsQuery, ComparatorData.stringsByDb),

          Card(
            margin: const EdgeInsets.only(top: 12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Le point important',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(ComparatorData.concatExplanation,
                      style: const TextStyle(fontSize: 13.5, height: 1.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, String question,
      Map<String, String> byDb) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 4),
            Text(question, style: const TextStyle(fontSize: 12.5, color: AppColors.terminalBlue)),
            const SizedBox(height: 12),
            for (final e in byDb.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(e.key,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    Expanded(
                      child: Text(e.value,
                          style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: dark ? AppColors.darkText : AppColors.lightText)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProgrammingScreen extends StatelessWidget {
  const ProgrammingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: 'SQL + Programmation',
          subtitle: 'Connecter une base dans ton langage'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final lang in _languages)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: Icon(lang.icon, color: AppColors.terminalGreen),
                title: Text(lang.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TerminalCode(lang.code, title: lang.file),
                        if (lang.note.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(lang.note,
                                style: const TextStyle(fontSize: 12.5, height: 1.4)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SectionHeading('Rappels de sécurité', icon: Icons.shield),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bullet('Toujours utiliser des requêtes préparées (anti-injection).'),
                  _bullet('Ne jamais stocker de mots de passe en clair (hacher + saler).'),
                  _bullet('Valider et assainir toutes les entrées utilisateur.'),
                  _bullet('Appliquer le principe du moindre privilège.'),
                  _bullet('En production, séparer l\'app du backend via une API REST.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle, size: 16, color: AppColors.terminalGreen),
            const SizedBox(width: 8),
            Expanded(child: Text(s, style: const TextStyle(fontSize: 13, height: 1.4))),
          ],
        ),
      );

  static const _languages = [
    _Lang('Flutter / Dart', 'lib/database.dart', Icons.smartphone,
        'final db = await openDatabase(\'app.db\');\n'
        'final result = await db.rawQuery(\n'
        '  \'SELECT * FROM products WHERE price < ?\', [50]);',
        'sqflite pour mobile ; drift est un ORM moderne pour Dart.'),
    _Lang('Python', 'app.py', Icons.code,
        'import psycopg2\n'
        'conn = psycopg2.connect(dbname="mabase", user="u", password="p")\n'
        'cur = conn.cursor()\n'
        'cur.execute("SELECT * FROM products WHERE price < %s", (50,))\n'
        'rows = cur.fetchall()',
        'psycopg2 (PostgreSQL), pymysql (MySQL), sqlite3 (SQLite).'),
    _Lang('JavaScript / Node.js', 'app.js', Icons.code,
        'const { Pool } = require(\'pg\');\n'
        'const pool = new Pool({ host: \'localhost\', database: \'mabase\' });\n'
        'const res = await pool.query(\n'
        "  'SELECT * FROM products WHERE price < \$1', [50]);",
        'pg (PostgreSQL), mysql2 (MySQL), better-sqlite3 (SQLite).'),
    _Lang('PHP', 'index.php', Icons.language,
        '\$pdo = new PDO("mysql:host=localhost;dbname=mabase", "u", "p");\n'
        '\$req = \$pdo->prepare("SELECT * FROM products WHERE price < ?");\n'
        '\$req->execute([50]);\n'
        '\$rows = \$req->fetchAll();',
        'PDO supporte plusieurs SGBD : mysql, pgsql, sqlite, sqlsrv.'),
    _Lang('Java', 'Main.java', Icons.extension,
        'try (Connection c = DriverManager.getConnection(\n'
        '    "jdbc:postgresql://localhost/mabase", "u", "p")) {\n'
        '  PreparedStatement ps = c.prepareStatement(\n'
        '    "SELECT * FROM products WHERE price < ?");\n'
        '  ps.setInt(1, 50);\n'
        '  ResultSet rs = ps.executeQuery();\n'
        '}',
        'JDBC est le pilote standard Java ; Hibernate est un ORM.'),
    _Lang('C#', 'Program.cs', Icons.developer_mode,
        'using var conn = new NpgsqlConnection(\n'
        '    "Host=localhost;Database=mabase;Username=u;Password=p");\n'
        'await conn.OpenAsync();\n'
        'using var cmd = new NpgsqlCommand(\n'
        '    "SELECT * FROM products WHERE price < @p", conn);\n'
        'cmd.Parameters.AddWithValue("@p", 50);',
        'Npgsql (PostgreSQL), MySqlConnector, Microsoft.Data.SqlClient ; EF Core ORM.'),
  ];
}

class _Lang {
  final String name;
  final String file;
  final IconData icon;
  final String code;
  final String note;
  const _Lang(this.name, this.file, this.icon, this.code, this.note);
}

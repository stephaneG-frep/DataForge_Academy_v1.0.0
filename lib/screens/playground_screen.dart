import 'package:flutter/material.dart';

import '../database/playground_database.dart';
import '../database/practice_data.dart';
import '../models/table_models.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'main_shell.dart';
import 'playground_editor_screen.dart';

class PlaygroundScreen extends StatefulWidget {
  final String? initialSql;
  final String? initialDb;
  const PlaygroundScreen({super.key, this.initialSql, this.initialDb});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  final TextEditingController _sql = TextEditingController();
  String _dbId = 'boutique';
  bool _running = false;

  QueryResult? _result;
  SqlError? _error;
  bool _showExplorer = false;

  List<Map<String, Object?>> _tables = [];
  Map<String, List<Map<String, Object?>>> _tableData = {};

  ProgressService get _prog => ProgressService.instance;

  @override
  void initState() {
    super.initState();
    _dbId = widget.initialDb ?? _prog.playgroundPrefs['lastDb'] ?? 'boutique';
    if (widget.initialSql != null) _sql.text = widget.initialSql!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExplorer();
      _setLastDb();
    });
  }

  void _setLastDb() {
    _prog.setPlaygroundPref('lastDb', _dbId);
  }

  Future<void> _loadExplorer() async {
    try {
      final tables = await PlaygroundDatabase.instance.listTables(_dbId);
      final data = <String, List<Map<String, Object?>>>{};
      for (final t in tables) {
        final rows = await PlaygroundDatabase.instance.tableData(
            _dbId, t['name'] as String, 5);
        data[t['name'] as String] = rows;
        t['rows'] = rows;
      }
      if (mounted) {
        setState(() {
          _tables = tables;
          _tableData = data;
        });
      }
    } catch (_) {}
  }

  static const _examples = [
    'SELECT * FROM products;',
    'SELECT name, price FROM products WHERE price < 50 ORDER BY price DESC;',
    'SELECT category_id, COUNT(*) AS nb FROM products GROUP BY category_id;',
    'SELECT p.name, c.nom FROM products p JOIN categories c ON p.category_id = c.id;',
    "INSERT INTO products (name, price, category_id, stock) VALUES ('Mousse', 19.99, 3, 50);",
    "UPDATE products SET stock = 0 WHERE id = 1;",
    'PRAGMA table_info(products);',
  ];

  Future<void> _run(String sql, {bool record = true, String? dbId}) async {
    final db = dbId ?? _dbId;
    setState(() {
      _running = true;
      _error = null;
      _result = null;
    });
    if (record) {
      _prog.addHistory(sql);
      _prog.incrementQueries();
      _setLastDb();
    }
    try {
      final r = await PlaygroundDatabase.instance.executeScript(db, sql);
      if (mounted) {
        setState(() {
          _result = r;
          _error = null;
        });
      }
    } catch (e) {
      final err = e is SqlError ? e : SqlError(e.toString());
      if (mounted) {
        setState(() {
          _error = err;
          _result = null;
        });
      }
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = PracticeData.meta(_dbId);
    return Scaffold(
      appBar: AppHeader(
        title: 'Playground',
        subtitle: 'SQLite local · base "${meta['name']}"',
        actions: [
          IconButton(
            icon: const Icon(Icons.table_view),
            tooltip: 'Explorer la base',
            onPressed: () => setState(() => _showExplorer = !_showExplorer),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historique',
            onPressed: () => _openHistory(context),
          ),
          IconButton(
            icon: const Icon(Icons.star_border),
            tooltip: 'Favoris',
            onPressed: () => _openFavorites(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _dbSelector(context),
          Expanded(
            child: _showExplorer
                ? _explorer(context)
                : _terminalArea(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _running ? null : () => _run(_sql.text),
        backgroundColor: AppColors.terminalGreen,
        foregroundColor: Colors.black,
        icon: _running
            ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.play_arrow),
        label: Text(_running ? '...' : 'Exécuter'),
      ),
    );
  }

  Widget _dbSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final id in PracticeData.ids)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(PracticeData.meta(id)['name']!),
                  selected: _dbId == id,
                  onSelected: (_) {
                    setState(() => _dbId = id);
                    _loadExplorer();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _terminalArea(BuildContext context) {
    return Column(
      children: [
        _editor(context),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_error != null) _errorCard(context),
              if (_result != null) _resultView(context),
              if (_error == null && _result == null) _helpCard(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _editor(BuildContext context) {
    final fontSize = SettingsService.instance.playgroundFontSize;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF16233B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.terminal, size: 14, color: AppColors.terminalGreen),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text('dataforge@sql:~\$',
                      style: TextStyle(color: AppColors.terminalGreen, fontSize: 12, fontFamily: 'monospace')),
                ),
                IconButton(
                  icon: const Icon(Icons.font_download, size: 16, color: AppColors.terminalAmber),
                  tooltip: 'Taille du texte',
                  onPressed: _adjustFont,
                ),
                IconButton(
                  icon: const Icon(Icons.cleaning_services, size: 16, color: AppColors.terminalRed),
                  tooltip: 'Effacer l\'éditeur',
                  onPressed: () => _sql.clear(),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 16, color: Colors.white),
                  onSelected: (v) {
                    if (v == 'examples') _pickExample(context);
                    if (v == 'reset') _resetDb(context);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'examples', child: Text('Exemples')),
                    PopupMenuItem(value: 'reset', child: Text('Réinitialiser la base')),
                  ],
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 100, maxHeight: 180),
            child: TextField(
              controller: _sql,
              maxLines: null,
              minLines: 4,
              keyboardType: TextInputType.multiline,
              style: TextStyle(
                  color: const Color(0xFFE6EDF5),
                  fontFamily: 'monospace',
                  fontSize: fontSize),
              decoration: const InputDecoration(
                hintText: 'Saisis ton SQL ici...\nSELECT * FROM products;',
                hintStyle: TextStyle(color: Color(0xFF5A6A82), fontFamily: 'monospace'),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _adjustFont() async {
    final cur = SettingsService.instance.playgroundFontSize;
    final sizes = [11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 18.0];
    final next = sizes[(sizes.indexOf(cur) + 1) % sizes.length];
    await SettingsService.instance.setPlaygroundFontSize(next);
    setState(() {});
  }

  void _pickExample(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Exemples de requêtes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            for (final e in _examples)
              ListTile(
                leading: const Icon(Icons.terminal, size: 18, color: AppColors.terminalGreen),
                title: Text(e,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                onTap: () {
                  _sql.text = e;
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetDb(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Réinitialiser la base'),
        content: Text('Réinitialiser la base "${PracticeData.meta(_dbId)['name']}" à son état d\'origine ? Tu perdras tes modifications.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Réinitialiser')),
        ],
      ),
    );
    if (ok == true) {
      await PlaygroundDatabase.instance.closeAll();
      await _loadExplorer();
      if (!context.mounted) return;
      setState(() {
        _result = null;
        _error = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Base réinitialisée'), behavior: SnackBarBehavior.floating));
    }
  }

  Widget _errorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.terminalRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.terminalRed.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.terminalRed),
              const SizedBox(width: 6),
              const Text('Erreur SQL',
                  style: TextStyle(color: AppColors.terminalRed, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(_error!.displayMessage,
              style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  Widget _helpCard(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bienvenue dans ton laboratoire SQL !',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Essaie par exemple :',
                style: TextStyle(color: dark ? AppColors.darkMuted : AppColors.lightMuted)),
            const SizedBox(height: 8),
            for (final e in _examples.take(4))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: InkWell(
                  onTap: () => _run(e),
                  child: Text(e,
                      style: const TextStyle(
                          color: AppColors.terminalGreen,
                          fontFamily: 'monospace',
                          fontSize: 13)),
                ),
              ),
            const SizedBox(height: 8),
            Text('Appuie sur Exécuter pour lancer ta requête.',
                style: TextStyle(fontSize: 13, color: AppColors.terminalBlue)),
          ],
        ),
      ),
    );
  }

  Widget _resultView(BuildContext context) {
    final r = _result!;
    if (r.isQuery && r.columns.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Pill('${r.rowCount} résultat(s)',
                  color: AppColors.terminalGreen, icon: Icons.table_chart),
              const SizedBox(width: 6),
              Pill('${r.elapsedMs} ms', color: AppColors.terminalBlue, icon: Icons.timer),
              if (r.statementCount > 1) ...[
                const SizedBox(width: 6),
                Pill('${r.statementCount} instructions', color: AppColors.terminalAmber, icon: Icons.playlist_play),
              ],
            ],
          ),
          const SizedBox(height: 10),
          _resultTable(context, r),
        ],
      );
    }
    // DML
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.terminalGreen),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                r.summary,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultTable(BuildContext context, QueryResult r) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dark ? AppColors.darkBorder : AppColors.lightBorder),
        color: dark ? AppColors.darkCard : Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(dark
                ? AppColors.darkCardAlt
                : const Color(0xFFF1F5F9)),
            columnSpacing: 20,
            horizontalMargin: 14,
            columns: [
              for (final c in r.columns)
                DataColumn(
                  label: Text(c.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                ),
            ],
            rows: [
              for (final row in r.rows)
                DataRow(
                  cells: [
                    for (var i = 0; i < row.length; i++)
                      DataCell(
                        Text(
                          row[i] == null ? 'NULL' : row[i].toString(),
                          style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: row[i] == null
                                  ? AppColors.terminalRed
                                  : dark
                                      ? AppColors.darkText
                                      : AppColors.lightText),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _explorer(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Icon(Icons.storage, color: AppColors.terminalGreen),
            const SizedBox(width: 8),
            Text('Base "${PracticeData.meta(_dbId)['name']}"',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 4),
        Text(PracticeData.meta(_dbId)['desc'] ?? '',
            style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 12),
        for (final t in _tables)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              leading: const Icon(Icons.table_view, color: AppColors.terminalBlue),
              title: Text(t['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${t['count']} lignes'),
              children: [
                if ((_tableData[t['name']] ?? []).isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _miniTable(context, t['name'] as String),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Table vide'),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Interroger'),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PlaygroundEditorScreen(
                                    initialSql:
                                        'SELECT * FROM ${t['name']};',
                                    dbId: _dbId)));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _miniTable(BuildContext context, String tableName) {
    final rows = _tableData[tableName] ?? [];
    if (rows.isEmpty) return const Text('Pas de données');
    final cols = rows.first.keys.toList();
    return DataTable(
      columnSpacing: 16,
      headingRowHeight: 30,
      columns: [
        for (final c in cols)
          DataColumn(
              label: Text(c,
                  style:
                      const TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
      ],
      rows: [
        for (final row in rows)
          DataRow(
            cells: [
              for (final c in cols)
                DataCell(Text(row[c]?.toString() ?? 'NULL',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
            ],
          ),
      ],
    );
  }

  Future<void> _openHistory(BuildContext context) async {
    final prog = _prog;
    final history = List<Map<String, String>>.from(prog.history);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('Historique SQL',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        await prog.clearHistory();
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Effacer'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: history.isEmpty
                    ? const Center(
                        child: Text('Aucune requête récente',
                            style: TextStyle(color: AppColors.lightMuted)))
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (_, i) {
                          final h = history[i];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.history, size: 18, color: AppColors.terminalBlue),
                            title: Text(h['sql']!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                            subtitle: Text(h['date'] ?? '',
                                style: const TextStyle(fontSize: 11)),
                            onTap: () {
                              setState(() => _sql.text = h['sql']!);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openFavorites(BuildContext context) async {
    final favs = _prog.favorites;
    if (favs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Aucun favori. Marque des leçons avec l\'étoile ⭐'),
          behavior: SnackBarBehavior.floating));
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Favoris',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            for (final f in favs)
              ListTile(
                leading: const Icon(Icons.star, color: AppColors.terminalAmber),
                title: Text(f, style: const TextStyle(fontSize: 14)),
              ),
          ],
        ),
      ),
    );
  }
}

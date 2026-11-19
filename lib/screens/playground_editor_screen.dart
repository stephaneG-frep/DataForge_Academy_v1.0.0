import 'package:flutter/material.dart';

import '../database/playground_database.dart';
import '../database/practice_data.dart';
import '../models/table_models.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';

/// A focused full-screen SQL editor used to run one query against a
/// chosen practice database. Reused by the explorer and the challenges.
class PlaygroundEditorScreen extends StatefulWidget {
  final String? initialSql;
  final String dbId;
  const PlaygroundEditorScreen({super.key, this.initialSql, this.dbId = 'boutique'});

  @override
  State<PlaygroundEditorScreen> createState() => _PlaygroundEditorScreenState();
}

class _PlaygroundEditorScreenState extends State<PlaygroundEditorScreen> {
  late final TextEditingController _sql;
  bool _running = false;
  QueryResult? _result;
  SqlError? _error;

  @override
  void initState() {
    super.initState();
    _sql = TextEditingController(text: widget.initialSql ?? '');
  }

  Future<void> _run() async {
    setState(() {
      _running = true;
      _error = null;
      _result = null;
    });
    ProgressService.instance.addHistory(_sql.text);
    ProgressService.instance.incrementQueries();
    try {
      final r = await PlaygroundDatabase.instance.executeScript(widget.dbId, _sql.text);
      if (mounted) {
        setState(() {
          _result = r;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is SqlError ? e : SqlError(e.toString());
        });
      }
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Console SQL', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            Text('Base : ${PracticeData.meta(widget.dbId)['name']}',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers_clear),
            tooltip: 'Effacer le résultat',
            onPressed: () => setState(() {
              _result = null;
              _error = null;
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _editor(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _running ? null : _run,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(_running ? 'Exécution...' : 'Exécuter'),
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.terminalGreen,
                            foregroundColor: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: _sql.clear,
                      icon: const Icon(Icons.cleaning_services, size: 18),
                      tooltip: 'Effacer',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_error != null) _errorCard(),
                if (_result != null) _resultView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editor() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF16233B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Text('dataforge@sql:~\$',
                style: TextStyle(color: AppColors.terminalGreen, fontFamily: 'monospace', fontSize: 12)),
          ),
          TextField(
            controller: _sql,
            maxLines: null,
            minLines: 6,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(color: Color(0xFFE6EDF5), fontFamily: 'monospace', fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Écris ta requête SQL...',
              hintStyle: TextStyle(color: Color(0xFF5A6A82)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard() {
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
          const Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.terminalRed),
              SizedBox(width: 6),
              Text('Erreur SQL',
                  style: TextStyle(color: AppColors.terminalRed, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(_error!.displayMessage, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }

  Widget _resultView() {
    final r = _result!;
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (r.isQuery && r.columns.isNotEmpty) {
      final table = Container(
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
              columnSpacing: 20,
              columns: [
                for (final c in r.columns)
                  DataColumn(label: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700))),
              ],
              rows: [
                for (final row in r.rows)
                  DataRow(cells: [
                    for (final v in row)
                      DataCell(Text(v?.toString() ?? 'NULL',
                          style: const TextStyle(fontFamily: 'monospace'))),
                  ]),
              ],
            ),
          ),
        ),
      );
      if (r.statementCount == 1) return table;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${r.statementCount} instructions exécutées — résultat de la dernière :',
              style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 8),
          table,
        ],
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(r.summary, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

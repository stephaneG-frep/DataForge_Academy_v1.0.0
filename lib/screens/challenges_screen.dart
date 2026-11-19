import 'package:flutter/material.dart';

import '../data/challenge_data.dart';
import '../models/challenge_models.dart';
import '../database/playground_database.dart';
import '../models/table_models.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../utils/sql_util.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prog = ProgressService.instance;
    final challenges = ChallengeData.all;
    final resolved = prog.resolvedChallenges;
    final sorted = List<Challenge>.from(challenges)
      ..sort((a, b) => a.level.compareTo(b.level));

    return Scaffold(
      appBar: const AppHeader(title: 'Challenges', subtitle: 'Écris du SQL, le terminal vérifie'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: challenges.isEmpty ? 0 : resolved.length / challenges.length,
                    minHeight: 8,
                    color: AppColors.terminalGreen,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${resolved.length}/${challenges.length}',
                  style: const TextStyle(color: AppColors.terminalGreen, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          for (final c in sorted)
            _challengeCard(context, c, resolved),
        ],
      ),
    );
  }

  Widget _challengeCard(BuildContext context, Challenge c, Set<String> resolved) {
    final done = resolved.contains(c.id);
    final color = AppColors.levelColors[c.level - 1];
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ChallengeViewScreen(challenge: c))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  done ? Icons.emoji_events : Icons.flag,
                  color: done ? AppColors.terminalAmber : color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(c.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Pill('Difficulté ${c.level}', color: color),
                        if (done)
                          const Pill('Réussi', color: AppColors.terminalGreen, icon: Icons.check)
                        else
                          Pill('+${c.xp} XP', color: AppColors.terminalBlue, icon: Icons.bolt),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class ChallengeViewScreen extends StatefulWidget {
  final Challenge challenge;
  const ChallengeViewScreen({super.key, required this.challenge});

  @override
  State<ChallengeViewScreen> createState() => _ChallengeViewScreenState();
}

class _ChallengeViewScreenState extends State<ChallengeViewScreen> {
  final TextEditingController _sql = TextEditingController();
  bool _showHint = false;
  bool _showSolution = false;
  bool _checking = false;
  _CheckOutcome? _outcome;

  @override
  void dispose() {
    _sql.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = AppColors.levelColors[c.level - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text(c.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Pill('Niveau ${c.level}', color: color),
              const SizedBox(width: 6),
              const Pill('Total datasets', color: AppColors.terminalBlue),
              const Spacer(),
              Pill('+${c.xp} XP', color: AppColors.terminalGreen, icon: Icons.bolt),
            ],
          ),
          const SizedBox(height: 12),
          Text('Mission',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: dark ? AppColors.darkText : AppColors.lightText)),
          const SizedBox(height: 6),
          Text(c.description,
              style: const TextStyle(fontSize: 15, height: 1.5)),
          const SizedBox(height: 16),

          // SQL editor
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF16233B),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: const Text('dataforge@challenge:~\$',
                      style: TextStyle(color: AppColors.terminalGreen, fontFamily: 'monospace', fontSize: 12)),
                ),
                TextField(
                  controller: _sql,
                  maxLines: null,
                  minLines: 5,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(color: Color(0xFFE6EDF5), fontFamily: 'monospace', fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Ta requête SQL...',
                    hintStyle: TextStyle(color: Color(0xFF5A6A82)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _checking ? null : _check,
                  icon: _checking
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.verified),
                  label: Text(_checking ? 'Vérification...' : 'Vérifier ma réponse'),
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.terminalGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),

          if (_outcome != null) ...[
            const SizedBox(height: 12),
            _outcomeCard(context),
          ],

          const SizedBox(height: 8),
          if (!_showHint)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Afficher un indice'),
                onPressed: () => setState(() => _showHint = true),
              ),
            ),
          if (_showHint)
            _infoBlock(context, 'Indice', c.hint, AppColors.terminalAmber),
          if (_showSolution)
            _infoBlock(context, 'Solution', c.solution,
                AppColors.terminalGreen, mono: true),
        ],
      ),
    );
  }

  Future<void> _check() async {
    if (_sql.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Écris d\'abord ta requête SQL'),
          behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() {
      _checking = true;
      _outcome = null;
    });
    final c = widget.challenge;
    final engine = PlaygroundDatabase.instance;
    try {
      // Both queries run read-only and are rolled back: a destructive query
      // can neither pass the check nor damage the practice database.
      final user = await engine.executeReadOnly(c.databaseId, _sql.text);
      final sol = await engine.executeReadOnly(c.databaseId, c.solution);

      final userRows = user.rows.map(SqlUtil.rowKeys).toList();
      final solRows = sol.rows.map(SqlUtil.rowKeys).toList();
      final sameRows = SqlUtil.datasetsEqual(solRows, userRows);

      var wrongOrder = false;
      final orderCol = c.orderByColumn;
      if (sameRows && orderCol != null) {
        final idx = user.columns.indexWhere(
            (col) => col.name.toLowerCase() == orderCol.toLowerCase());
        wrongOrder = idx >= 0
            ? !SqlUtil.isSortedOn(user.rows, idx,
                descending: c.orderDescending)
            : !SqlUtil.datasetsEqualOrdered(solRows, userRows);
      }
      final match = sameRows && !wrongOrder;

      final outcome = _CheckOutcome(
        passed: match,
        wrongOrder: wrongOrder,
        rowsReturned: user.rowCount,
        expectedRows: sol.rowCount,
      );
      final prog = ProgressService.instance;
      if (match && !prog.resolvedChallenges.contains(c.id)) {
        await prog.resolveChallenge(c.id);
        await prog.addXp(c.xp);
        outcome.earnedXp = c.xp;
      }
      if (match) _showSolution = true;
      if (mounted) setState(() => _outcome = outcome);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _outcome = _CheckOutcome(
          passed: false,
          error: e is SqlError ? e.displayMessage : e.toString(),
          rowsReturned: 0,
          expectedRows: null,
        );
      });
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Widget _outcomeCard(BuildContext context) {
    final o = _outcome!;
    final passed = o.passed;
    final color = passed ? AppColors.terminalGreen : AppColors.terminalRed;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(passed ? Icons.emoji_events : Icons.close,
                  color: color),
              const SizedBox(width: 6),
              Text(
                passed ? 'Réussi ! Bravo 🎉' : 'Pas encore, essaie encore',
                style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            o.error ??
                (o.wrongOrder
                    ? 'Tu as les bonnes lignes, mais pas dans l\'ordre demandé. '
                        'Relis la consigne et vérifie ton ORDER BY.'
                    : 'Ta requête a renvoyé ${o.rowsReturned} ligne(s) '
                        '(attendu : ${o.expectedRows ?? o.rowsReturned}).'),
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          if (passed && o.earnedXp != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('+${o.earnedXp} XP gagnés !',
                  style: const TextStyle(color: AppColors.terminalGreen, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  Widget _infoBlock(
      BuildContext context, String title, String body, Color color,
      {bool mono = false}) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 4),
          Text(body,
              style: mono
                  ? const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.4)
                  : const TextStyle(fontSize: 13, height: 1.4)),
          if (mono) ...[
            const SizedBox(height: 6),
            Text('Explication : ${widget.challenge.explanation}',
                style: const TextStyle(fontSize: 12.5, height: 1.4)),
          ],
        ],
      ),
    );
  }
}

class _CheckOutcome {
  final bool passed;
  final bool wrongOrder;
  final String? error;
  final int rowsReturned;
  final int? expectedRows;
  int? earnedXp;
  _CheckOutcome({
    required this.passed,
    this.wrongOrder = false,
    this.error,
    required this.rowsReturned,
    this.expectedRows,
  });
}

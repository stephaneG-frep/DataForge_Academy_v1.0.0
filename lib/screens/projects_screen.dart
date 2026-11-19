import 'package:flutter/material.dart';

import '../data/project_data.dart';
import '../models/project_models.dart';
import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

Color _projectColor(String name) {
  switch (name) {
    case 'cyan':
      return AppColors.brandCyan;
    case 'orange':
      return AppColors.terminalAmber;
    case 'blue':
      return AppColors.terminalBlue;
    case 'green':
      return AppColors.terminalGreen;
    case 'purple':
      return AppColors.terminalPurple;
    case 'red':
      return AppColors.terminalRed;
    default:
      return AppColors.brandNavy;
  }
}

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prog = ProgressService.instance;
    return Scaffold(
      appBar: const AppHeader(title: 'Projets', subtitle: 'Des mises en pratique complètes'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final p in ProjectData.all)
            _projectCard(context, p, prog),
        ],
      ),
    );
  }

  Widget _projectCard(BuildContext context, Project p, ProgressService prog) {
    final color = _projectColor(p.colorName);
    final done = prog.completedProjects.contains(p.id);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ProjectViewScreen(project: p))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(p.icon,
                    color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(p.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Pill('${p.tasks.length} exercices', color: color),
                        Pill('+${p.estimatedXp} XP', color: AppColors.terminalGreen, icon: Icons.bolt),
                        if (done)
                          const Pill('Terminé', color: AppColors.terminalGreen, icon: Icons.check),
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

class ProjectViewScreen extends StatefulWidget {
  final Project project;
  const ProjectViewScreen({super.key, required this.project});

  @override
  State<ProjectViewScreen> createState() => _ProjectViewScreenState();
}

class _ProjectViewScreenState extends State<ProjectViewScreen> {
  final Set<String> _revealed = {};
  ProgressService get _prog => ProgressService.instance;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final color = _projectColor(p.colorName);
    final done = _prog.completedProjects.contains(p.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(p.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(p.icon,
                    color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('+${p.estimatedXp} XP estimés',
                        style: const TextStyle(fontSize: 12, color: AppColors.terminalGreen)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cahier des charges
          const SectionHeading('Cahier des charges', icon: Icons.description),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(p.spec, style: const TextStyle(fontSize: 14, height: 1.5)),
            ),
          ),

          // Tables
          const SectionHeading('Tables & schéma', icon: Icons.table_chart),
          for (final t in p.tables)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                leading: const Icon(Icons.table_view, color: AppColors.terminalBlue),
                title: Text(t.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text(t.description, style: const TextStyle(fontSize: 12)),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: TerminalCode(t.createSql, title: t.name),
                  ),
                ],
              ),
            ),

          // Relations
          const SectionHeading('Relations', icon: Icons.account_tree),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(p.relations, style: const TextStyle(fontSize: 13.5, height: 1.5)),
            ),
          ),

          // Données
          const SectionHeading('Données', icon: Icons.storage),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(p.sampleData, style: const TextStyle(fontSize: 13.5, height: 1.5)),
            ),
          ),

          // Exercices
          const SectionHeading('Exercices & solutions', icon: Icons.fitness_center),
          for (var i = 0; i < p.tasks.length; i++)
            _taskCard(context, i, p.tasks[i]),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                // Re-read the state at tap time: `done` was captured at build time.
                final already = _prog.completedProjects.contains(p.id);
                if (!already) {
                  await _prog.completeProject(p.id);
                  await _prog.addXp(p.estimatedXp);
                }
                if (!context.mounted) return;
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        already ? 'Projet déjà marqué comme terminé' : 'Projet terminé ! +${p.estimatedXp} XP'),
                    behavior: SnackBarBehavior.floating));
              },
              icon: Icon(done ? Icons.check_circle : Icons.done_all),
              label: Text(done ? 'Projet terminé' : 'Marquer comme terminé'),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.terminalGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(BuildContext context, int i, ProjectTask task) {
    final color = task.difficulty == 'Facile'
        ? AppColors.terminalGreen
        : task.difficulty == 'Moyen'
            ? AppColors.terminalBlue
            : task.difficulty == 'Expert'
                ? AppColors.terminalRed
                : AppColors.terminalAmber;
    final revealed = _revealed.contains(task.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Pill('Exercice ${i + 1}', color: color),
                const SizedBox(width: 6),
                Pill(task.difficulty, color: AppColors.terminalPurple),
                const Spacer(),
                Text('+${task.difficulty == 'Facile' ? 20 : task.difficulty == 'Moyen' ? 30 : task.difficulty == 'Expert' ? 50 : 40} XP',
                    style: const TextStyle(fontSize: 11, color: AppColors.terminalGreen)),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            Text(task.description,
                style: const TextStyle(fontSize: 13.5, height: 1.4)),
            const SizedBox(height: 8),
            if (revealed) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.terminalGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Solution SQL :',
                        style: TextStyle(
                            color: AppColors.terminalGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(task.solutionSql,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5)),
                    const SizedBox(height: 6),
                    Text(task.explanation,
                        style: const TextStyle(fontSize: 12.5, height: 1.4)),
                  ],
                ),
              ),
            ] else
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() => _revealed.add(task.id)),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Voir la solution'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

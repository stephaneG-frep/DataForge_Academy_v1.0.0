import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import '../theme/app_colors.dart';
import 'main_shell.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  ProgressService get _prog => ProgressService.instance;

  @override
  Widget build(BuildContext context) {
    final notes = _prog.notes;
    return Scaffold(
      appBar: const AppHeader(title: 'Notes personnelles', subtitle: 'Tes notes liées aux leçons'),
      body: notes.isEmpty
          ? const Center(
              child: Text('Aucune note. Ajoute une note depuis une leçon.',
                  style: TextStyle(color: AppColors.lightMuted)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final n in notes)
                  Dismissible(
                    key: ValueKey(n['id']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: AppColors.terminalRed,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      _prog.deleteNote(n['id']!);
                      setState(() {});
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(Icons.note_alt_outlined, color: AppColors.terminalAmber),
                        title: Text(n['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n['body'] ?? '',
                                maxLines: 4, overflow: TextOverflow.ellipsis),
                            Text(n['date'] ?? '',
                                style: const TextStyle(fontSize: 11, color: AppColors.lightMuted)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

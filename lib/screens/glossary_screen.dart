import 'package:flutter/material.dart';

import '../data/reference_data.dart';
import '../theme/app_colors.dart';
import 'main_shell.dart';

class GlossaryScreen extends StatelessWidget {
  const GlossaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = GlossaryData.entries.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
    return Scaffold(
      appBar: AppHeader(title: 'Glossaire', subtitle: 'Les termes clés du SQL et des bases'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final e in entries)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                leading: const Icon(Icons.bookmark_add_outlined, color: AppColors.terminalGreen),
                title: Text(e.key,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(e.value,
                        style: const TextStyle(fontSize: 13.5, height: 1.5)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

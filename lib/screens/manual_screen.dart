import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'main_shell.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Mode d\'emploi', subtitle: 'Tout comprendre de l\'application'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final s in _sections)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: Icon(s.icon, color: AppColors.terminalGreen),
                title: Text(s.title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final p in s.points)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('•  ', style: TextStyle(fontWeight: FontWeight.w800)),
                                Expanded(
                                  child: Text(p,
                                      style: const TextStyle(fontSize: 13.5, height: 1.5)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          const Text('Astuce : explore librement, rien ne bloque. Gagne des XP en terminant leçons, défis et projets.',
              style: TextStyle(fontSize: 13, color: AppColors.terminalBlue)),
        ],
      ),
    );
  }

  static const _sections = [
    _Sec('Cours', Icons.menu_book, [
      'L\'onglet Apprendre liste tous les parcours (SQL, SQLite, PostgreSQL, ...).',
      'Chaque parcours est découpé en 6 niveaux (Débutant → Database Engineer).',
      'Une leçon contient : objectif, cours, exemples SQL avec explications, erreurs fréquentes, exercices avec correction et un mini-quiz.',
      'Termine une leçon pour gagner des XP. Avance librement, aucun blocage.',
    ]),
    _Sec('Playground', Icons.terminal, [
      'Le Playground est un vrai laboratoire SQLite local, sans connexion internet.',
      'Choisis une base d\'entraînement (Boutique, Bibliothèque, Films, Employés, École).',
      'Écris du SQL puis appuie sur Exécuter pour voir les colonnes, lignes et le nombre de résultats.',
      'L\'icône tableau ouvre l\'explorateur de tables. L\'historique et les favoris sont dans les menus.',
      'Chaque exécution compte pour tes stats et tes badges.',
    ]),
    _Sec('Challenges', Icons.flag, [
      'Les défis te demandent d\'écrire une requête SQL pour accomplir une mission.',
      'Appuie sur « Vérifier » : le terminal compare ton résultat à la solution attendue.',
      'En cas d\'échec, utilise les indices puis passe à la solution expliquée.',
      'Réussir un défi rapporte des XP. Des difficultés croissantes sont prévues.',
    ]),
    _Sec('Projets', Icons.folder, [
      'Les projets sont des cas pratiques complets (bibliothèque, boutique, banque...).',
      'Chaque projet détaille le cahier des charges, les tables, les relations et les données.',
      'Chaque exercice propose une solution SQL expliquée.',
      'Le dernier projet est le grand projet intégrateur « Database Engineer ».',
    ]),
    _Sec('Progression & badges', Icons.workspace_premium, [
      'L\'onglet Profil centralise tes XP, ton niveau, tes statistiques et tes badges.',
      'Termine des leçons, défis, quiz et projets pour débloquer des badges.',
      'Badges : SELECT Rookie, Query Hunter, JOIN Master, SQL Ninja, Database Architect, Database Engineer...',
    ]),
    _Sec('Favoris & notes', Icons.star, [
      'Appuie sur l\'étoile d\'une leçon pour l\'ajouter aux favoris.',
      'Depuis une leçon, le menu (...) permet d\'ajouter une note personnelle.',
      'Retrouve et gère tes notes dans la section dédiée.',
    ]),
    _Sec('Paramètres & thème', Icons.palette, [
      'Choisis un thème clair, sombre, ou système.',
      'Règle ton objectif d\'XP dans le profil.',
      'Dans le Playground, tu peux ajuster la taille du texte.',
    ]),
  ];
}

class _Sec {
  final String title;
  final IconData icon;
  final List<String> points;
  const _Sec(this.title, this.icon, this.points);
}

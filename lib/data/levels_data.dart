import '../models/lesson_models.dart';

/// The 6 progression levels.
class LevelsData {
  LevelsData._();

  static const List<Level> all = [
    Level('debutant', 'Débutant',
        'Découvre les bases : requêtes simples, SELECT, tables.', 0),
    Level('fondamentaux', 'Fondamentaux',
        'Filtrage, tri, fonctions d\'agrégation.', 1),
    Level('intermediaire', 'Intermédiaire',
        'Jointures, sous-requêtes, regroupements.', 2),
    Level('avance', 'Avancé',
        'Vues, index, transactions, optimisation.', 3),
    Level('expert', 'Expert',
        'Conception avancée, sécurité, réplication.', 4),
    Level('engineer', 'Database Engineer',
        'Scalabilité, architecture, bonnes pratiques de production.', 5),
  ];
}


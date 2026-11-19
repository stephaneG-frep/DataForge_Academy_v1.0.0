import 'package:flutter/widgets.dart' show IconData;

/// A practical project with specs, tables, relations, data, exercises & solutions.
class ProjectTask {
  final String id;
  final String title;
  final String description;
  final String difficulty; // Facile / Moyen / Difficile / Expert
  final String solution;
  final String solutionSql;
  final String explanation;

  const ProjectTask({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.solution,
    required this.solutionSql,
    required this.explanation,
  });
}

/// Schema pillar of a project: table definition with a "database flavor" SQL.
class PillarTable {
  final String name;
  final String createSql;
  final String description;

  const PillarTable(this.name, this.createSql, this.description);
}

class Project {
  final String id;
  final String title;
  final IconData icon;
  final String colorName;
  final String summary;
  final String spec; // cahier des charges
  final List<PillarTable> tables;
  final String relations;
  final String sampleData;
  final List<ProjectTask> tasks;
  final int estimatedXp;

  const Project({
    required this.id,
    required this.title,
    required this.icon,
    required this.colorName,
    required this.summary,
    required this.spec,
    required this.tables,
    required this.relations,
    required this.sampleData,
    required this.tasks,
    required this.estimatedXp,
  });
}

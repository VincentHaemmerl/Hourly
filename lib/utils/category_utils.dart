import 'package:flutter/material.dart';

class CategoryUtils {
  // Verfügbare Kategorien
  static const List<String> categories = [
    'Arbeit',
    'Lernen',
    'Sport',
    'Pause',
    'Meeting',
    'Projekt',
    'Freizeit',
    'Haushalt',
  ];

  // Icon für Kategorie ermitteln
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Arbeit':
        return Icons.work;
      case 'Lernen':
        return Icons.school;
      case 'Sport':
        return Icons.fitness_center;
      case 'Pause':
        return Icons.coffee;
      case 'Meeting':
        return Icons.people;
      case 'Projekt':
        return Icons.assignment;
      case 'Freizeit':
        return Icons.games;
      case 'Haushalt':
        return Icons.home;
      default:
        return Icons.timer;
    }
  }

  // Farbe für Kategorie ermitteln (optional für spätere Verwendung)
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Arbeit':
        return Colors.blue;
      case 'Lernen':
        return Colors.green;
      case 'Sport':
        return Colors.orange;
      case 'Pause':
        return Colors.brown;
      case 'Meeting':
        return Colors.purple;
      case 'Projekt':
        return Colors.teal;
      case 'Freizeit':
        return Colors.pink;
      case 'Haushalt':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

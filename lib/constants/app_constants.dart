import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color.fromARGB(
    255,
    76,
    0,
    78,
  );
  static const Color background = Color.fromARGB(
    131,
    75,
    0,
    64,
  );
  static const Color cardBackground = Color.fromARGB(
    255,
    60,
    0,
    62,
  );
  static const Color accent = Color.fromARGB(
    255,
    195,
    0,
    255,
  );

  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color green = Colors.green;
  static const Color red = Colors.red;
  static const Color orange = Colors.orange;
  static const Color purple = Colors.purple;
}

class AppConstants {
  static const String appTitle = 'Hourly';
  static const String storageKey = 'saved_sessions';

  // Dialog Texte
  static const String sessionDialogTitle =
      'Session starten';
  static const String historyDialogTitle =
      'Gespeicherte Sessions';
  static const String statisticsDialogTitle = 'Statistiken';

  // Button Texte
  static const String startText = 'Session starten';
  static const String stopText = 'Session stoppen';
  static const String cancelText = 'Abbrechen';
  static const String closeText = 'Schließen';

  // Placeholder Texte
  static const String sessionNameHint =
      'Session-Name eingeben...';
  static const String categorySelectLabel =
      'Kategorie auswählen:';
  static const String noSessionsText =
      'Noch keine Sessions gespeichert';
}

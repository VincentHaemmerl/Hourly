import 'package:flutter/services.dart';
import '../models/session_model.dart';
import '../utils/statistics_utils.dart';

class ExportService {
  // Sessions in Zwischenablage exportieren
  static Future<Map<String, dynamic>>
  exportSessionsToClipboard(
    List<SessionModel> sessions,
  ) async {
    if (sessions.isEmpty) {
      return {
        'success': false,
        'message':
            'Keine Sessions zum Exportieren vorhanden',
        'color': 'orange',
      };
    }

    // Sessions sortieren (neueste zuerst)
    List<SessionModel> sortedSessions = List.from(sessions);
    sortedSessions.sort((a, b) {
      int timestampA = int.parse(a.timestamp);
      int timestampB = int.parse(b.timestamp);
      return timestampB.compareTo(timestampA);
    });

    // Gesamtzeit berechnen
    int totalSeconds =
        StatisticsUtils.getAverageSeconds(sessions) *
        sessions.length;
    int totalHours = (totalSeconds / 3600).floor();
    int totalMinutes = ((totalSeconds % 3600) / 60).floor();
    int remainingSeconds = totalSeconds % 60;

    // Text für Zwischenablage erstellen
    StringBuffer exportText = StringBuffer();
    exportText.writeln('📊 Hourly Sessions Export');
    exportText.writeln('========================');
    exportText.writeln(
      'Exportiert am: ${DateTime.now().toString().split(' ')[0]}',
    );
    exportText.writeln(
      'Anzahl Sessions: ${sortedSessions.length}',
    );
    exportText.writeln('');

    // Statistiken hinzufügen
    exportText.writeln('📈 STATISTIKEN:');
    exportText.writeln(
      'Durchschnittliche Session-Zeit: ${StatisticsUtils.getAverageTime(sessions)}',
    );
    exportText.writeln(
      'Meistgenutzte Kategorie: ${StatisticsUtils.getMostUsedCategory(sessions)}',
    );
    exportText.writeln(
      'Produktivität: ${StatisticsUtils.getProductivityText(sessions)}',
    );
    exportText.writeln(
      'Gesamtzeit: ${totalHours}h ${totalMinutes}m ${remainingSeconds}s',
    );
    exportText.writeln('');

    exportText.writeln('📋 SESSION DETAILS:');
    exportText.writeln('');

    // Jede Session hinzufügen
    for (int i = 0; i < sortedSessions.length; i++) {
      var session = sortedSessions[i];
      exportText.writeln('${i + 1}. ${session.name}');
      exportText.writeln('   📅 Datum: ${session.date}');
      exportText.writeln('   ⏱️ Länge: ${session.time}');
      exportText.writeln(
        '   🏷️ Kategorie: ${session.category}',
      );

      // Wochentag hinzufügen
      try {
        DateTime sessionDate = DateTime.parse(session.date);
        List<String> weekdays = [
          'Mo',
          'Di',
          'Mi',
          'Do',
          'Fr',
          'Sa',
          'So',
        ];
        String weekday = weekdays[sessionDate.weekday - 1];
        exportText.writeln('   📆 Wochentag: $weekday');
      } catch (e) {
        // Fehler beim Parsen ignorieren
      }

      exportText.writeln('');
    }

    // Zusammenfassung am Ende
    exportText.writeln('========================');
    exportText.writeln('Generiert von Hourly Timer App');

    try {
      // In Zwischenablage kopieren
      await Clipboard.setData(
        ClipboardData(text: exportText.toString()),
      );

      return {
        'success': true,
        'message':
            '✅ ${sortedSessions.length} Sessions in Zwischenablage kopiert!',
        'color': 'green',
      };
    } catch (e) {
      print('Fehler beim Kopieren: $e');
      return {
        'success': false,
        'message':
            '❌ Fehler beim Kopieren in die Zwischenablage',
        'color': 'red',
      };
    }
  }
}

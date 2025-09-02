import 'package:flutter/material.dart';
import '../models/session_model.dart';

class StatisticsUtils {
  // Durchschnittliche Session-Zeit berechnen
  static String getAverageTime(
    List<SessionModel> sessions,
  ) {
    if (sessions.isEmpty) return "00:00:00";

    int totalSeconds = 0;

    for (var session in sessions) {
      List<String> parts = session.time.split(':');
      if (parts.length == 3) {
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        int seconds = int.parse(parts[2]);
        totalSeconds +=
            hours * 3600 + minutes * 60 + seconds;
      }
    }

    int avgSeconds = (totalSeconds / sessions.length)
        .round();
    int hours = avgSeconds ~/ 3600;
    int minutes = (avgSeconds % 3600) ~/ 60;
    int seconds = avgSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Durchschnittliche Sekunden berechnen
  static int getAverageSeconds(
    List<SessionModel> sessions,
  ) {
    if (sessions.isEmpty) return 1;

    int totalSeconds = 0;

    for (var session in sessions) {
      List<String> parts = session.time.split(':');
      if (parts.length == 3) {
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        int seconds = int.parse(parts[2]);
        totalSeconds +=
            hours * 3600 + minutes * 60 + seconds;
      }
    }

    int averageSeconds = (totalSeconds / sessions.length)
        .round();
    return averageSeconds <= 0 ? 0 : averageSeconds;
  }

  // Meistgenutzte Kategorie ermitteln
  static String getMostUsedCategory(
    List<SessionModel> sessions,
  ) {
    if (sessions.isEmpty) return "Keine Kategorie";

    Map<String, int> categoryCount = {};

    for (var session in sessions) {
      String cat = session.category;
      categoryCount[cat] = (categoryCount[cat] ?? 0) + 1;
    }

    return categoryCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Tage seit letzter Session berechnen
  static int getDaysSinceLastSession(
    List<SessionModel> sessions,
  ) {
    if (sessions.isEmpty) return -1;

    // Sessions sortieren
    List<SessionModel> sortedSessions = List.from(sessions);
    sortedSessions.sort((a, b) {
      int timestampA = int.parse(a.timestamp);
      int timestampB = int.parse(b.timestamp);
      return timestampB.compareTo(timestampA);
    });

    DateTime lastSessionDate =
        DateTime.fromMillisecondsSinceEpoch(
          int.parse(sortedSessions.first.timestamp),
        );

    DateTime now = DateTime.now();
    Duration difference = now.difference(lastSessionDate);

    return difference.inDays;
  }

  // Produktivitätsscore berechnen
  static int calculateProductivityScore(
    int days,
    int avgSeconds,
  ) {
    int activityScore = 0;
    if (days == -1) {
      activityScore = 0;
    } else if (days == 0) {
      activityScore = 50;
    } else if (days == 1) {
      activityScore = 40;
    } else if (days <= 3) {
      activityScore = 30;
    } else if (days <= 7) {
      activityScore = 20;
    } else if (days <= 14) {
      activityScore = 10;
    } else {
      activityScore = 0;
    }

    int qualityScore = 0;
    if (avgSeconds >= 7200) {
      qualityScore = 50;
    } else if (avgSeconds >= 3600) {
      qualityScore = 45;
    } else if (avgSeconds >= 1800) {
      qualityScore = 35;
    } else if (avgSeconds >= 900) {
      qualityScore = 25;
    } else if (avgSeconds >= 300) {
      qualityScore = 15;
    } else if (avgSeconds >= 60) {
      qualityScore = 5;
    } else {
      qualityScore = 0;
    }

    int bonusScore = 0;

    if (avgSeconds >= 3600 && days <= 7) {
      bonusScore += 10;
    }

    if (avgSeconds < 600 && days > 2) {
      bonusScore -= 10;
    }

    if (avgSeconds >= 1200 &&
        avgSeconds <= 2400 &&
        days <= 3) {
      bonusScore += 5;
    }

    int totalScore =
        activityScore + qualityScore + bonusScore;
    return totalScore.clamp(0, 100);
  }

  // Produktivitätstext ermitteln
  static String getProductivityText(
    List<SessionModel> sessions,
  ) {
    int days = getDaysSinceLastSession(sessions);
    int avgSeconds = getAverageSeconds(sessions);
    int productivityScore = calculateProductivityScore(
      days,
      avgSeconds,
    );

    if (productivityScore >= 90) {
      return " GROSSARTIG!";
    } else if (productivityScore >= 70) {
      return " hoch";
    } else if (productivityScore >= 50) {
      return " mittelmäßig";
    } else if (productivityScore >= 30) {
      return " niedrig";
    } else {
      return " ZU NIEDRIG!";
    }
  }

  // Produktivitätsfarbe ermitteln
  static Color getProductivityColor(
    List<SessionModel> sessions,
  ) {
    int days = getDaysSinceLastSession(sessions);

    if (days == -1 || days >= 15) {
      return Colors.red;
    } else if (days >= 10 && days < 15) {
      return Colors.red;
    } else if (days >= 5 && days < 10) {
      return Colors.orange;
    } else if (days > 0 && days < 5) {
      return Colors.lightGreen;
    } else if (days == 0) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }
}

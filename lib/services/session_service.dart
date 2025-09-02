import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/session_model.dart';

class SessionService {
  static const String _storageKey = 'saved_sessions';

  // Sessions laden
  static Future<List<SessionModel>> loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sessionsJson = prefs.getString(
        _storageKey,
      );

      if (sessionsJson != null) {
        final List<dynamic> sessionsList = json.decode(
          sessionsJson,
        );
        return sessionsList
            .map(
              (session) => SessionModel.fromMap(
                Map<String, String>.from(session),
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Fehler beim Laden der Sessions: $e');
      return [];
    }
  }

  // Sessions speichern
  static Future<void> saveSessions(
    List<SessionModel> sessions,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String sessionsJson = json.encode(
        sessions.map((session) => session.toMap()).toList(),
      );
      await prefs.setString(_storageKey, sessionsJson);
      print('${sessions.length} Sessions gespeichert');
    } catch (e) {
      print('Fehler beim Speichern der Sessions: $e');
    }
  }

  // Session hinzufügen
  static Future<void> addSession(
    SessionModel session,
    List<SessionModel> currentSessions,
  ) async {
    currentSessions.add(session);
    await saveSessions(currentSessions);
  }

  // Session löschen
  static Future<void> deleteSession(
    int index,
    List<SessionModel> currentSessions,
  ) async {
    if (index >= 0 && index < currentSessions.length) {
      currentSessions.removeAt(index);
      await saveSessions(currentSessions);
      print('Session gelöscht');
    }
  }

  // Sessions sortieren (neueste zuerst)
  static List<SessionModel> sortSessionsByTimestamp(
    List<SessionModel> sessions,
  ) {
    List<SessionModel> sortedSessions = List.from(sessions);
    sortedSessions.sort((a, b) {
      int timestampA = int.parse(a.timestamp);
      int timestampB = int.parse(b.timestamp);
      return timestampB.compareTo(timestampA);
    });
    return sortedSessions;
  }
}

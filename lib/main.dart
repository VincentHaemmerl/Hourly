import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Für SystemChrome
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const Hourly());
}

class Hourly extends StatelessWidget {
  const Hourly({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hourly',
      debugShowCheckedModeBanner:
          false, // Debug-Banner entfernen
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: const HourlyHomePage(title: 'Hourly'),
    );
  }
}

class HourlyHomePage extends StatefulWidget {
  const HourlyHomePage({super.key, required this.title});
  final String title;

  @override
  State<HourlyHomePage> createState() =>
      _HourlyHomePageState();
}

class _HourlyHomePageState extends State<HourlyHomePage> {
  bool isSessionActive = false;
  String currentTimeString = "00:00:00";
  String currentSessionName = "";
  String selectedCategory = "";
  bool isNotification = false;
  int notificationNum = 0;
  String productivityText = "";
  List<Map<String, String>> savedSessions = [];
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  String getAverageTime() {
    if (savedSessions.isEmpty) return "00:00:00";

    int totalSeconds = 0;

    for (var session in savedSessions) {
      String timeStr = session['time'] ?? "00:00:00";
      List<String> parts = timeStr.split(':');
      if (parts.length == 3) {
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        int seconds = int.parse(parts[2]);
        totalSeconds +=
            hours * 3600 + minutes * 60 + seconds;
      }
    }

    int avgSeconds = (totalSeconds / savedSessions.length)
        .round();
    int hours = avgSeconds ~/ 3600;
    int minutes = (avgSeconds % 3600) ~/ 60;
    int seconds = avgSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int getAverageSeconds() {
    if (savedSessions.isEmpty) return 1;

    int totalSeconds = 0;

    for (var session in savedSessions) {
      String timeStr = session['time'] ?? "00:00:00";
      List<String> parts = timeStr.split(':');
      if (parts.length == 3) {
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        int seconds = int.parse(parts[2]);
        totalSeconds +=
            hours * 3600 + minutes * 60 + seconds;
      }
    }

    int averageSeconds =
        (totalSeconds / savedSessions.length).round();

    if (averageSeconds <= 0) {
      return 0;
    } else {
      return averageSeconds;
    }
  }

  int getDaysSinceLastSession() {
    if (savedSessions.isEmpty) {
      return -1;
    }

    savedSessions.sort((a, b) {
      int timestampA = int.parse(a['timestamp'] ?? '0');
      int timestampB = int.parse(b['timestamp'] ?? '0');
      return timestampB.compareTo(timestampA);
    });

    String lastSessionTimestamp =
        savedSessions.first['timestamp'] ?? '0';
    DateTime lastSessionDate =
        DateTime.fromMillisecondsSinceEpoch(
          int.parse(lastSessionTimestamp),
        );

    DateTime now = DateTime.now();
    Duration difference = now.difference(lastSessionDate);

    return difference.inDays;
  }

  String getLastSessionText() {
    int days = getDaysSinceLastSession();
    int avgSeconds = getAverageSeconds();

    // Berechne einen kombinierten Score
    int productivityScore = _calculateProductivityScore(
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

  // Neue Funktion für kombinierten Produktivitäts-Score
  int _calculateProductivityScore(
    int days,
    int avgSeconds,
  ) {
    // Basis-Score für Aktualität (0-50 Punkte)
    int activityScore = 0;
    if (days == -1) {
      activityScore = 0; // Keine Sessions
    } else if (days == 0) {
      activityScore = 50; // Heute aktiv = volle Punkte
    } else if (days == 1) {
      activityScore = 40; // Gestern = sehr gut
    } else if (days <= 3) {
      activityScore = 30; // Vor 2-3 Tagen = ok
    } else if (days <= 7) {
      activityScore = 20; // Vor 4-7 Tagen = nicht so gut
    } else if (days <= 14) {
      activityScore = 10; // Vor 8-14 Tagen = schlecht
    } else {
      activityScore =
          0; // Mehr als 2 Wochen = sehr schlecht
    }

    // Basis-Score für Session-Qualität (0-50 Punkte)
    int qualityScore = 0;
    if (avgSeconds >= 7200) {
      // 2+ Stunden
      qualityScore = 50;
    } else if (avgSeconds >= 3600) {
      // 1-2 Stunden
      qualityScore = 45;
    } else if (avgSeconds >= 1800) {
      // 30-60 Minuten
      qualityScore = 35;
    } else if (avgSeconds >= 900) {
      // 15-30 Minuten
      qualityScore = 25;
    } else if (avgSeconds >= 300) {
      // 5-15 Minuten
      qualityScore = 15;
    } else if (avgSeconds >= 60) {
      // 1-5 Minuten
      qualityScore = 5;
    } else {
      qualityScore = 0; // Weniger als 1 Minute
    }

    // Bonus/Malus je nach Kombination
    int bonusScore = 0;

    // Bonus: Sehr lange Sessions können alte Daten kompensieren
    if (avgSeconds >= 3600 && days <= 7) {
      bonusScore +=
          10; // Lange Sessions + nicht zu alt = Bonus
    }

    // Malus: Kurze Sessions werden strenger bewertet
    if (avgSeconds < 600 && days > 2) {
      bonusScore -= 10; // Kurze Sessions + alt = Malus
    }

    // Bonus: Konsistenz bei mittleren Sessions
    if (avgSeconds >= 1200 &&
        avgSeconds <= 2400 &&
        days <= 3) {
      bonusScore +=
          5; // Mittlere Sessions regelmäßig = Bonus
    }

    int totalScore =
        activityScore + qualityScore + bonusScore;

    // Stelle sicher, dass Score zwischen 0-100 liegt
    return totalScore.clamp(0, 100);
  }

  @override
  void initState() {
    super.initState();
    _loadSessions(); // Sessions beim Start laden

    // Verstecke die Navigationsleiste für diese spezifische Seite
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    // Setze die Navigationsleiste auf transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  // Sessions aus SharedPreferences laden
  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? sessionsJson = prefs.getString(
        'saved_sessions',
      );

      if (sessionsJson != null) {
        final List<dynamic> sessionsList = json.decode(
          sessionsJson,
        );
        setState(() {
          savedSessions = sessionsList
              .map(
                (session) =>
                    Map<String, String>.from(session),
              )
              .toList();
        });
        print('${savedSessions.length} Sessions geladen');
      }
    } catch (e) {
      print('Fehler beim Laden der Sessions: $e');
    }
  }

  // Sessions in SharedPreferences speichern
  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String sessionsJson = json.encode(
        savedSessions,
      );
      await prefs.setString('saved_sessions', sessionsJson);
      print('${savedSessions.length} Sessions gespeichert');
    } catch (e) {
      print('Fehler beim Speichern der Sessions: $e');
    }
  }

  Future<void> _showSessionNameDialog() async {
    String sessionName = "";
    String selectedCategoryLocal = "Arbeit";

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color.fromARGB(
                255,
                76,
                0,
                78,
              ),
              title: const Text(
                'Session starten',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Session-Name eingeben...',
                      hintStyle: TextStyle(
                        color: Colors.white70,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.purple,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      sessionName = value;
                    },
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kategorie auswählen:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white54,
                          ),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: selectedCategoryLocal,
                          dropdownColor:
                              const Color.fromARGB(
                                255,
                                76,
                                0,
                                78,
                              ),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          underline: Container(),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          ),
                          isExpanded: true,
                          items:
                              [
                                'Arbeit',
                                'Lernen',
                                'Sport',
                                'Pause',
                                'Meeting',
                                'Projekt',
                                'Freizeit',
                                'Haushalt',
                              ].map((String kategorie) {
                                return DropdownMenuItem<
                                  String
                                >(
                                  value: kategorie,
                                  child: Text(
                                    kategorie,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged:
                              (String? neueKategorie) {
                                setDialogState(() {
                                  selectedCategoryLocal =
                                      neueKategorie!;
                                });
                              },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Abbrechen',
                    style: TextStyle(color: Colors.white70),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    'Starten',
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () {
                    if (sessionName.trim().isNotEmpty) {
                      currentSessionName = sessionName
                          .trim();
                      selectedCategory =
                          selectedCategoryLocal;
                      Navigator.of(context).pop();
                      _startTimerSession();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startTimerSession() {
    setState(() {
      isSessionActive = true;
    });
    _stopWatchTimer.onStartTimer();
    print('Session "$currentSessionName" started');
  }

  void _stopAndSaveSession() async {
    _stopWatchTimer.onStopTimer();
    isNotification = true;
    notificationNum++;

    // Session zur Liste hinzufügen
    savedSessions.add({
      'name': currentSessionName,
      'time': currentTimeString,
      'date': DateTime.now().toString().split(' ')[0],
      'category': selectedCategory,
      'timestamp': DateTime.now().millisecondsSinceEpoch
          .toString(), // Eindeutige ID
    });

    setState(() {
      isSessionActive = false;
    });

    // Sessions dauerhaft speichern
    await _saveSessions();

    _stopWatchTimer.onResetTimer();

    print(
      'Session "$currentSessionName" gespeichert: $currentTimeString',
    );
    print('Alle Sessions: $savedSessions');

    currentSessionName = "";
    selectedCategory = "";
  }

  void StartSession() {
    if (!isSessionActive) {
      _showSessionNameDialog();
    } else {
      _stopAndSaveSession();
    }
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    super.dispose();
  }

  // Session löschen
  Future<void> _deleteSession(int index) async {
    setState(() {
      savedSessions.removeAt(index);
    });
    await _saveSessions();
    print('Session gelöscht');
  }

  IconData _getCategoryIcon(String category) {
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

  void _showSavedSessions() {
    // setState() hinzufügen damit UI aktualisiert wird
    setState(() {
      isNotification = false;
      notificationNum = 0;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(
            255,
            76,
            0,
            78,
          ),
          title: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gespeicherte Sessions',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: savedSessions.isEmpty
                ? const Text(
                    'Noch keine Sessions gespeichert',
                    style: TextStyle(color: Colors.white70),
                  )
                : ListView.builder(
                    itemCount: savedSessions.length,
                    itemBuilder: (context, index) {
                      final session = savedSessions[index];
                      return Card(
                        color: const Color.fromARGB(
                          255,
                          60,
                          0,
                          62,
                        ),
                        margin: EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        child: ListTile(
                          title: Text(
                            session['name']!,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            'Zeit: ${session['time']}\nKategorie: ${session['category']}\nDatum: ${session['date']}',
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          leading: Icon(
                            _getCategoryIcon(
                              session['category']!,
                            ),
                            color: Colors.purple,
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              _deleteSession(index);
                              Navigator.of(context).pop();
                              _showSavedSessions(); // Dialog neu öffnen
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Schließen',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Farbe basierend auf Produktivitätslevel bestimmen
  Color getProductivityColor() {
    int days = getDaysSinceLastSession();

    if (days == -1 || days >= 15) {
      return Colors.red; // ZU NIEDRIG! - Rot
    } else if (days >= 10 && days < 15) {
      return Colors.red; // niedrig - Rot
    } else if (days >= 5 && days < 10) {
      return Colors.orange; // mittelmäßig - Orange/Gelb
    } else if (days > 0 && days < 5) {
      return Colors.lightGreen; // hoch - Hellgrün
    } else if (days == 0) {
      return Colors.green; // GROSSARTIG! - Grün
    } else {
      return Colors.grey; // Unmöglich - Grau
    }
  }

  void _showStatistics() {
    setState(() {
      productivityText = getLastSessionText();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(
            255,
            76,
            0,
            78,
          ),
          title: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Statistiken',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Durchschnittliche Session-Zeit:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    getAverageTime(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Deine Produktivität ist:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: getProductivityColor()
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                      border: Border.all(
                        color: getProductivityColor(),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      productivityText,
                      style: TextStyle(
                        color: getProductivityColor(),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Schließen',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(131, 75, 0, 64),
      extendBody:
          true, // Erweitert den Body hinter die Navigationsleiste
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.analytics,
            color: Colors.white,
          ),
          onPressed: () {
            _showStatistics();
          },
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(
          255,
          76,
          0,
          78,
        ),
        actions: [
          // Bestehender History-Button
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    _showSavedSessions();
                  },
                ),
                // Notification Badge
                if (isNotification && notificationNum > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '$notificationNum',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: EdgeInsets.fromLTRB(0, 200, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentSessionName.isNotEmpty)
                  Container(
                    margin: EdgeInsets.fromLTRB(
                      0,
                      0,
                      0,
                      20,
                    ),
                    child: Text(
                      'Session: $currentSessionName',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: StreamBuilder<int>(
                    stream: _stopWatchTimer.rawTime,
                    initialData:
                        _stopWatchTimer.rawTime.value,
                    builder: (context, snap) {
                      final value = snap.data!;
                      final displayTime =
                          StopWatchTimer.getDisplayTime(
                            value,
                            hours: true,
                            milliSecond: false,
                          );

                      currentTimeString = displayTime;

                      return Text(
                        displayTime,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 200, 0, 0),
                  child: Text(
                    isSessionActive
                        ? "Session stoppen"
                        : "Session starten",
                    style: TextStyle(
                      color: const Color.fromARGB(
                        255,
                        195,
                        0,
                        255,
                      ),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Material(
                    elevation: 4.0,
                    shadowColor: isSessionActive
                        ? Colors.red.withValues()
                        : Colors.green.withValues(),
                    shape: CircleBorder(),
                    color: isSessionActive
                        ? Colors.red
                        : Colors.green,
                    child: InkWell(
                      onTap: StartSession,
                      customBorder: CircleBorder(),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          size: 30,
                          color: Colors.white,
                          isSessionActive
                              ? Icons.stop
                              : Icons.play_arrow,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

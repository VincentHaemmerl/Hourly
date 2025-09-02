import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'models/session_model.dart';
import 'services/session_service.dart';
import 'widgets/session_dialog.dart';
import 'pages/session_history_page.dart';
import 'pages/statistics_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const Hourly());
}

class Hourly extends StatelessWidget {
  const Hourly({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hourly',
      debugShowCheckedModeBanner: false,
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
  List<SessionModel> savedSessions = [];
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  @override
  void initState() {
    super.initState();
    _loadSessions();
    _initializeSystemUI();
  }

  void _initializeSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
      ),
    );
  }

  Future<void> _loadSessions() async {
    final sessions = await SessionService.loadSessions();
    setState(() {
      savedSessions = sessions;
    });
  }

  Future<void> _showSessionNameDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SessionDialog(
          onSessionStart: (sessionName, category) {
            currentSessionName = sessionName;
            selectedCategory = category;
            _startTimerSession();
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

    setState(() {
      isNotification = true;
      notificationNum++;
      isSessionActive = false;
    });

    // Neue Session erstellen und speichern
    final newSession = SessionModel.create(
      name: currentSessionName,
      time: currentTimeString,
      category: selectedCategory,
    );

    await SessionService.addSession(
      newSession,
      savedSessions,
    );
    await _loadSessions(); // Sessions neu laden

    _stopWatchTimer.onResetTimer();

    print(
      'Session "$currentSessionName" gespeichert: $currentTimeString',
    );

    currentSessionName = "";
    selectedCategory = "";
  }

  void _startSession() {
    if (!isSessionActive) {
      _showSessionNameDialog();
    } else {
      _stopAndSaveSession();
    }
  }

  void _showSavedSessions() {
    setState(() {
      isNotification = false;
      notificationNum = 0;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionHistoryPage(
          sessions: savedSessions,
          onDeleteSession: (index) async {
            await SessionService.deleteSession(
              index,
              savedSessions,
            );
            await _loadSessions();
            setState(() {});
          },
        ),
      ),
    );
  }

  void _showStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StatisticsPage(sessions: savedSessions),
      ),
    );
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          onDeleteAllSessions: () async {
            savedSessions.clear();
            await SessionService.saveSessions([]);
            await _loadSessions();
            setState(() {
              isNotification = false;
              notificationNum = 0;
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(131, 75, 0, 64),
      extendBody: true,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.analytics,
            color: Colors.white,
          ),
          onPressed: _showStatistics,
        ),
        title: Container(
          width: 120,
          height: 40,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 76, 0, 78),
            borderRadius: BorderRadius.all(
              Radius.circular(34),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(
                0.1,
              ), // Dünner, weißer Border
              width: 2.0, // Dünne Linie
            ),
          ),
          child: Center(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 7, 0),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                // Notification Badge
                if (isNotification && notificationNum > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
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
                        style: const TextStyle(
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
            margin: const EdgeInsets.fromLTRB(0, 200, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Session Name Display
                if (currentSessionName.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(
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

                // Timer Display
                Container(
                  margin: const EdgeInsets.fromLTRB(
                    0,
                    100,
                    0,
                    0,
                  ),
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

                      return Container(
                        width: 200,
                        height: 85,
                        margin: EdgeInsets.fromLTRB(
                          0,
                          0,
                          0,
                          0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            76,
                            0,
                            78,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(34),
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              0.1,
                            ), // Dünner, weißer Border
                            width: 2.0, // Dünne Linie
                          ),
                        ),

                        child: Center(
                          child: Text(
                            displayTime,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  width: 350,
                  height: 85,
                  margin: EdgeInsets.fromLTRB(0, 250, 0, 0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      76,
                      0,
                      78,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(34),
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(
                        0.1,
                      ), // Dünner, weißer Border
                      width: 2.0, // Dünne Linie
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: IconButton(
                          onPressed: _showSettings,
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Material(
                          elevation: 4.0,
                          shadowColor: isSessionActive
                              ? Colors.red.withValues()
                              : Colors.green.withValues(),
                          shape: const CircleBorder(),
                          color: isSessionActive
                              ? Colors.red
                              : Colors.green,
                          child: InkWell(
                            onTap: _startSession,
                            customBorder:
                                const CircleBorder(),

                            child: Icon(
                              size: 60,
                              color: Colors.white,
                              isSessionActive
                                  ? Icons.stop_rounded
                                  : Icons
                                        .play_arrow_rounded,
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: IconButton(
                          onPressed: _showSavedSessions,
                          icon: const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
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

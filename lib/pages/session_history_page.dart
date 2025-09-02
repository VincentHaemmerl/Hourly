import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/session_model.dart';
import '../services/export_service.dart';
import '../utils/category_utils.dart';

class SessionHistoryPage extends StatefulWidget {
  final List<SessionModel> sessions;
  final Function(int index) onDeleteSession;

  const SessionHistoryPage({
    super.key,
    required this.sessions,
    required this.onDeleteSession,
  });

  @override
  State<SessionHistoryPage> createState() =>
      _SessionHistoryPageState();
}

class _SessionHistoryPageState
    extends State<SessionHistoryPage> {
  List<SessionModel> sessions = [];

  @override
  void initState() {
    super.initState();
    sessions = widget.sessions;
  }

  Future<void> _handleExport() async {
    final result =
        await ExportService.exportSessionsToClipboard(
          sessions,
        );

    if (mounted) {
      Color backgroundColor;
      switch (result['color']) {
        case 'green':
          backgroundColor = Colors.green;
          break;
        case 'red':
          backgroundColor = Colors.red;
          break;
        case 'orange':
          backgroundColor = Colors.orange;
          break;
        default:
          backgroundColor = Colors.grey;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(131, 75, 0, 64),
      appBar: AppBar(
        title: const Text(
          'Session Verlauf',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(
          255,
          76,
          0,
          78,
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _handleExport,
            tooltip: 'Sessions exportieren',
          ),
        ],
      ),
      body: SafeArea(
        child: sessions.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 80,
                      color: Colors.white54,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Noch keine Sessions gespeichert',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Starte deine erste Session!',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Card(
                    color: const Color.fromARGB(
                      255,
                      76,
                      0,
                      78,
                    ),
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                      side: BorderSide(
                        color: Colors.white.withOpacity(
                          0.1,
                        ),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(
                        16,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(
                            0.2,
                          ),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Icon(
                          CategoryUtils.getCategoryIcon(
                            session.category,
                          ),
                          color: Colors.purple,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        session.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                session.time,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.category,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                session.category,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                session.date,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _showDeleteDialog(index);
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showDeleteDialog(int index) {
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
          title: const Text(
            '⚠️ Session löschen?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Möchtest du die Session "${sessions[index].name}" wirklich löschen?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Abbrechen',
                style: TextStyle(color: Colors.white70),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Löschen',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await widget.onDeleteSession(index);
                setState(() {
                  sessions.removeAt(index);
                });

                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Session wurde gelöscht',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

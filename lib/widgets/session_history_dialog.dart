import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../utils/category_utils.dart';
import '../services/export_service.dart';

class SessionHistoryDialog extends StatelessWidget {
  final List<SessionModel> sessions;
  final Function(int index) onDeleteSession;

  const SessionHistoryDialog({
    super.key,
    required this.sessions,
    required this.onDeleteSession,
  });

  Future<void> _handleExport(BuildContext context) async {
    final result =
        await ExportService.exportSessionsToClipboard(
          sessions,
        );

    if (context.mounted) {
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
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 76, 0, 78),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Gespeicherte Sessions',
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.copy,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => _handleExport(context),
            tooltip: 'Sessions kopieren',
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: sessions.isEmpty
            ? const Text(
                'Noch keine Sessions gespeichert',
                style: TextStyle(color: Colors.white70),
              )
            : ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Card(
                    color: const Color.fromARGB(
                      255,
                      60,
                      0,
                      62,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(
                        session.name,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        'Zeit: ${session.time}\nKategorie: ${session.category}\nDatum: ${session.date}',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      leading: Icon(
                        CategoryUtils.getCategoryIcon(
                          session.category,
                        ),
                        color: Colors.purple,
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          onDeleteSession(index);
                          Navigator.of(context).pop();
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
  }
}

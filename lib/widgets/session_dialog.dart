import 'package:flutter/material.dart';
import '../utils/category_utils.dart';

class SessionDialog extends StatefulWidget {
  final Function(String sessionName, String category)
  onSessionStart;

  const SessionDialog({
    super.key,
    required this.onSessionStart,
  });

  @override
  State<SessionDialog> createState() =>
      _SessionDialogState();
}

class _SessionDialogState extends State<SessionDialog> {
  String sessionName = "";
  String selectedCategory = "Arbeit";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 76, 0, 78),
      title: const Text(
        'Session starten',
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Session Name Input
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Session-Name eingeben...',
              hintStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.purple,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                sessionName = value;
              });
            },
          ),
          const SizedBox(height: 20),

          // Category Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kategorie auswählen:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white54),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: selectedCategory,
                  dropdownColor: const Color.fromARGB(
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
                  items: CategoryUtils.categories.map((
                    String kategorie,
                  ) {
                    return DropdownMenuItem<String>(
                      value: kategorie,
                      child: Text(
                        kategorie,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? neueKategorie) {
                    setState(() {
                      selectedCategory = neueKategorie!;
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
              widget.onSessionStart(
                sessionName.trim(),
                selectedCategory,
              );
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../utils/statistics_utils.dart';

class StatisticsDialog extends StatelessWidget {
  final List<SessionModel> sessions;

  const StatisticsDialog({
    super.key,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final productivityText =
        StatisticsUtils.getProductivityText(sessions);
    final productivityColor =
        StatisticsUtils.getProductivityColor(sessions);

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 76, 0, 78),
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
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
              // Meistgenutzte Kategorie
              const Text(
                "Meistgenutzte Kategorie:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(
                  20,
                  5,
                  20,
                  20,
                ),
                child: Text(
                  StatisticsUtils.getMostUsedCategory(
                    sessions,
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Durchschnittliche Session-Zeit
              const Text(
                "Durchschnittliche Session-Zeit:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(
                  20,
                  5,
                  20,
                  20,
                ),
                child: Text(
                  StatisticsUtils.getAverageTime(sessions),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Produktivität
              const Text(
                "Deine Produktivität ist:",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: productivityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: productivityColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  productivityText,
                  style: TextStyle(
                    color: productivityColor,
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
  }
}

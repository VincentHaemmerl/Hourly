import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../utils/statistics_utils.dart';

class StatisticsPage extends StatelessWidget {
  final List<SessionModel> sessions;

  const StatisticsPage({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final productivityText =
        StatisticsUtils.getProductivityText(sessions);
    final productivityColor =
        StatisticsUtils.getProductivityColor(sessions);
    final averageTime = StatisticsUtils.getAverageTime(
      sessions,
    );
    final mostUsedCategory =
        StatisticsUtils.getMostUsedCategory(sessions);
    final daysSinceLastSession =
        StatisticsUtils.getDaysSinceLastSession(sessions);

    return Scaffold(
      backgroundColor: const Color.fromARGB(131, 75, 0, 64),
      appBar: AppBar(
        title: const Text(
          'Statistiken',
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Produktivitäts-Card
              Card(
                color: const Color.fromARGB(255, 76, 0, 78),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: productivityColor.withOpacity(
                      0.3,
                    ),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: productivityColor,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Deine Produktivität ist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: productivityColor
                              .withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(25),
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

              const SizedBox(height: 20),

              // Statistik-Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Sessions',
                      sessions.length.toString(),
                      Icons.timer,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Ø Zeit',
                      averageTime,
                      Icons.access_time,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Top Kategorie',
                      mostUsedCategory,
                      Icons.category,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Letzte Session',
                      daysSinceLastSession == -1
                          ? 'Keine'
                          : daysSinceLastSession == 0
                          ? 'Heute'
                          : '${daysSinceLastSession}d ago',
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ),
                ],
              ),

              if (sessions.isNotEmpty) ...[
                const SizedBox(height: 24),

                // Kategorie-Übersicht
                Card(
                  color: const Color.fromARGB(
                    255,
                    76,
                    0,
                    78,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.pie_chart,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Kategorien-Verteilung',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._buildCategoryStats(),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: const Color.fromARGB(255, 76, 0, 78),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryStats() {
    Map<String, int> categoryCount = {};

    for (var session in sessions) {
      categoryCount[session.category] =
          (categoryCount[session.category] ?? 0) + 1;
    }

    final sortedCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedCategories.map((entry) {
      final percentage =
          (entry.value / sessions.length * 100).round();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                entry.key,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: LinearProgressIndicator(
                value: entry.value / sessions.length,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.purple.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${entry.value}x ($percentage%)',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

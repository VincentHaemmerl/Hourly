class SessionModel {
  final String name;
  final String time;
  final String date;
  final String category;
  final String timestamp;

  SessionModel({
    required this.name,
    required this.time,
    required this.date,
    required this.category,
    required this.timestamp,
  });

  // Erstelle SessionModel aus Map
  factory SessionModel.fromMap(Map<String, String> map) {
    return SessionModel(
      name: map['name'] ?? '',
      time: map['time'] ?? '00:00:00',
      date: map['date'] ?? '',
      category: map['category'] ?? 'Unbekannt',
      timestamp: map['timestamp'] ?? '0',
    );
  }

  // Konvertiere SessionModel zu Map
  Map<String, String> toMap() {
    return {
      'name': name,
      'time': time,
      'date': date,
      'category': category,
      'timestamp': timestamp,
    };
  }

  // Erstelle neue Session mit aktueller Zeit
  factory SessionModel.create({
    required String name,
    required String time,
    required String category,
  }) {
    return SessionModel(
      name: name,
      time: time,
      date: DateTime.now().toString().split(' ')[0],
      category: category,
      timestamp: DateTime.now().millisecondsSinceEpoch
          .toString(),
    );
  }
}

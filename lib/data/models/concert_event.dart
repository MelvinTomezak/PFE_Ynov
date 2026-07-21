/// Un événement / concert.
class ConcertEvent {
  final String id;
  final String title;
  final String venue;
  final String city;
  final DateTime startsAt;
  final double? latitude;
  final double? longitude;

  const ConcertEvent({
    required this.id,
    required this.title,
    required this.venue,
    required this.city,
    required this.startsAt,
    this.latitude,
    this.longitude,
  });

  factory ConcertEvent.fromMap(Map<String, dynamic> map) {
    return ConcertEvent(
      id: map['id'] as String,
      title: map['title'] as String,
      venue: map['venue'] as String,
      city: map['city'] as String,
      startsAt: DateTime.parse(map['starts_at'] as String).toLocal(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  bool get hasCoordinates => latitude != null && longitude != null;

  /// Date formatée « JJ/MM/AAAA à HHhMM ».
  String get formattedDate {
    String two(int n) => n.toString().padLeft(2, '0');
    final d = startsAt;
    return '${two(d.day)}/${two(d.month)}/${d.year} à ${two(d.hour)}h${two(d.minute)}';
  }
}

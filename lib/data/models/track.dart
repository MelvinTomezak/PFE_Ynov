/// Un morceau de STYMA.
class Track {
  final String id;
  final String title;
  final String? album;
  final String? coverUrl;
  final int? durationSeconds;

  const Track({
    required this.id,
    required this.title,
    this.album,
    this.coverUrl,
    this.durationSeconds,
  });

  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      id: map['id'] as String,
      title: map['title'] as String,
      album: map['album'] as String?,
      coverUrl: map['cover_url'] as String?,
      durationSeconds: map['duration_seconds'] as int?,
    );
  }

  /// Durée formatée « m:ss » (ex. 213 -> "3:33").
  String get formattedDuration {
    final total = durationSeconds;
    if (total == null) return '';
    final minutes = total ~/ 60;
    final seconds = (total % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

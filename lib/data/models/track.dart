/// Un morceau de STYMA.
class Track {
  final String id;
  final String title;
  final String? album;
  final String? coverUrl;
  final int? durationSeconds;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  const Track({
    required this.id,
    required this.title,
    this.album,
    this.coverUrl,
    this.durationSeconds,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
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

  Track copyWith({int? likeCount, int? commentCount, bool? isLiked}) {
    return Track(
      id: id,
      title: title,
      album: album,
      coverUrl: coverUrl,
      durationSeconds: durationSeconds,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
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

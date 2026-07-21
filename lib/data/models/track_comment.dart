/// Commentaire laissé par un utilisateur sur un morceau.
class TrackComment {
  final String id;
  final String trackId;
  final String userId;
  final String username;
  final String content;
  final DateTime createdAt;

  const TrackComment({
    required this.id,
    required this.trackId,
    required this.userId,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  factory TrackComment.fromMap(Map<String, dynamic> map) {
    return TrackComment(
      id: map['id'] as String,
      trackId: map['track_id'] as String,
      userId: map['user_id'] as String,
      username: map['username'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
    );
  }
}

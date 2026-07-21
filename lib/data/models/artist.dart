/// Informations sur l'artiste (biographie).
class Artist {
  final String name;
  final String bio;
  final String? imageUrl;

  const Artist({required this.name, required this.bio, this.imageUrl});

  factory Artist.fromMap(Map<String, dynamic> map) {
    return Artist(
      name: map['name'] as String,
      bio: map['bio'] as String,
      imageUrl: map['image_url'] as String?,
    );
  }
}

/// Représente le profil d'un utilisateur STYMA.
class UserProfile {
  final String id;
  final String email;
  final String? displayName;

  const UserProfile({
    required this.id,
    required this.email,
    this.displayName,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      displayName: map['display_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
    };
  }
}

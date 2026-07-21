import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';

/// Couche d'accès aux données pour l'authentification.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Pseudonyme stocké dans les métadonnées du compte.
  String? get username =>
      _client.auth.currentUser?.userMetadata?['username'] as String?;

  /// Inscription : le pseudonyme est enregistré dans les métadonnées.
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'username': username.trim()},
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Met à jour le pseudonyme.
  Future<void> updateUsername(String username) async {
    await _client.auth.updateUser(
      UserAttributes(data: {'username': username.trim()}),
    );
  }

  /// Supprime définitivement le compte de l'utilisateur courant
  /// (via la fonction sécurisée `delete_account` côté base), puis déconnecte.
  Future<void> deleteAccount() async {
    await _client.rpc('delete_account');
    await _client.auth.signOut();
  }
}

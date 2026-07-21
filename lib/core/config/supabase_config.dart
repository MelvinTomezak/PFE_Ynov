import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralise l'initialisation de Supabase.
///
/// Les identifiants sont lus depuis le fichier `.env` (non commité) :
/// aucun secret n'est écrit en dur dans le code source (bonne pratique
/// OWASP — A05:2021 Security Misconfiguration).
class SupabaseConfig {
  const SupabaseConfig._();

  static Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL et SUPABASE_ANON_KEY doivent être définis dans le fichier .env',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  /// Accès rapide au client Supabase depuis le reste de l'application.
  static SupabaseClient get client => Supabase.instance.client;
}

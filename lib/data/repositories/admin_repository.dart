import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../models/concert_event.dart';
import '../models/product.dart';
import '../models/track.dart';
import 'content_repository.dart';

/// Écritures réservées aux administrateurs par les politiques RLS Supabase.
class AdminRepository {
  final SupabaseClient _client;
  final ContentRepository _content;

  AdminRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client,
        _content = ContentRepository(client: client ?? SupabaseConfig.client);

  Future<List<Track>> fetchTracks() => _content.fetchTracks();
  Future<List<ConcertEvent>> fetchEvents() => _content.fetchEvents();
  Future<List<Product>> fetchProducts() => _content.fetchProducts();

  Future<void> saveTrack({
    String? id,
    required String title,
    String? album,
    String? coverUrl,
    int? durationSeconds,
  }) async {
    final values = {
      'title': title.trim(),
      'album': _nullable(album),
      'cover_url': _nullable(coverUrl),
      'duration_seconds': durationSeconds,
    };
    if (id == null) {
      await _client.from('tracks').insert(values);
    } else {
      await _client.from('tracks').update(values).eq('id', id);
    }
  }

  Future<void> saveEvent({
    String? id,
    required String title,
    required String venue,
    required String city,
    required DateTime startsAt,
    double? latitude,
    double? longitude,
  }) async {
    final values = {
      'title': title.trim(),
      'venue': venue.trim(),
      'city': city.trim(),
      'starts_at': startsAt.toUtc().toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
    if (id == null) {
      await _client.from('events').insert(values);
    } else {
      await _client.from('events').update(values).eq('id', id);
    }
  }

  Future<void> saveProduct({
    String? id,
    required String name,
    String? category,
    required double price,
    String? imageUrl,
    String? description,
  }) async {
    final values = {
      'name': name.trim(),
      'category': _nullable(category),
      'price': price,
      'image_url': _nullable(imageUrl),
      'description': _nullable(description),
    };
    if (id == null) {
      await _client.from('products').insert(values);
    } else {
      await _client.from('products').update(values).eq('id', id);
    }
  }

  Future<void> deleteTrack(String id) =>
      _client.from('tracks').delete().eq('id', id);
  Future<void> deleteEvent(String id) =>
      _client.from('events').delete().eq('id', id);
  Future<void> deleteProduct(String id) =>
      _client.from('products').delete().eq('id', id);

  String? _nullable(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}

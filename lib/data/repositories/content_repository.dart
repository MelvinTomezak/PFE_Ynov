import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../models/artist.dart';
import '../models/concert_event.dart';
import '../models/product.dart';
import '../models/social_link.dart';
import '../models/track.dart';

abstract interface class ContentDataSource {
  Future<Artist> fetchArtist();
  Future<List<Track>> fetchTracks();
  Future<List<ConcertEvent>> fetchEvents();
  Future<List<SocialLink>> fetchSocialLinks();
  Future<List<Product>> fetchProducts();
}

/// Couche d'accès aux contenus (lecture seule) : biographie, morceaux,
/// événements, liens sociaux et produits de la boutique.
class ContentRepository implements ContentDataSource {
  final SupabaseClient _client;

  ContentRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  @override
  Future<Artist> fetchArtist() async {
    final data = await _client.from('artist').select().eq('id', 1).single();
    return Artist.fromMap(data);
  }

  @override
  Future<List<Track>> fetchTracks() async {
    final data = await _client.from('tracks').select().order('created_at');
    return (data as List)
        .map((e) => Track.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ConcertEvent>> fetchEvents() async {
    final data = await _client.from('events').select().order('starts_at');
    return (data as List)
        .map((e) => ConcertEvent.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SocialLink>> fetchSocialLinks() async {
    final data =
        await _client.from('social_links').select().order('sort_order');
    return (data as List)
        .map((e) => SocialLink.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Product>> fetchProducts() async {
    final data = await _client.from('products').select().order('sort_order');
    return (data as List)
        .map((e) => Product.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}

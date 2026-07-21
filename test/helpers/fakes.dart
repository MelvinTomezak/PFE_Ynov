import 'package:styma/data/models/artist.dart';
import 'package:styma/data/models/concert_event.dart';
import 'package:styma/data/models/product.dart';
import 'package:styma/data/models/social_link.dart';
import 'package:styma/data/models/track.dart';
import 'package:styma/data/models/track_comment.dart';
import 'package:styma/data/repositories/auth_repository.dart';
import 'package:styma/data/repositories/admin_repository.dart';
import 'package:styma/data/repositories/content_repository.dart';
import 'package:styma/data/repositories/music_repository.dart';

/// Double contrôlable du repository de contenus, sans appel à Supabase.
class FakeContentDataSource implements ContentDataSource {
  Artist artist = const Artist(name: 'STYMA', bio: 'Bio');
  List<Track> tracks = [];
  List<ConcertEvent> events = [];
  List<SocialLink> links = [];
  List<Product> products = [];
  Object? error;

  void _throwIfNeeded() {
    if (error != null) throw error!;
  }

  @override
  Future<Artist> fetchArtist() async {
    _throwIfNeeded();
    return artist;
  }

  @override
  Future<List<ConcertEvent>> fetchEvents() async {
    _throwIfNeeded();
    return events;
  }

  @override
  Future<List<Product>> fetchProducts() async {
    _throwIfNeeded();
    return products;
  }

  @override
  Future<List<SocialLink>> fetchSocialLinks() async {
    _throwIfNeeded();
    return links;
  }

  @override
  Future<List<Track>> fetchTracks() async {
    _throwIfNeeded();
    return tracks;
  }
}

/// Double d'authentification qui mémorise les paramètres reçus.
class FakeAuthDataSource implements AuthDataSource {
  Object? error;
  String? email;
  String? password;
  String? username;
  bool signedOut = false;
  bool deleted = false;

  void _throwIfNeeded() {
    if (error != null) throw error!;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    _throwIfNeeded();
    this.email = email;
    this.password = password;
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _throwIfNeeded();
    this.email = email;
    this.password = password;
    this.username = username;
  }

  @override
  Future<void> signOut() async {
    _throwIfNeeded();
    signedOut = true;
  }

  @override
  Future<void> deleteAccount() async {
    _throwIfNeeded();
    deleted = true;
  }
}

/// Double du repository musical pour tester likes et commentaires.
class FakeMusicDataSource implements MusicDataSource {
  List<Track> tracks = [];
  List<TrackComment> comments = [];
  Object? fetchError;
  Object? likeError;
  Object? commentError;
  Track? toggledTrack;
  String? addedContent;
  String? addedUsername;

  @override
  Future<List<Track>> fetchTracks() async {
    if (fetchError != null) throw fetchError!;
    return tracks;
  }

  @override
  Future<void> toggleLike(Track track) async {
    if (likeError != null) throw likeError!;
    toggledTrack = track;
  }

  @override
  Future<List<TrackComment>> fetchComments(String trackId) async {
    if (commentError != null) throw commentError!;
    return comments.where((comment) => comment.trackId == trackId).toList();
  }

  @override
  Future<TrackComment> addComment({
    required String trackId,
    required String content,
    required String username,
  }) async {
    if (commentError != null) throw commentError!;
    addedContent = content;
    addedUsername = username;
    return TrackComment(
      id: 'new-comment',
      trackId: trackId,
      userId: 'user-1',
      username: username,
      content: content,
      createdAt: DateTime(2026),
    );
  }
}

/// Double complet de l'administration pour tester les formulaires CRUD.
class FakeAdminDataSource implements AdminDataSource {
  List<Track> tracks = [];
  List<ConcertEvent> events = [];
  List<Product> products = [];
  Object? error;
  String? deletedTrackId;
  String? deletedEventId;
  String? deletedProductId;
  Map<String, Object?>? savedTrack;
  Map<String, Object?>? savedEvent;
  Map<String, Object?>? savedProduct;

  void _throwIfNeeded() {
    if (error != null) throw error!;
  }

  @override
  Future<List<Track>> fetchTracks() async {
    _throwIfNeeded();
    return tracks;
  }

  @override
  Future<List<ConcertEvent>> fetchEvents() async {
    _throwIfNeeded();
    return events;
  }

  @override
  Future<List<Product>> fetchProducts() async {
    _throwIfNeeded();
    return products;
  }

  @override
  Future<void> saveTrack({
    String? id,
    required String title,
    String? album,
    String? coverUrl,
    int? durationSeconds,
  }) async {
    _throwIfNeeded();
    savedTrack = {
      'id': id,
      'title': title,
      'album': album,
      'coverUrl': coverUrl,
      'durationSeconds': durationSeconds,
    };
  }

  @override
  Future<void> saveEvent({
    String? id,
    required String title,
    required String venue,
    required String city,
    required DateTime startsAt,
    double? latitude,
    double? longitude,
  }) async {
    _throwIfNeeded();
    savedEvent = {
      'id': id,
      'title': title,
      'venue': venue,
      'city': city,
      'startsAt': startsAt,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  Future<void> saveProduct({
    String? id,
    required String name,
    String? category,
    required double price,
    String? imageUrl,
    String? description,
  }) async {
    _throwIfNeeded();
    savedProduct = {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  @override
  Future<void> deleteTrack(String id) async {
    _throwIfNeeded();
    deletedTrackId = id;
  }

  @override
  Future<void> deleteEvent(String id) async {
    _throwIfNeeded();
    deletedEventId = id;
  }

  @override
  Future<void> deleteProduct(String id) async {
    _throwIfNeeded();
    deletedProductId = id;
  }
}

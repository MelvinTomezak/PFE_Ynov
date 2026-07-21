import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../models/track.dart';
import '../models/track_comment.dart';
import 'content_repository.dart';

abstract interface class MusicDataSource {
  Future<List<Track>> fetchTracks();
  Future<void> toggleLike(Track track);
  Future<List<TrackComment>> fetchComments(String trackId);
  Future<TrackComment> addComment({
    required String trackId,
    required String content,
    required String username,
  });
}

/// Accès aux morceaux et aux interactions sociales associées.
class MusicRepository implements MusicDataSource {
  final SupabaseClient _client;
  final ContentRepository _contentRepository;

  MusicRepository(
      {SupabaseClient? client, ContentRepository? contentRepository})
      : _client = client ?? SupabaseConfig.client,
        _contentRepository = contentRepository ??
            ContentRepository(client: client ?? SupabaseConfig.client);

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<Track>> fetchTracks() async {
    final tracks = await _contentRepository.fetchTracks();

    // Les morceaux restent visibles si la migration sociale n'a pas encore
    // été appliquée sur une ancienne instance Supabase.
    try {
      final results = await Future.wait([
        _client.from('track_likes').select('track_id,user_id'),
        _client.from('track_comments').select('track_id'),
      ]);
      final likes = results[0] as List;
      final comments = results[1] as List;

      return tracks.map((track) {
        final trackLikes = likes.where((row) => row['track_id'] == track.id);
        return track.copyWith(
          likeCount: trackLikes.length,
          commentCount:
              comments.where((row) => row['track_id'] == track.id).length,
          isLiked: trackLikes.any((row) => row['user_id'] == _userId),
        );
      }).toList();
    } catch (_) {
      return tracks;
    }
  }

  @override
  Future<void> toggleLike(Track track) async {
    if (track.isLiked) {
      await _client
          .from('track_likes')
          .delete()
          .eq('track_id', track.id)
          .eq('user_id', _userId);
    } else {
      await _client.from('track_likes').insert({
        'track_id': track.id,
        'user_id': _userId,
      });
    }
  }

  @override
  Future<List<TrackComment>> fetchComments(String trackId) async {
    final data = await _client
        .from('track_comments')
        .select()
        .eq('track_id', trackId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((row) => TrackComment.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TrackComment> addComment({
    required String trackId,
    required String content,
    required String username,
  }) async {
    final data = await _client
        .from('track_comments')
        .insert({
          'track_id': trackId,
          'user_id': _userId,
          'username': username,
          'content': content.trim(),
        })
        .select()
        .single();
    return TrackComment.fromMap(data);
  }
}

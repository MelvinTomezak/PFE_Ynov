import 'package:flutter/foundation.dart';

import '../../../core/utils/load_status.dart';
import '../../../data/models/track.dart';
import '../../../data/models/track_comment.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/music_repository.dart';

class MusicViewModel extends ChangeNotifier {
  final MusicDataSource _repository;
  final String Function() _username;

  MusicViewModel({MusicDataSource? repository, String Function()? username})
      : _repository = repository ?? MusicRepository(),
        _username =
            username ?? (() => AuthRepository().username ?? 'Utilisateur');

  LoadStatus status = LoadStatus.idle;
  List<Track> tracks = [];
  String? errorMessage;
  bool interactionInProgress = false;

  Future<void> load() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      tracks = await _repository.fetchTracks();
      status = LoadStatus.success;
    } catch (_) {
      errorMessage = 'Impossible de charger les morceaux.';
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<bool> toggleLike(Track track) async {
    if (interactionInProgress) return false;
    interactionInProgress = true;
    final index = tracks.indexWhere((item) => item.id == track.id);
    if (index == -1) {
      interactionInProgress = false;
      return false;
    }
    final updated = track.copyWith(
      isLiked: !track.isLiked,
      likeCount: track.isLiked
          ? (track.likeCount > 0 ? track.likeCount - 1 : 0)
          : track.likeCount + 1,
    );
    tracks[index] = updated;
    notifyListeners();

    try {
      await _repository.toggleLike(track);
      return true;
    } catch (_) {
      tracks[index] = track;
      return false;
    } finally {
      interactionInProgress = false;
      notifyListeners();
    }
  }

  Future<List<TrackComment>> fetchComments(String trackId) {
    return _repository.fetchComments(trackId);
  }

  Future<TrackComment?> addComment(Track track, String content) async {
    try {
      final comment = await _repository.addComment(
        trackId: track.id,
        content: content,
        username: _username(),
      );
      final index = tracks.indexWhere((item) => item.id == track.id);
      if (index == -1) return null;
      tracks[index] = tracks[index].copyWith(
        commentCount: tracks[index].commentCount + 1,
      );
      notifyListeners();
      return comment;
    } catch (_) {
      return null;
    }
  }
}

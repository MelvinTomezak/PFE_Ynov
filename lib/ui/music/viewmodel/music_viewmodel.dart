import 'package:flutter/foundation.dart';

import '../../../core/utils/load_status.dart';
import '../../../data/models/track.dart';
import '../../../data/repositories/content_repository.dart';

class MusicViewModel extends ChangeNotifier {
  final ContentRepository _repository;

  MusicViewModel({ContentRepository? repository})
      : _repository = repository ?? ContentRepository();

  LoadStatus status = LoadStatus.idle;
  List<Track> tracks = [];
  String? errorMessage;

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
}

import 'package:flutter/foundation.dart';

import '../../../core/utils/load_status.dart';
import '../../../data/models/concert_event.dart';
import '../../../data/models/track.dart';
import '../../../data/repositories/content_repository.dart';

/// ViewModel de l'accueil : rassemble les dernières actualités.
class HomeViewModel extends ChangeNotifier {
  final ContentDataSource _repository;

  HomeViewModel({ContentDataSource? repository})
      : _repository = repository ?? ContentRepository();

  LoadStatus status = LoadStatus.idle;
  String? errorMessage;

  List<Track> latestTracks = [];
  ConcertEvent? nextEvent;

  Future<void> load() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      final tracks = await _repository.fetchTracks();
      final events = await _repository.fetchEvents();

      // Derniers sons : les 3 plus récents (la liste est triée par date d'ajout).
      latestTracks = tracks.reversed.take(3).toList();
      // Prochain événement : le premier à venir (liste triée par date).
      nextEvent = events.isNotEmpty ? events.first : null;

      status = LoadStatus.success;
    } catch (_) {
      errorMessage = 'Impossible de charger les actualités.';
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}

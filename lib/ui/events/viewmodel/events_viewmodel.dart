import 'package:flutter/foundation.dart';

import '../../../core/utils/load_status.dart';
import '../../../data/models/concert_event.dart';
import '../../../data/repositories/content_repository.dart';

class EventsViewModel extends ChangeNotifier {
  final ContentDataSource _repository;

  EventsViewModel({ContentDataSource? repository})
      : _repository = repository ?? ContentRepository();

  LoadStatus status = LoadStatus.idle;
  List<ConcertEvent> events = [];
  String? errorMessage;

  Future<void> load() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      events = await _repository.fetchEvents();
      status = LoadStatus.success;
    } catch (_) {
      errorMessage = 'Impossible de charger les événements.';
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}

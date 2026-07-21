import 'package:flutter/foundation.dart';

import '../../../core/utils/load_status.dart';
import '../../../data/models/artist.dart';
import '../../../data/repositories/content_repository.dart';

class ArtistViewModel extends ChangeNotifier {
  final ContentRepository _repository;

  ArtistViewModel({ContentRepository? repository})
      : _repository = repository ?? ContentRepository();

  LoadStatus status = LoadStatus.idle;
  Artist? artist;
  String? errorMessage;

  Future<void> load() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      artist = await _repository.fetchArtist();
      status = LoadStatus.success;
    } catch (_) {
      errorMessage = 'Impossible de charger la biographie.';
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}

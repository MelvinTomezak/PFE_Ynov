import 'package:flutter/foundation.dart';

import '../../../core/utils/load_status.dart';
import '../../../data/models/social_link.dart';
import '../../../data/repositories/content_repository.dart';

class LinktreeViewModel extends ChangeNotifier {
  final ContentDataSource _repository;

  LinktreeViewModel({ContentDataSource? repository})
      : _repository = repository ?? ContentRepository();

  LoadStatus status = LoadStatus.idle;
  String? errorMessage;

  List<SocialLink> links = [];
  String? photoUrl;

  Future<void> load() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      final artist = await _repository.fetchArtist();
      photoUrl = (artist.imageUrl != null && artist.imageUrl!.isNotEmpty)
          ? artist.imageUrl
          : null;
      links = await _repository.fetchSocialLinks();
      status = LoadStatus.success;
    } catch (_) {
      errorMessage = 'Impossible de charger les liens.';
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}

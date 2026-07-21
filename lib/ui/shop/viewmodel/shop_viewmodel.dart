import 'package:flutter/foundation.dart';

import '../../../core/utils/load_status.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/content_repository.dart';

class ShopViewModel extends ChangeNotifier {
  final ContentDataSource _repository;

  ShopViewModel({ContentDataSource? repository})
      : _repository = repository ?? ContentRepository();

  LoadStatus status = LoadStatus.idle;
  List<Product> products = [];
  String? errorMessage;

  Future<void> load() async {
    status = LoadStatus.loading;
    notifyListeners();
    try {
      products = await _repository.fetchProducts();
      status = LoadStatus.success;
    } catch (_) {
      errorMessage = 'Impossible de charger la boutique.';
      status = LoadStatus.error;
    }
    notifyListeners();
  }
}

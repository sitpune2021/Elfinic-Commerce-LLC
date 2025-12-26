

import 'package:flutter/cupertino.dart';

import '../model/ProductsResponse.dart';
import '../services/api_service.dart';

class SimilarProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String _error = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchSimilarProducts(int productId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    debugPrint("🔵 [PROVIDER] Fetching similar products for ID: $productId");

    try {
      _products = await ApiService.getSimilarProducts(productId);
      debugPrint("🟢 [PROVIDER] Similar products count: ${_products.length}");
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ [PROVIDER] Error: $_error");
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _products = [];
    notifyListeners();
  }
}


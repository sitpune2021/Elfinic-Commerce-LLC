import 'package:flutter/cupertino.dart';

import '../model/ProductsResponse.dart';
import '../services/api_service.dart';

class ArrivalProductProvider with ChangeNotifier {
  List<Product> _arrivalProducts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;

  List<Product> get arrivalProducts => _arrivalProducts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;

  bool get hasMore => _currentPage < _lastPage;

  /// ✅ Initial Load
  Future<void> fetchArrivalProducts() async {
    _isLoading = true;
    _currentPage = 1;
    notifyListeners();

    try {
      final result =
      await ApiService.fetchProductsBySectionPaginated(
        section: "arrival",
        page: _currentPage,
      );

      _arrivalProducts = result["products"];
      _lastPage = result["last_page"];
    } catch (e) {
      print("❌ Arrival Load Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ Pagination Load
  Future<void> loadMoreArrivalProducts() async {
    if (_isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;

      final result =
      await ApiService.fetchProductsBySectionPaginated(
        section: "arrival",
        page: _currentPage,
      );

      final List<Product> newProducts = result["products"];
      _arrivalProducts.addAll(newProducts);
    } catch (e) {
      print("❌ Arrival Pagination Error: $e");
    }

    _isLoadingMore = false;
    notifyListeners();
  }
}


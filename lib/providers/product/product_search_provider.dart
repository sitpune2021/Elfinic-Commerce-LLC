import 'package:elfinic_commerce_llc/model/search_product_list_model.dart';
import 'package:elfinic_commerce_llc/services/product_api_service.dart';
import 'package:flutter/foundation.dart';

class ProductSearchProvider extends ChangeNotifier {
  final ProductApiService _api = ProductApiService();

  List<Product> products = [];

  int page = 1;
  final int perPage = 10;

  bool isLoading = false;
  bool isLoadMore = false;
  bool hasMoreData = true;

  String keyword = '';

  /// INITIAL LOAD
  Future<void> loadInitial(String value) async {
    if (value.trim().isEmpty) {
      debugPrint("PROVIDER: Empty search → clear data");
      products.clear();
      hasMoreData = false;
      notifyListeners();
      return;
    }
    
    debugPrint("========== PROVIDER INITIAL LOAD ==========");
    keyword = value;
    page = 1;
    hasMoreData = true;
    products.clear();

    isLoading = true;
    notifyListeners();

    debugPrint("Initial Page : $page");

    try {
      final response = await _api.getProducts(
        name: keyword,
        page: page,
        perPage: perPage,
      );

      products = response.data;
      hasMoreData = response.data.length == perPage;

      debugPrint("Loaded Items : ${products.length}");
      debugPrint("Has More     : $hasMoreData");
    } catch (e) {
      debugPrint("INITIAL LOAD ERROR : $e");
      hasMoreData = false;
    }

    isLoading = false;
    notifyListeners();
  }

  /// LOAD MORE
  Future<void> loadMore() async {
    if (isLoadMore || !hasMoreData) {
      debugPrint("LOAD MORE SKIPPED");
      return;
    }

    isLoadMore = true;
    page++;

    debugPrint("========== PROVIDER LOAD MORE ==========");
    debugPrint("Next Page : $page");

    notifyListeners();

    try {
      final response = await _api.getProducts(
        name: keyword,
        page: page,
        perPage: perPage,
      );

      if (response.data.isEmpty) {
        debugPrint("NO MORE DATA");
        hasMoreData = false;
      } else {
        products.addAll(response.data);
        debugPrint("Total Items : ${products.length}");
      }
    } catch (e) {
      debugPrint("LOAD MORE ERROR : $e");
      page--;
    }

    isLoadMore = false;
    notifyListeners();
  }
}

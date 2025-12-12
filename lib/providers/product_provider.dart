import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/ProductsResponse.dart';


import '../services/api_service.dart';
class ProductProvider with ChangeNotifier {
  bool isLoading = true;
  bool isLoadingMore = false;
  String? error;
  List<Product> products = [];

  // Pagination variables
  int currentPage = 1;
  int perPage = 10;
  bool hasMore = true;
  bool isInitialLoad = true;

  Map<int, bool> favoriteStatus = {};

  /// Initial load of products
  Future<void> fetchProducts({String? productId, bool loadMore = false}) async {
    print("🔵 Provider → fetchProducts() - Page: $currentPage, LoadMore: $loadMore");

    if (loadMore) {
      if (!hasMore || isLoadingMore) return;
      isLoadingMore = true;
    } else {
      if (isInitialLoad) {
        isLoading = true;
        error = null;
      }
    }

    notifyListeners();

    try {
      final newProducts = await ApiService.fetchProducts(
        productId: productId,
        perPage: perPage,
        page: currentPage,
      );

      if (loadMore) {
        // Append to existing list when loading more
        products.addAll(newProducts);
      } else {
        // Replace products on initial load
        products = newProducts;
        isInitialLoad = false;
      }

      // Check if we have more products to load
      hasMore = newProducts.length == perPage;

      print("✅ Products Loaded: ${newProducts.length} | Total: ${products.length} | Has More: $hasMore | Page: $currentPage");
    } catch (e) {
      error = e.toString();
      print("❌ Provider Error: $error");

      if (loadMore) {
        currentPage--; // Revert page increment on error
      }
    }

    isLoading = false;
    isLoadingMore = false;
    notifyListeners();
  }

  /// Load more products for pagination
  Future<void> loadMoreProducts() async {
    if (isLoadingMore || !hasMore) {
      print("⚠️ Cannot load more: isLoadingMore=$isLoadingMore, hasMore=$hasMore");
      return;
    }

    print("🔵 Provider → loadMoreProducts() - Incrementing page to: ${currentPage + 1}");

    currentPage++;
    await fetchProducts(loadMore: true);
  }

  /// Load next page for horizontal scrolling
  Future<void> loadNextPage() async {
    if (isLoadingMore || !hasMore) return;

    print("🔵 Provider → loadNextPage() - Loading page ${currentPage + 1}");

    currentPage++;
    await fetchProducts(loadMore: true);
  }

  /// Refresh products (pull to refresh)
  Future<void> refreshProducts() async {
    print("🔵 Provider → refreshProducts()");

    // Reset pagination state
    currentPage = 1;
    hasMore = true;
    isInitialLoad = true;

    await fetchProducts();

    print("✅ Products Refreshed");
  }

  /// Reset pagination state
  void resetPagination() {
    currentPage = 1;
    hasMore = true;
    isInitialLoad = true;
    products.clear();
  }

  /// Fetch single product
  Future<Product?> fetchSingleProduct(int productId) async {
    print("🔵 Provider → fetchSingleProduct(productId: $productId)");

    try {
      isLoading = true;
      notifyListeners();

      final product = await ApiService.fetchSingleProduct(productId);

      if (product != null) {
        print("✅ Single Product Loaded: ${product.name}");
      } else {
        print("⚠️ No product found in Provider");
      }

      isLoading = false;
      notifyListeners();
      return product;
    } catch (e) {
      error = e.toString();
      print("❌ Provider Error: $error");

      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void toggleFavorite(int productId) {
    favoriteStatus[productId] = !(favoriteStatus[productId] ?? false);
    notifyListeners();
  }

  bool isFavorite(int productId) {
    return favoriteStatus[productId] ?? false;
  }
}



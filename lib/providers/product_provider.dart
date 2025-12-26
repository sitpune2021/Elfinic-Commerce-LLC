import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/ProductsResponse.dart';


import '../services/api_service.dart';
class ProductProvider with ChangeNotifier {
  bool isLoading = true;
  bool isLoadingMore = false;
  bool isLoadingSimilar = false;
  String? error;
  List<Product> products = [];
  List<Product> similarProducts = [];

  // Pagination variables for main products
  int currentPage = 1;
  int perPage = 10;
  bool hasMore = true;
  bool isInitialLoad = true;

  // Similar products pagination
  int similarCurrentPage = 1;
  bool hasMoreSimilar = true;

  Map<int, bool> favoriteStatus = {};


  int page = 1;

  Future<void> fetchFilteredProducts({
    required String categoryName,
    required String subcategoryName,
    bool reset = false,
  }) async {
    if (isLoading) return;

    if (reset) {
      products.clear();
      page = 1;
      hasMore = true;
    }

    if (!hasMore) return;

    isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        "${ApiService.baseUrl}/api/getProductsFilterList"
            "?category_id=$categoryName"
            "&subcategory_id=$subcategoryName"
            "&page=$page",
      );

      final response = await http.get(url);
      final json = jsonDecode(response.body);

      if (json['status'] == 'success') {
        /// ✅ SAFELY HANDLE NULL OR NON-LIST DATA
        final rawData = json['data'];

        final List listData =
        rawData is List ? rawData : <dynamic>[];

        products.addAll(
          listData
              .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );

        /// ✅ Pagination safe check
        final pagination = json['pagination'];
        if (pagination != null) {
          final int lastPage = pagination['last_page'] ?? page;
          hasMore = page < lastPage;
          page++;
        } else {
          hasMore = false;
        }
      } else {
        hasMore = false;
      }
    } catch (e) {
      debugPrint("❌ fetchFilteredProducts error: $e");
      hasMore = false;
    }

    isLoading = false;
    notifyListeners();
  }


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

  /// Fetch similar products based on category
  Future<void> fetchSimilarProducts({
    required String category,
    int excludeProductId = 0,
    int perPage = 10,
    bool loadMore = false,
  }) async {
    print("🔵 Provider → fetchSimilarProducts() - Category: $category, Exclude: $excludeProductId");

    if (loadMore) {
      if (!hasMoreSimilar || isLoadingSimilar) return;
      isLoadingSimilar = true;
    } else {
      isLoadingSimilar = true;
      similarCurrentPage = 1;
      hasMoreSimilar = true;
      similarProducts.clear();
    }

    notifyListeners();

    try {
      // Use the same API endpoint but filter by category
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/getProductsList?category_id=$category&per_page=$perPage&page=$similarCurrentPage',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status'] == 'success') {
          final List<dynamic> productData = data['data'] ?? [];

          // Filter out the current product and convert to Product objects
          final List<Product> newSimilarProducts = productData
              .where((productJson) => productJson['id'] != excludeProductId)
              .map((productJson) => Product.fromJson(productJson))
              .toList();

          if (loadMore) {
            similarProducts.addAll(newSimilarProducts);
          } else {
            similarProducts = newSimilarProducts;
          }

          // Update pagination
          hasMoreSimilar = newSimilarProducts.length == perPage;

          print("✅ Similar Products Loaded: ${newSimilarProducts.length} | Total: ${similarProducts.length} | Has More: $hasMoreSimilar");
        } else {
          throw Exception('Failed to fetch similar products: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load similar products: ${response.statusCode}');
      }
    } catch (e) {
      error = e.toString();
      print("❌ Similar Products Error: $error");

      if (loadMore) {
        similarCurrentPage--; // Revert page increment on error
      }
    }

    isLoadingSimilar = false;
    notifyListeners();
  }

  /// Load more similar products
  Future<void> loadMoreSimilarProducts({
    required String category,
    int excludeProductId = 0,
  }) async {
    if (isLoadingSimilar || !hasMoreSimilar) {
      print("⚠️ Cannot load more similar products: isLoadingSimilar=$isLoadingSimilar, hasMoreSimilar=$hasMoreSimilar");
      return;
    }

    print("🔵 Provider → loadMoreSimilarProducts() - Loading page ${similarCurrentPage + 1}");

    similarCurrentPage++;
    await fetchSimilarProducts(
      category: category,
      excludeProductId: excludeProductId,
      loadMore: true,
    );
  }

  /// Get similar products for a specific product (helper method)
  List<Product> getSimilarProductsFor(Product currentProduct) {
    // First, try to get from cached similar products
    if (similarProducts.isNotEmpty) {
      return similarProducts;
    }

    // Otherwise, filter from main products list
    return products.where((product) {
      final isSameCategory = product.category == currentProduct.category;
      final isNotCurrent = product.id != currentProduct.id;
      return isSameCategory && isNotCurrent;
    }).take(10).toList();
  }

  /// Clear similar products cache
  void clearSimilarProducts() {
    similarProducts.clear();
    similarCurrentPage = 1;
    hasMoreSimilar = true;
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
/*class ProductProvider with ChangeNotifier {
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
}*/



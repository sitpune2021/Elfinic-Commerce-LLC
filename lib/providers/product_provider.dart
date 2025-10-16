import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/ProductsResponse.dart';


import 'package:flutter/material.dart';
import '../model/ProductsResponse.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  bool isLoading = true;
  String? error;
  List<Product> products = [];

  /// Map to store favorite status per product
  Map<int, bool> favoriteStatus = {};

  /// Fetch products from API
  Future<void> fetchProducts() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      products = await ApiService.fetchProducts();

      /// Initialize favoriteStatus map
      for (var product in products) {
        favoriteStatus[product.id] = false; // default not favorite
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  /// Toggle favorite status
  void toggleFavorite(int productId) {
    favoriteStatus[productId] = !(favoriteStatus[productId] ?? false);
    notifyListeners();
  }

  /// Check if a product is favorite
  bool isFavorite(int productId) {
    return favoriteStatus[productId] ?? false;
  }
}

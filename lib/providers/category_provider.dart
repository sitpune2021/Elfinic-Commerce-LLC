import 'package:flutter/foundation.dart';

import '../model/CategoriesResponse.dart';
import '../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch categories using ApiService
  Future<void> fetchCategories() async {

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await ApiService.fetchCategories();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearCategories() {
    _categories = [];
    _error = null;
    notifyListeners();
  }
}

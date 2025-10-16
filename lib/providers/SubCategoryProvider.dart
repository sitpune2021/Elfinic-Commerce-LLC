import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/SubcategoriesResponse.dart';
import '../services/api_service.dart';


class SubCategoryProvider with ChangeNotifier {
  List<SubCategoryModel> _subcategories = [];
  bool _isLoading = false;
  String? _error;

  List<SubCategoryModel> get subcategories => _subcategories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSubcategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subcategories = await ApiService.fetchSubcategories();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}

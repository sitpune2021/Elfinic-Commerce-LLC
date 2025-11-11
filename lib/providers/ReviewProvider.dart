import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/Review.dart';
import '../services/api_service.dart';

class ReviewProvider with ChangeNotifier {
  List<Review> _reviews = [];
  bool _isLoading = false;
  String _error = '';

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Add review method
  Future<bool> addReview({
    required int productId,
    required int rating,
    required String review,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString('user_id');
      final userId = int.tryParse(userIdString ?? '0') ?? 0;

      if (userId == 0) {
        _error = 'Please login to add review';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Prepare request data
      final requestData = {
        'product_id': productId,
        'user_id': userId,
        'rating': rating,
        'review': review,
      };

      // Use ApiService URL
      final url = ApiService.addReview;

      // Print request details
      print('🟡 REVIEW API REQUEST:');
      print('🟡 URL: $url');
      print('🟡 Method: POST');
      print('🟡 Headers: {Content-Type: application/json}');
      print('🟡 Request Body: ${jsonEncode(requestData)}');
      print('🟡 User ID: $userId');
      print('🟡 Product ID: $productId');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      // Print response details
      print('🟢 REVIEW API RESPONSE:');
      print('🟢 Status Code: ${response.statusCode}');
      print('🟢 Response Body: ${response.body}');
      print('🟢 Response Headers: ${response.headers}');

      _isLoading = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('🟢 Parsed Response Data: $data');

        if (data['status'] == 'success') {
          print('✅ Review added successfully!');

          // Add the new review to local list
          final newReview = Review(
            id: DateTime.now().millisecondsSinceEpoch,
            productId: productId,
            userId: userId,
            rating: rating,
            review: review,
            createdAt: DateTime.now().toIso8601String(),
            userPhoto: '',
          );

          _reviews.insert(0, newReview);
          notifyListeners();
          return true;
        } else {
          _error = data['message'] ?? 'Failed to add review';
          print('❌ API Error: $_error');
          notifyListeners();
          return false;
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
        print('❌ HTTP Error: $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Network error: $e';
      print('❌ Exception: $e');
      notifyListeners();
      return false;
    }
  }

  // Fetch product reviews with detailed information
  Future<Map<String, dynamic>?> fetchProductReviews(int productId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // Use ApiService URL
      final url = ApiService.productReviews;

      // Print request details
      print('🟡 PRODUCT REVIEWS API REQUEST:');
      print('🟡 URL: $url');
      print('🟡 Method: POST');
      print('🟡 Product ID: $productId');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id': productId,
        }),
      );

      // Print response details
      print('🟢 PRODUCT REVIEWS API RESPONSE:');
      print('🟢 Status Code: ${response.statusCode}');
      print('🟢 Response Body: ${response.body}');

      _isLoading = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('🟢 Parsed Product Reviews Data: $data');

        if (data['status'] == 'success') {
          print('✅ Product reviews fetched successfully!');

          // Update reviews list
          if (data['reviews'] != null) {
            _reviews = (data['reviews'] as List)
                .map((item) {
              print('🟢 Review Item: $item');
              return Review.fromJson(item);
            })
                .toList();
          }

          notifyListeners();
          return data;
        } else {
          _error = data['message'] ?? 'Failed to fetch product reviews';
          print('❌ API Error: $_error');
          notifyListeners();
          return null;
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
        print('❌ HTTP Error: $_error');
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Network error: $e';
      print('❌ Exception: $e');
      notifyListeners();
      return null;
    }
  }


  // Clear all reviews
  void clearReviews() {
    _reviews.clear();
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Get reviews for specific product
  List<Review> getReviewsForProduct(int productId) {
    return _reviews.where((review) => review.productId == productId).toList();
  }

  // Check if user has already reviewed this product
  Future<bool> hasUserReviewed(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('user_id');
    final userId = int.tryParse(userIdString ?? '0') ?? 0;

    if (userId == 0) return false;

    return _reviews.any((review) =>
    review.productId == productId && review.userId == userId
    );
  }

  // Alternative synchronous version
  bool hasUserReviewedSync(int productId, int userId) {
    if (userId == 0) return false;

    return _reviews.any((review) =>
    review.productId == productId && review.userId == userId
    );
  }

  // Calculate average rating and distribution
  Map<String, dynamic> calculateRatingStats(List<Review> reviews) {
    if (reviews.isEmpty) {
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        'percentageDistribution': {5: 0.0, 4: 0.0, 3: 0.0, 2: 0.0, 1: 0.0},
      };
    }

    int totalReviews = reviews.length;
    double totalRating = 0;
    Map<int, int> ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (var review in reviews) {
      totalRating += review.rating;
      ratingDistribution[review.rating] = (ratingDistribution[review.rating] ?? 0) + 1;
    }

    double averageRating = totalRating / totalReviews;

    Map<int, double> percentageDistribution = {};
    ratingDistribution.forEach((rating, count) {
      percentageDistribution[rating] = (count / totalReviews) * 100;
    });

    return {
      'averageRating': double.parse(averageRating.toStringAsFixed(1)),
      'totalReviews': totalReviews,
      'ratingDistribution': ratingDistribution,
      'percentageDistribution': percentageDistribution,
    };
  }

  // Get reviews for specific product with stats
  Map<String, dynamic> getProductReviewStats(int productId) {
    final productReviews = _reviews.where((review) => review.productId == productId).toList();
    final stats = calculateRatingStats(productReviews);

    return {
      ...stats,
      'reviews': productReviews,
    };
  }
}

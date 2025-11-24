import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/ProductsResponse.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class RecentViewProvider with ChangeNotifier {
  List<Product> _recentViews = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get recentViews => _recentViews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Helper method to get auth token and user ID from SharedPreferences
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    if (kDebugMode) {
      print('🔐 Auth Details from SharedPreferences:');
      print('Token: ${token != null ? '***${token.substring(token.length - 5)}' : 'null'}');
    }

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (token != null) 'Accept': 'application/json',
    };
  }

  // Helper method to get user ID from SharedPreferences
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userIdString = prefs.getString('user_id');

    if (userIdString != null && userIdString.isNotEmpty) {
      return int.tryParse(userIdString);
    }

    if (kDebugMode) {
      print('❌ No user ID found in SharedPreferences');
    }
    return null;
  }

  // Add recent view - POST method (working)
  Future<void> addRecentView(int productId) async {
    final int? userId = await _getUserId();

    if (userId == null) {
      if (kDebugMode) {
        print('❌ Cannot add recent view: User not logged in');
      }
      return;
    }

    final String url = '${ApiService.baseUrl}/api/addRecentView';
    final Map<String, dynamic> requestBody = {
      'product_id': productId,
      'user_id': userId,
    };

    final headers = await _getAuthHeaders();

    if (kDebugMode) {
      print('=== ADD RECENT VIEW API CALL ===');
      print('URL: $url');
      print('Request Body: ${json.encode(requestBody)}');
      print('Headers: $headers');
      print('Method: POST');
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      if (kDebugMode) {
        print('=== ADD RECENT VIEW RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'Success') {
          if (kDebugMode) {
            print('✅ Recent view added successfully for product: $productId');
            print('Message: ${data['message']}');
          }

          // Refresh the recent views list after adding
          await getRecentViews();
        } else {
          if (kDebugMode) {
            print('❌ API returned error status');
            print('Status: ${data['status']}');
            print('Message: ${data['message']}');
          }
          throw Exception(data['message'] ?? 'Failed to add recent view');
        }
      } else {
        if (kDebugMode) {
          print('❌ HTTP Error: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        throw Exception('Failed to add recent view: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in addRecentView: $e');
      }
    } finally {
      if (kDebugMode) {
        print('=== ADD RECENT VIEW COMPLETED ===');
      }
    }
  }

  // Get recent views - GET with query parameters (working)
  Future<void> getRecentViews() async {
    final int? userId = await _getUserId();

    if (userId == null) {
      if (kDebugMode) {
        print('❌ Cannot fetch recent views: User not logged in');
      }
      _recentViews = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Use GET with query parameter (this is working based on your logs)
    final String url = '${ApiService.baseUrl}/api/getRecentViews?user_id=$userId';
    final headers = await _getAuthHeaders();

    if (kDebugMode) {
      print('=== GET RECENT VIEWS API CALL ===');
      print('URL: $url');
      print('User ID: $userId');
      print('Headers: $headers');
      print('Method: GET');
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (kDebugMode) {
        print('=== GET RECENT VIEWS RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          if (kDebugMode) {
            print('✅ Recent views fetched successfully');
            print('Number of items: ${data['data']?.length ?? 0}');
          }

          // Extract data from response
          List<dynamic> recentViewData = data['data'] ?? [];

          if (kDebugMode && recentViewData.isNotEmpty) {
            print('=== RAW DATA STRUCTURE ===');
            for (int i = 0; i < recentViewData.length; i++) {
              print('Item $i keys: ${recentViewData[i].keys}');
              print('Product ID: ${recentViewData[i]['id']}');
              print('Product Name: ${recentViewData[i]['name']}');
            }
          }

          // Map the products directly from the data array
          _recentViews = recentViewData
              .map((item) {
            if (kDebugMode) {
              print('Mapping item: ${item['name']} (ID: ${item['id']})');
            }
            return Product.fromJson(item);
          })
              .where((product) => product.id != null)
              .toList();

          if (kDebugMode) {
            print('✅ Mapped ${_recentViews.length} recent views');
            for (var product in _recentViews) {
              print(' - ${product.name} (ID: ${product.id})');
            }
          }
        } else {
          if (kDebugMode) {
            print('❌ API returned false status');
            print('Status: ${data['status']}');
            print('Message: ${data['message']}');
          }
          throw Exception('Failed to fetch recent views: ${data['message']}');
        }
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          print('❌ Unauthorized - Token may be invalid or expired');
        }
        _error = 'Authentication required';
        _recentViews = [];
      } else {
        if (kDebugMode) {
          print('❌ HTTP Error: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        throw Exception('Failed to fetch recent views: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('❌ Exception in getRecentViews: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('=== GET RECENT VIEWS COMPLETED ===');
        print('Loading: $_isLoading');
        print('Error: $_error');
        print('Recent Views Count: ${_recentViews.length}');
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final userId = await _getUserId();
    return userId != null;
  }

  // Helper method to print current state
  void printState() {
    if (kDebugMode) {
      print('=== RECENT VIEW PROVIDER STATE ===');
      print('Loading: $_isLoading');
      print('Error: $_error');
      print('Recent Views Count: ${_recentViews.length}');
      for (var product in _recentViews) {
        print(' - ${product.name} (ID: ${product.id})');
      }
      print('==================================');
    }
  }
}
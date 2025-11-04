// providers/wishlist_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// providers/wishlist_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// wishlist_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class WishlistProvider with ChangeNotifier {
  List<int> _wishlistItems = [];

  List<int> get wishlistItems => _wishlistItems;

  bool isInWishlist(int productId) => _wishlistItems.contains(productId);

  // ✅ Initialize wishlist from SharedPreferences
  WishlistProvider() {
    _loadWishlistFromStorage();
  }


  // Add a method to refresh wishlist and notify all listeners
  Future<void> refreshWishlist() async {
    await fetchWishlist();
    notifyListeners(); // This will update ALL consumers
  }




  // ✅ Load wishlist from SharedPreferences
  Future<void> _loadWishlistFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistString = prefs.getString('wishlist_items');

      if (wishlistString != null && wishlistString.isNotEmpty) {
        final List<dynamic> wishlistData = jsonDecode(wishlistString);
        _wishlistItems = wishlistData.map<int>((item) => item as int).toList();
        print('📥 Loaded wishlist from storage: $_wishlistItems');
        notifyListeners();
      }
    } catch (e) {
      print('⚠️ Error loading wishlist from storage: $e');
    }
  }

  // ✅ Save wishlist to SharedPreferences
  Future<void> _saveWishlistToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('wishlist_items', jsonEncode(_wishlistItems));
      print('💾 Saved wishlist to storage: $_wishlistItems');
    } catch (e) {
      print('⚠️ Error saving wishlist to storage: $e');
    }
  }

  // ✅ Add to Wishlist with persistence
  Future<bool> addToWishlist(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    final userIdString = prefs.getString('user_id');
    final userId = int.tryParse(userIdString ?? '0') ?? 0;

    if (userId == 0) {
      print('❌ Wishlist Add Failed: User not logged in');
      return false;
    }

    final url = Uri.parse('https://admin.elfinic.com/api/wishlist/add');
    print('📤 Wishlist Add URL: $url');
    print('📦 Request Body: {"user_id": $userId, "product_id": $productId}');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "user_id": userId,
          "product_id": productId,
        }),
      );

      print('✅ Wishlist Add Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          if (!_wishlistItems.contains(productId)) {
            _wishlistItems.add(productId);
            await _saveWishlistToStorage(); // Save to storage
            notifyListeners();
          }
          return true;
        }
      }
      return false;
    } catch (e) {
      print('⚠️ Wishlist Add Error: $e');
      return false;
    }
  }

  // ✅ Remove from Wishlist with persistence
  Future<bool> removeFromWishlist(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    final userIdString = prefs.getString('user_id');
    final userId = int.tryParse(userIdString ?? '0') ?? 0;

    if (userId == 0) {
      print('❌ Wishlist Remove Failed: User not logged in');
      return false;
    }

    final url = Uri.parse('https://admin.elfinic.com/api/wishlist/remove');
    print('📤 Wishlist Remove URL: $url');
    print('📦 Request Body: {"user_id": $userId, "product_id": $productId}');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "user_id": userId,
          "product_id": productId,
        }),
      );

      print('✅ Wishlist Remove Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          _wishlistItems.remove(productId);
          await _saveWishlistToStorage(); // Save to storage
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('⚠️ Wishlist Remove Error: $e');
      return false;
    }
  }

  // 🔁 Toggle wishlist (add/remove based on current state)
  // Update your toggle method to automatically refresh
  Future<bool> toggleWishlist(int productId) async {
    final isCurrentlyWishlisted = isInWishlist(productId);

    print('🔁 [TOGGLE WISHLIST] Product ID: $productId | Currently Wishlisted: $isCurrentlyWishlisted');

    bool success;
    if (isCurrentlyWishlisted) {
      success = await removeFromWishlist(productId);
    } else {
      success = await addToWishlist(productId);
    }

    // Refresh the wishlist after toggling
    if (success) {
      await refreshWishlist();
    }

    return success;
  }
  // ✅ Sync local wishlist with server on app start
  Future<void> syncWishlistWithServer() async {
    try {
      print('🔄 Syncing wishlist with server...');
      await fetchWishlist(); // This will update _wishlistItems from server
      await _saveWishlistToStorage(); // Save the synced data
    } catch (e) {
      print('⚠️ Wishlist sync error: $e');
    }
  }

  Future<void> fetchWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    final userIdString = prefs.getString('user_id');
    final userId = int.tryParse(userIdString ?? '0') ?? 0;

    if (userId == 0) {
      print('❌ Fetch Wishlist Failed: User not logged in');
      return;
    }

    final url = Uri.parse('https://admin.elfinic.com/api/wishlist/$userId');
    print('📥 Fetch Wishlist URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      print('✅ Fetch Wishlist Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success' && data['data'] is List) {
          _wishlistItems = (data['data'] as List)
              .map<int>((item) =>
          int.tryParse(item['product_id']?.toString() ?? '0') ?? 0)
              .where((id) => id > 0)
              .toList();
          notifyListeners();
        }
      }
    } catch (e) {
      print('⚠️ Fetch Wishlist Error: $e');
    }
  }

  void clearWishlist() {
    _wishlistItems.clear();
    _saveWishlistToStorage(); // Also clear from storage
    notifyListeners();
  }

  int get wishlistCount => _wishlistItems.length;
}


class WishlistService {
  static const String baseUrl = 'https://admin.elfinic.com/api/wishlist';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  Future<int> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('user_id');
    return int.tryParse(userIdString ?? '0') ?? 0;
  }

  Future<bool> addWishlist(int productId) async {
    final token = await _getToken();
    final userId = await _getUserId();
    if (userId == 0) return false;

    final url = Uri.parse('$baseUrl/add');
    final body = jsonEncode({"user_id": userId, "product_id": productId});

    print('🔹 [ADD WISHLIST] URL: $url');
    print('📦 [ADD WISHLIST] Body: $body');

    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body);

    print('📡 [ADD WISHLIST] Status Code: ${response.statusCode}');
    print('🧾 [ADD WISHLIST] Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'] == 'success';
    }
    return false;
  }

  Future<bool> removeWishlist(int productId) async {
    final token = await _getToken();
    final userId = await _getUserId();
    if (userId == 0) return false;

    final url = Uri.parse('$baseUrl/remove');
    final body = jsonEncode({"user_id": userId, "product_id": productId});

    print('🔹 [REMOVE WISHLIST] URL: $url');
    print('📦 [REMOVE WISHLIST] Body: $body');

    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body);

    print('📡 [REMOVE WISHLIST] Status Code: ${response.statusCode}');
    print('🧾 [REMOVE WISHLIST] Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'] == 'success';
    }
    return false;
  }

  Future<List<WishlistItem>> fetchWishlist() async {
    final token = await _getToken();
    final userId = await _getUserId();
    if (userId == 0) return [];

    final url = Uri.parse('$baseUrl/$userId');
    print('🔹 [FETCH WISHLIST] URL: $url');

    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
    });

    print('📡 [FETCH WISHLIST] Status Code: ${response.statusCode}');
    print('🧾 [FETCH WISHLIST] Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success' && data['data'] is List) {
        return (data['data'] as List)
            .map((item) => WishlistItem.fromJson(item))
            .toList();
      }
    }
    return [];
  }
}

class WishlistItem {
  final int id;
  final int userId;
  final int productId;
  final DateTime? createdAt;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    this.createdAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      productId: int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}


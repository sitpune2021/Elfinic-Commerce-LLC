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

import '../services/api_service.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class WishlistProvider with ChangeNotifier {
  static const _storageKey = 'wishlist_items';
  List<int> _wishlistItems = [];

  List<int> get wishlistItems => _wishlistItems;
  int get wishlistCount => _wishlistItems.length;

  WishlistProvider() {
    // Init: load local cache first, then attempt server sync (non-blocking)
    _init();
  }

  Future<void> _init() async {
    await _loadFromStorage();
    // Try to sync with server but don't throw if it fails
    try {
      await syncWishlistWithServer();
    } catch (e) {
      print('⚠️ Wishlist init sync failed: $e');
    }
  }

  // ------------ SharedPreferences helpers (single source) ------------
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<int> _getUserId() async {
    final prefs = await _prefs;
    final userIdString = prefs.getString('user_id');
    return int.tryParse(userIdString ?? '') ?? 0;
  }

  Future<String?> _getToken() async {
    final prefs = await _prefs;
    return prefs.getString('auth_token');
  }

  // ------------ Local storage (SharedPreferences) ------------
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await _prefs;
      final wishlistString = prefs.getString(_storageKey);
      if (wishlistString != null && wishlistString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(wishlistString);
        _wishlistItems = decoded.map<int>((e) => (e as num).toInt()).toList();
        print('📥 Wishlist loaded from SharedPreferences: $_wishlistItems');
        notifyListeners();
      } else {
        _wishlistItems = [];
      }
    } catch (e) {
      print('⚠️ Error loading wishlist from SharedPreferences: $e');
    }
  }

  Future<void> _saveWishlistToStorage() async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_storageKey, jsonEncode(_wishlistItems));
      print('💾 Wishlist saved to SharedPreferences: $_wishlistItems');
    } catch (e) {
      print('⚠️ Error saving wishlist to SharedPreferences: $e');
    }
  }

  // ------------ Server sync / API calls (keeps local in sync) ------------
  /// Fetch wishlist from server and replace local list.
  /// Uses only SharedPreferences for local reads (user id + token).
  Future<bool> fetchWishlist() async {
    final userId = await _getUserId();
    final token = await _getToken();

    if (userId == 0) {
      print('❌ Fetch Wishlist Failed: User not logged in');
      return false;
    }

    final url = Uri.parse('${ApiService.baseUrl}/api/getProductByType?user_id=$userId&type=Wishlist');
    print('📥 Fetch Wishlist URL: $url');

    try {
      final response = await http.get(url, headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      });

      print('✅ Fetch Wishlist Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] is List) {
          final List<int> serverList = (data['data'] as List)
              .map<int>((item) => item['id'])
              .toList();


          _wishlistItems = serverList;
          await _saveWishlistToStorage();
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print('⚠️ Fetch Wishlist Error: $e');
    }
    return false;
  }

  /// Add to server wishlist; on success update local storage
  Future<bool> addToWishlist(int productId) async {
    final userId = await _getUserId();
    final token = await _getToken();

    if (userId == 0) {
      print('❌ Wishlist Add Failed: User not logged in');
      return false;
    }

    final url = Uri.parse('${ApiService.baseUrl}/api/wishlist/add');
    print('📤 Wishlist Add URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode({"user_id": userId, "product_id": productId}),
      );

      print('✅ Wishlist Add Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          if (!_wishlistItems.contains(productId)) {
            _wishlistItems.add(productId);
            await _saveWishlistToStorage();
            notifyListeners();
          }
          return true;
        }
      }
    } catch (e) {
      print('⚠️ Wishlist Add Error: $e');
    }
    return false;
  }

  /// Remove from server wishlist; on success update local storage
  Future<bool> removeFromWishlist(int productId) async {
    final userId = await _getUserId();
    final token = await _getToken();

    if (userId == 0) {
      print('❌ Wishlist Remove Failed: User not logged in');
      return false;
    }

    final url = Uri.parse('${ApiService.baseUrl}/api/wishlist/remove');
    print('📤 Wishlist Remove URL: $url');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode({"user_id": userId, "product_id": productId}),
      );

      print('✅ Wishlist Remove Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _wishlistItems.remove(productId);
          await _saveWishlistToStorage();
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print('⚠️ Wishlist Remove Error: $e');
    }
    return false;
  }

  // -------------- Toggle + Refresh helpers ----------------
  bool isInWishlist(int productId) => _wishlistItems.contains(productId);

  /// Toggle wishlist for a product. On success, refresh local list from server.
  Future<bool> toggleWishlist(int productId) async {
    final isCurrently = isInWishlist(productId);
    print('🔁 [TOGGLE WISHLIST] $productId | currently: $isCurrently');

    bool success = false;
    if (isCurrently) {
      success = await removeFromWishlist(productId);
    } else {
      success = await addToWishlist(productId);
    }

    if (success) {
      // Try to refresh from server to keep consistent
      await fetchWishlist();
    }
    return success;
  }

  /// Force refresh (fetch from server and notify)
  Future<void> refreshWishlist() async {
    await fetchWishlist();
    // fetchWishlist already calls notifyListeners() on success; but call again to be safe
    notifyListeners();
  }

  /// Sync local cache with server and save locally (call on app start or when user logs in)
  Future<void> syncWishlistWithServer() async {
    print('🔄 Syncing wishlist with server...');
    final ok = await fetchWishlist();
    if (!ok) {
      print('⚠️ Wishlist sync failed; keeping local cache.');
    }
  }

  // ------------ Utilities ------------
  /// Clear local wishlist (and storage). Use carefully.
  Future<void> clearWishlist() async {
    _wishlistItems.clear();
    await _saveWishlistToStorage();
    notifyListeners();
  }

  void clear() {
    _wishlistItems.clear();
    notifyListeners();
  }

  void addLocal(int productId) {
    if (!_wishlistItems.contains(productId)) {
      _wishlistItems.add(productId);
    }
  }

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


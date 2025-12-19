import 'dart:convert';
import 'dart:io';
import 'package:elfinic_commerce_llc/model/CategoriesResponse.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/AddToCartResponse.dart';
import '../model/AddressModel.dart';
import '../model/LoginResponse.dart';
import '../model/LogoutResponse.dart';

import '../model/ProductsResponse.dart';
import '../model/RegisterResponse.dart';
import '../model/SubcategoriesResponse.dart';
import '../model/cart_models.dart';
import '../model/delivery_type.dart';
import '../screens/CartScreen.dart';


class ApiService {
  // static const String _baseUrl = 'https://business.elfinic.com';
  static const String _baseUrl = 'https://admin.elfinic.com';
  // static const String _baseUrl = 'https://elfinic.thecanatech.com';


  static String get baseUrl => _baseUrl; // public getter



  static Uri getBannersByTypeUrl(String type) {
    return Uri.parse('$_baseUrl/api/getBannersByType?type=$type');
  }
  /// API Endpoints
  static Uri get getCategoriesUrl => Uri.parse('$_baseUrl/api/getAllCategories');
  /// Products API
  static Uri get getProductsUrl => Uri.parse('$_baseUrl/api/getProductsList');
  // static Uri get getProductsUrl => Uri.parse('$_baseUrl/api/getAllProducts');

  static Uri get getSubcategoriesUrl => Uri.parse('$_baseUrl/api/getSubcategories');

  static Uri get registerUrl => Uri.parse("$_baseUrl/api/register");

  static Uri get addToCartUrl => Uri.parse("$_baseUrl/api/cart/add");

  static Uri get deliveryChargesUrl => Uri.parse('$_baseUrl/api/delivery-charges/getallDeliveryType');


  static Uri get addressesUrl => Uri.parse('$_baseUrl/api/addresses/getallAdresses');
  static Uri get addAddressUrl => Uri.parse('$_baseUrl/api/addresses/addaddress');
  static Uri get updateAddressUrl => Uri.parse('$_baseUrl/api/addresses/updateAddress');
  static Uri get deleteAddressUrl => Uri.parse('$_baseUrl/api/addresses/deleteAddress');


  // Review endpoints
  static String get addReview => '$_baseUrl/api/products/addReview';
  static String get productReviews => '$_baseUrl/api/products/productReviews';
  static String get productReviewsById => '$_baseUrl/api/products'; // Base for /{id}/reviews


  /// ✅ Login API
  Future<LoginResponse> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/api/login");

    // Proper POST body
    final body = jsonEncode({
      "email": email,
      "password": password,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    // Logging response (optional)
    print("API Call: POST $url");
    print("Request body: $body");
    print("Response: ${response.body}");

    logApiCall(method: 'POST', url: url, response: response);

    if (response.statusCode == 200) {
      final loginRes = LoginResponse.fromRawJson(response.body);

      // ✅ Save token & user details in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("auth_token", loginRes.token);
      await prefs.setString("user_id", loginRes.user.id.toString());
      await prefs.setString("user_name", loginRes.user.name);
      await prefs.setString("user_email", loginRes.user.email);

      // Optional: print for debug
      print("Saved user_id: ${loginRes.user.id}");
      print("token user_id: ${loginRes.token}");

      return loginRes;
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  /// ✅ LOGOUT API
  Future<LogoutResponse> logout(String email, String password) async {
    final url = Uri.parse("$baseUrl/api/logout");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    final body = jsonEncode({
      "email": email,
      "password": password,
    });

    print("🚀 API Call: POST $url");
    print("📤 Request body: $body");
    print("🔑 Token: $token");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: body,
    );
    logApiCall(method: 'POST', url: url, response: response);
    print("📥 Response Status Code: ${response.statusCode}");
    print("📥 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      // ✅ Decode before passing to fromJson
      final data = jsonDecode(response.body);
      final logoutRes = LogoutResponse.fromJson(data);

      if (logoutRes.status == "success") {
        await prefs.remove("auth_token");
        await prefs.remove("user_id");
        await prefs.remove("user_name");
        await prefs.remove("user_email");

        print("✅ Logout successful, cleared stored session data.");
      } else {
        print("⚠️ Logout failed: ${logoutRes.message}");
      }

      return logoutRes;
    } else {
      throw Exception("❌ Server error: ${response.statusCode}");
    }
  }

  /// ---------------- REGISTER ----------------
  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String mobile,
    required String username,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      registerUrl,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "mobile": mobile,
        "username": username,
        "password": password,
        "password_confirmation": passwordConfirmation,
      }),
    );

    logApiCall(method: 'POST', url: registerUrl, response: response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final registerRes = RegisterResponse.fromRawJson(response.body);

      if (registerRes.status.toLowerCase() == "success") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", registerRes.token);
        await prefs.setString("user_id", registerRes.data.id.toString());
        await prefs.setString("user_name", registerRes.data.name);
        await prefs.setString("user_email", registerRes.data.email);
      }

      return registerRes;
    } else {
      throw Exception("Registration failed: ${response.body}");
    }
  }


  /// Fetch Categories from API

  static Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await http.get(getCategoriesUrl);

      // log method, url, status code, body
      logApiCall(method: 'GET', url: getCategoriesUrl, response: response);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final categoriesResponse = CategoriesResponse.fromJson(jsonData);
        return categoriesResponse.data;
      } else {
        throw Exception(
            "Failed to load categories (${response.statusCode})");
      }
    } catch (e, st) {
      debugPrint("fetchCategories error: $e\n$st");
      rethrow;
    }
  }

  /// Fetch Products
  /// Fetch products with pagination
  static Future<List<Product>> fetchProducts({
    String? productId,
    int? perPage,
    int? page,
  }) async {
    Uri url;

    if (productId != null) {
      url = Uri.parse("$baseUrl/api/getProductsList?product_id=$productId");
    } else {
      final params = <String, String>{};
      if (perPage != null) params['per_page'] = perPage.toString();
      if (page != null) params['page'] = page.toString();

      url = Uri.parse("$baseUrl/api/getProductsList").replace(queryParameters: params);
    }

    print("🔵 API CALL → fetchProducts()");
    print("🌐 URL: $url");

    final response = await http.get(url);
    print("📩 Response Status: ${response.statusCode}");
    print("📌 RAW RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final res = ProductsResponse.fromRawJson(response.body);
        if (!res.status) {
          // API replied but indicated failure
          throw Exception('API returned status=false: ${res.message}');
        }
        return res.data;
      } catch (e, st) {
        print('❌ Parsing ProductsResponse failed: $e\n$st');
        // Re-throw to bubble up to provider and set provider.error
        throw Exception('Parsing ProductsResponse failed: $e');
      }
    } else {
      print("❌ API ERROR: ${response.statusCode} → ${response.body}");
      throw Exception("Failed to load products (${response.statusCode})");
    }
  }


  /// Fetch a single product
  static Future<Product?> fetchSingleProduct(int productId) async {
    final url = Uri.parse("$baseUrl/api/getProductsList?product_id=$productId");

    print("🔵 API CALL → fetchSingleProduct()");
    print("🌐 URL: $url");

    final response = await http.get(url);
    print("📩 Response Status: ${response.statusCode}");
    print("📩 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);

      if (jsonMap["status"] == true &&
          jsonMap["data"] != null &&
          jsonMap["data"].isNotEmpty) {
        return Product.fromJson(jsonMap["data"][0]);
      }

      print("⚠️ No product found for ID: $productId");
      return null;
    } else {
      print("❌ API ERROR: ${response.statusCode} → ${response.body}");
      throw Exception("Failed to load product details");
    }
  }

  static Future<List<SubCategoryModel>> fetchSubcategories() async {
    try {
      final response = await http.get(getSubcategoriesUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final subCategoriesResponse = SubCategoriesResponse.fromJson(jsonData);
        return subCategoriesResponse.data;
      } else {
        throw Exception("Failed to load Subcategories (${response.statusCode})");
      }
    } catch (e) {
      rethrow;
    }
  }


  // Common headers
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token") ?? "";
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    };
  }

  /// ✅ Get Cart Items
  static Future<List<UserCartItem>> fetchCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("user_id");
      if (userId == null) throw Exception("User not logged in");

      final url = Uri.parse("$_baseUrl/api/viewCart?user_id=$userId");
      final headers = await _headers();

      final response = await http.get(url, headers: headers);
      logApiCall(method: "GET", url: url, response: response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final status = data['status'];

        // ✅ FIXED CONDITION
        if (status == true || status == "success") {
          return (data['data'] as List)
              .map((e) => UserCartItem.fromJson(e))
              .toList();
        } else {
          throw Exception(data['message'] ?? "Failed to load cart");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ fetchCartItems error: $e");
      rethrow;
    }
  }

 /* static Future<List<UserCartItem>> fetchCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id");
    if (userId == null) throw Exception("User not logged in");

    final url = Uri.parse("$_baseUrl/api/viewCart?user_id=$userId");
    final headers = await _headers();

    final response = await http.get(url, headers: headers);
    logApiCall(method: "GET", url: url, response: response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // ✅ Correct condition (status is boolean)
      if (data['status'] == true) {
        return (data['data'] as List)
            .map((e) => UserCartItem.fromJson(e))
            .toList();
      } else {
        throw Exception(data['message'] ?? "Failed to load cart");
      }
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }*/

  /// ✅ Update Quantity (Add or Decrease)
  static Future<int> updateQuantity({
    required int userId,
    required int productId,
    required bool increase,
  }) async {
    final url = Uri.parse(
        increase ? "$_baseUrl/api/cart/add" : "$_baseUrl/api/cart/decrease");
    final headers = await _headers();

    final body = jsonEncode({
      "user_id": userId,
      "product_id": productId,
      "quantity": 1,
    });

    final response = await http.post(url, headers: headers, body: body);
    logApiCall(method: "POST", url: url, response: response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["status"] == "success") {
        return data["data"]["quantity"];
      } else {
        throw Exception(data["message"] ?? "Failed to update quantity");
      }
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }

  /// ✅ Remove Cart Item
  static Future<bool> removeCartItem(int cartId) async {
    final url = Uri.parse("$_baseUrl/api/removeFromCart");
    final headers = await _headers();

    final response = await http.delete(
      url,
      headers: headers,
      body: jsonEncode({"cart_id": cartId}),
    );

    logApiCall(method: "DELETE", url: url, response: response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["status"] == "success";
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }


  /// Add to Cart API
  static Future<AddToCartResponse> addToCartApi({
    required int productId,
    required int quantity,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = int.parse(prefs.getString("user_id") ?? "0");
    final token = prefs.getString("auth_token") ?? "";



    if (userId == 0 || token.isEmpty) {
      throw Exception("User not logged in");
    }

    final url = addToCartUrl; // Correct URL with /api

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "user_id": userId,
        "product_id": productId,
        "quantity": quantity,
      }),
    );

    // Use logApiCall for consistent logging
    logApiCall(method: 'POST', url: url, response: response);

    print("Token : $token");

    if (response.statusCode == 200) {
      return AddToCartResponse.fromRawJson(response.body);
    } else {
      throw Exception("Failed to add to cart: ${response.body}");
    }
  }

  /// Delivery Charges API
  static Future<List<DeliveryType>> fetchDeliveryTypes() async {
    final url = deliveryChargesUrl;

    final response = await http.get(url);

    // Use logApiCall for consistent logging
    logApiCall(method: 'GET', url: url, response: response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        return (data['data'] as List)
            .map((e) => DeliveryType.fromJson(e))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch delivery types');
      }
    } else {
      throw Exception("Failed to fetch delivery types: ${response.statusCode}");
    }
  }





  /// ✅ Add new address
  static Future<Address> addAddressApi({required Address address}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token") ?? "";

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final body = jsonEncode(address.toJson());

    final response = await http.post(
      addAddressUrl,
      headers: headers,
      body: body,
    );

    logApiCall(method: 'POST', url: addAddressUrl, response: response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["status"] == "success" && data["data"] != null) {
        return Address.fromJson(data["data"]);
      } else {
        throw Exception(data["message"] ?? "Failed to add address");
      }
    } else {
      throw Exception("Failed to add address: ${response.statusCode}");
    }
  }

  /// ✅ Update address
  static Future<bool> updateAddressApi({required Address address}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = json.encode(address.toJson());

    final response = await http.post(
      updateAddressUrl,
      headers: headers,
      body: body,
    );

    logApiCall(method: 'POST', url: updateAddressUrl, response: response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'] == 'success';
    } else {
      throw Exception("Failed to update address: ${response.statusCode}");
    }
  }

  /// ✅ Delete address
  static Future<bool> deleteAddressApi({required int addressId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'address_id': addressId,
    });

    final response = await http.delete(
      deleteAddressUrl,
      headers: headers,
      body: body,
    );

    logApiCall(method: 'DELETE', url: deleteAddressUrl, response: response);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'] == 'success';
    } else {
      throw Exception("Failed to delete address: ${response.statusCode}");
    }
  }




  // Fetch active coupons
  // Fetch active coupons
  static Future<CouponResponse> fetchActiveCoupons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = '$baseUrl/api/coupons';
      print("➡️ FETCH COUPONS URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print("⬅️ RESPONSE STATUS: ${response.statusCode}");
      print("⬅️ RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CouponResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load coupons: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      throw Exception('Error fetching coupons: $e');
    }
  }


  // Apply coupon to cart
// Apply coupon to cart
  static Future<ApplyCouponResponse> applyCoupon(
      String couponCode,
      double amount,
      ) async {
    final url = Uri.parse('$baseUrl/api/applyCoupon');

    // ✅ PRINT REQUEST
    print('📌 APPLY COUPON URL: $url');
    print('📌 REQUEST BODY: ${jsonEncode({
      'code': couponCode,
      'amount': amount.toInt(),
    })}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'code': couponCode,
        'amount': amount.toInt(),
      }),
    );

    // ✅ PRINT RESPONSE
    print('📌 STATUS CODE: ${response.statusCode}');
    print('📌 RESPONSE BODY: ${response.body}');

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return ApplyCouponResponse.fromJson(json);
    } else {
      throw Exception(json['message'] ?? 'Failed to apply coupon');
    }
  }



  // Remove applied coupon
  // Remove applied coupon
  static Future<Map<String, dynamic>> removeCoupon() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = int.tryParse(prefs.getString('user_id') ?? "0") ?? 0;

      final url = '$baseUrl/api/remove-coupon';
      print("➡️ REMOVE COUPON URL: $url");

      final bodyData = {
        'user_id': userId,
      };

      print("➡️ REQUEST BODY: $bodyData");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(bodyData),
      );

      print("⬅️ RESPONSE STATUS: ${response.statusCode}");
      print("⬅️ RESPONSE BODY: ${response.body}");

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Coupon removed successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to remove coupon',
        };
      }
    } catch (e) {
      print("❌ REMOVE COUPON ERROR: $e");
      return {
        'success': false,
        'message': 'Error removing coupon',
        'error': e.toString(),
      };
    }
  }




  static Future<Map<String, dynamic>> fetchProductsBySectionPaginated({
    required String section,
    required int page,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/api/getProductsList")
          .replace(queryParameters: {
        "show_section": section,
        "page": page.toString(),
      });

      print("📌 FINAL API URL: $uri");

      final response = await http.get(
        uri,
        headers: {"Accept": "application/json"},
      );

      print("📌 STATUS CODE: ${response.statusCode}");
      print("📌 RAW RESPONSE: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Server Error: ${response.statusCode}");
      }

      final Map<String, dynamic> json = jsonDecode(response.body);

      // --- ROBUST STATUS PARSING ---
      final rawStatus = json['status'];
      print('📣 RAW status from API: $rawStatus (${rawStatus?.runtimeType})');

      bool isSuccess = false;
      if (rawStatus is bool) {
        isSuccess = rawStatus;
      } else if (rawStatus is String) {
        final s = rawStatus.toLowerCase().trim();
        isSuccess = (s == 'true' || s == 'success' || s == '1' || s == 'yes');
      } else if (rawStatus is num) {
        isSuccess = rawStatus != 0;
      }

      if (!isSuccess) {
        // Only throw if API really indicates failure
        throw Exception(json["message"] ?? "Unknown error");
      }

      // --- SAFE DATA & PAGINATION PARSING ---
      final List<dynamic> dataList = (json['data'] is List) ? json['data'] as List : [];

      final paginationRaw = json['pagination'];
      final int lastPage = (paginationRaw is Map && paginationRaw['last_page'] != null)
          ? int.tryParse('${paginationRaw['last_page']}') ?? 1
          : 1;
      final int currentPage = (paginationRaw is Map && paginationRaw['current_page'] != null)
          ? int.tryParse('${paginationRaw['current_page']}') ?? page
          : page;

      final products = dataList.map((e) {
        try {
          return Product.fromJson(Map<String, dynamic>.from(e));
        } catch (err) {
          print('⚠️ Product parse error: $err — raw: $e');
          // skip malformed product by returning null; caller receives only valid ones
          return null;
        }
      }).where((p) => p != null).map((p) => p as Product).toList();

      return {
        "products": products,
        "last_page": lastPage,
        "current_page": currentPage,
      };
    } catch (e, st) {
      print("❌ fetchProductsBySectionPaginated Error: $e\n$st");
      throw Exception("fetchProductsBySectionPaginated Error: $e");
    }
  }




  static String getFullImageUrl(String? image, String folder) {
    if (image == null || image.isEmpty) {
      return "assets/images/no_product_img2.png";
    }

    // ✅ If already full URL, return directly
    if (image.startsWith("http")) {
      return image;
    }

    // ✅ If only filename, attach base URL
    return "$_baseUrl/assets/img/$folder/$image";
  }



}
void logApiCall({
  required String method,
  required Uri url,
  required http.Response response,
}) {
  debugPrint(
      '➡️ API [$method] ${url.toString()} | Status: ${response.statusCode}');
  debugPrint('⬅️ Response: ${response.body}');
}

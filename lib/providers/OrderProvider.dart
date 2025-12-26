// providers/order_provider.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// providers/order_provider.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../model/OrderModel.dart';


// providers/order_provider.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/VerifyPaymentModels.dart';
import '../model/cart_models.dart';
import '../services/api_service.dart';


class OrderProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isVerifyingPayment = false;
  String? _orderId;
  String? _error;
  CreateOrderResponse? _lastOrderResponse;
  VerifyPaymentResponse? _lastVerifyResponse;

  bool get isLoading => _isLoading;
  bool get isVerifyingPayment => _isVerifyingPayment;
  String? get orderId => _orderId;
  String? get error => _error;
  CreateOrderResponse? get lastOrderResponse => _lastOrderResponse;
  VerifyPaymentResponse? get lastVerifyResponse => _lastVerifyResponse;




  Future<CreateOrderResponse?> createOrder({
    required int userId,
    required int addressId,
    required double totalAmount,
    required List<UserCartItem> cartItems, // Changed parameter name
    String? couponCode,
    double discountAmount = 0,
    double coinsUsed = 0,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Convert UserCartItem to OrderCartItem
    final List<OrderCartItem> orderCart = cartItems.map((item) {
      final p = item.product;
      final regularPrice = double.tryParse(p.price.replaceAll(',', '')) ?? 0;
      final discountPrice = double.tryParse(p.discountPrice.replaceAll(',', '')) ?? 0;

      return OrderCartItem(
        productId: p.id,
        variantId: p.selectedVariantId ?? 0,   // ✅ FIXED
        quantity: item.quantity,
        price: regularPrice,
        discount: discountPrice,
      );
    }).toList();


    final request = CreateOrderRequest(
      userId: userId,
      totalAmount: totalAmount,
      couponCode: couponCode,
      discountAmount: discountAmount,
      coinsUsed: coinsUsed,
      addressId: addressId,
      cart: orderCart,
    );

    final url = Uri.parse("${ApiService.baseUrl}/api/product-order/place");

    _logPaymentFlow('Sending order request', extra: {
      'url': url.toString(),
      'request': request.toJson(),
    });


    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) {
      _error = "User not authenticated. Token missing.";
      _isLoading = false;
      notifyListeners();
      return null;
    }

    _printDebugInfo("📦 PLACE ORDER REQUEST", {
      "URL": url.toString(),
      "HEADERS": {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      "BODY": request.toJson(),
    });



    final response = await http.post(
      url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',  // 🔥 REQUIRED
        },

      body: jsonEncode(request.toJson()),
    );

    _printDebugInfo("📦 PLACE ORDER RESPONSE", {
      "STATUS": response.statusCode,
      "BODY": response.body,
    });

    _isLoading = false;

    _logPaymentFlow('Order API response', extra: {
      'statusCode': response.statusCode,
      'body': response.body,
    });

    if (response.statusCode == 200) {
      try {
        final jsonResponse = jsonDecode(response.body);
        final order = CreateOrderResponse.fromJson(jsonResponse);
        _orderId = order.razorpayOrderId;
        _lastOrderResponse = order;
        notifyListeners();
        return order;
      } catch (e) {
        _error = 'Failed to parse response: $e';
        notifyListeners();
        return null;
      }
    } else {
      _error = 'HTTP ${response.statusCode}: ${response.body}';
      notifyListeners();
      return null;
    }
  }
  void _logPaymentFlow(String message, {Map<String, dynamic>? extra}) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ 📦 ORDER FLOW: $message');
      print('├─────────────────────────────────────────────────────────────');
      if (extra != null) {
        extra.forEach((key, value) {
          print('│ $key: $value');
        });
      }
      print('│ Timestamp: ${DateTime.now()}');
      print('└─────────────────────────────────────────────────────────────');
    }
  }
  Future<VerifyPaymentResponse?> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    _isVerifyingPayment = true;
    notifyListeners();

    final url = Uri.parse("${ApiService.baseUrl}/api/product-order/verify-payment");

    final request = VerifyPaymentRequest(
      orderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );


    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (token == null) {
      _isVerifyingPayment = false;
      _error = "Auth token missing";
      notifyListeners();
      return VerifyPaymentResponse(
        success: false,
        message: "User not logged in",
      );
    }
    _printDebugInfo("🔐 VERIFY PAYMENT HEADERS", {
      "Authorization": "Bearer $token",
    });
    _printDebugInfo("🔐 VERIFY PAYMENT REQUEST", {
      "url": url.toString(),
      "body": request.toJson(),
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",   // 🔥 THIS FIXES 401
        },
        body: jsonEncode(request.toJson()),
      );

      _printDebugInfo("🔐 VERIFY PAYMENT RESPONSE", {
        "STATUS": response.statusCode,
        "BODY": response.body,
      });

      _isVerifyingPayment = false;

      _printDebugInfo("📡 VERIFY PAYMENT RESPONSE", {
        "statusCode": response.statusCode,
        "body": response.body,
      });

      final json = jsonDecode(response.body);
      final verifyResponse = VerifyPaymentResponse.fromJson(json);

      _lastVerifyResponse = verifyResponse;
      notifyListeners();

      return verifyResponse;

    } catch (e) {
      _isVerifyingPayment = false;
      _error = e.toString();
      notifyListeners();

      return VerifyPaymentResponse(
        success: false,
        message: "Verification failed: $e",
      );
    }
  }


  // Helper method for formatted debug printing
  void _printDebugInfo(String title, Map<String, dynamic> data) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ $title');
      print('├─────────────────────────────────────────────────────────────');
      data.forEach((key, value) {
        print('│ $key: $value');
      });
      print('└─────────────────────────────────────────────────────────────');
    }
  }


  void clearError() {
    _printDebugInfo('🗑️ CLEARING ERROR', {'previous_error': _error});
    _error = null;
    notifyListeners();
  }

  void reset() {
    _printDebugInfo('🔄 RESETTING PROVIDER', {
      'previous_state': {
        'isLoading': _isLoading,
        'isVerifyingPayment': _isVerifyingPayment,
        'orderId': _orderId,
        'error': _error,
      }
    });
    _isLoading = false;
    _isVerifyingPayment = false;
    _orderId = null;
    _error = null;
    _lastOrderResponse = null;
    _lastVerifyResponse = null;
    notifyListeners();
  }

  // Method to print current state
  void printCurrentState() {
    _printDebugInfo('📊 CURRENT STATE', {
      'isLoading': _isLoading,
      'isVerifyingPayment': _isVerifyingPayment,
      'orderId': _orderId,
      'error': _error,
      'lastOrderResponse': _lastOrderResponse?.toString(),
      'lastVerifyResponse': _lastVerifyResponse?.toString(),
    });
  }
}
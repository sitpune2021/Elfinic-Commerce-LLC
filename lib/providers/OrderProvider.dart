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
import 'dart:convert';

import '../model/OrderModel.dart';


// providers/order_provider.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/VerifyPaymentModels.dart';


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




  Future<CreateOrderResponse?> createOrder(double amount) async {
    _isLoading = true;
    _error = null;
    _lastOrderResponse = null;
    notifyListeners();

    // Create request model
    final CreateOrderRequest request = CreateOrderRequest(amount: amount);

    // API Configuration
    const String baseUrl = 'https://admin.elfinic.com';
    const String endpoint = '/api/createOrder';
    final String fullUrl = baseUrl + endpoint;

    // Debug prints
    _printDebugInfo('🚀 STARTING ORDER CREATION', {
      'API_URL': fullUrl,
      'REQUEST': request.toString(),
      'JSON_REQUEST': request.toJson(),
    });

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      _isLoading = false;

      // Response debug prints
      _printDebugInfo('📡 RESPONSE RECEIVED', {
        'STATUS_CODE': response.statusCode,
        'RESPONSE_BODY': response.body,
      });

      if (response.statusCode == 200) {
        // Parse response using model
        final Map<String, dynamic> responseJson = json.decode(response.body);
        final CreateOrderResponse orderResponse = CreateOrderResponse.fromJson(responseJson);

        _lastOrderResponse = orderResponse;
        _orderId = orderResponse.orderId;

        _printDebugInfo('✅ ORDER CREATED SUCCESSFULLY', {
          'ORDER_RESPONSE': orderResponse.toString(),
          'ORDER_ID': orderResponse.orderId,
          'AMOUNT': orderResponse.amount,
        });

        notifyListeners();
        return orderResponse;
      } else {
        _error = 'HTTP ${response.statusCode}: ${response.body}';

        _printDebugInfo('❌ ORDER CREATION FAILED', {
          'ERROR': _error,
          'STATUS_CODE': response.statusCode,
        });

        notifyListeners();
        return null;
      }
    } catch (e, stackTrace) {
      _isLoading = false;
      _error = 'Exception: $e';

      _printDebugInfo('💥 EXCEPTION OCCURRED', {
        'ERROR': e.toString(),
        'STACK_TRACE': stackTrace.toString(),
      });

      notifyListeners();
      return null;
    }
  }

  Future<VerifyPaymentResponse?> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    _isVerifyingPayment = true;
    _error = null;
    _lastVerifyResponse = null;
    notifyListeners();

    // Create request model
    final VerifyPaymentRequest request = VerifyPaymentRequest(
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );

    // API Configuration
    const String baseUrl = 'https://admin.elfinic.com';
    const String endpoint = '/api/verifyPayment';
    final String fullUrl = baseUrl + endpoint;

    // Debug prints
    _printDebugInfo('🔐 STARTING PAYMENT VERIFICATION', {
      'API_URL': fullUrl,
      'REQUEST': request.toString(),
      'JSON_REQUEST': request.toJson(),
    });

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      _isVerifyingPayment = false;

      // Response debug prints
      _printDebugInfo('📡 VERIFICATION RESPONSE RECEIVED', {
        'STATUS_CODE': response.statusCode,
        'RESPONSE_BODY': response.body,
      });

      if (response.statusCode == 200) {
        try {
          // Parse response using model
          final Map<String, dynamic> responseJson = json.decode(response.body);
          final VerifyPaymentResponse verifyResponse = VerifyPaymentResponse.fromJson(responseJson);

          _lastVerifyResponse = verifyResponse;

          if (verifyResponse.success) {
            _printDebugInfo('✅ PAYMENT VERIFIED SUCCESSFULLY', {
              'VERIFY_RESPONSE': verifyResponse.toString(),
              'MESSAGE': verifyResponse.message,
            });
          } else {
            _printDebugInfo('❌ PAYMENT VERIFICATION FAILED', {
              'VERIFY_RESPONSE': verifyResponse.toString(),
              'MESSAGE': verifyResponse.message,
            });
          }

          notifyListeners();
          return verifyResponse;

        } catch (parseError) {
          _printDebugInfo('❌ JSON PARSE ERROR', {
            'ERROR': parseError.toString(),
            'RESPONSE_BODY': response.body,
          });

          // Return a fallback response if parsing fails
          return VerifyPaymentResponse(
            success: false,
            message: 'Failed to parse server response: $parseError',
          );
        }
      } else {
        _error = 'HTTP ${response.statusCode}: ${response.body}';

        _printDebugInfo('❌ VERIFICATION REQUEST FAILED', {
          'ERROR': _error,
          'STATUS_CODE': response.statusCode,
        });

        notifyListeners();
        return VerifyPaymentResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      _isVerifyingPayment = false;
      _error = 'Exception: $e';

      _printDebugInfo('💥 VERIFICATION EXCEPTION OCCURRED', {
        'ERROR': e.toString(),
        'STACK_TRACE': stackTrace.toString(),
      });

      notifyListeners();
      return VerifyPaymentResponse(
        success: false,
        message: 'Network error: $e',
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
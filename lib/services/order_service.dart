import 'package:elfinic_commerce_llc/model/order_history_details_model.dart';
import 'package:elfinic_commerce_llc/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class OrderService {

  static Future<Uint8List?> downloadInvoiceBytes({
    required int orderId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString('user_id') ?? '0') ?? 0;
      final token = prefs.getString('auth_token') ?? '';

      if (userId == 0 || token.isEmpty) return null;

      final uri = Uri.parse(ApiService.orderInvoicedownload).replace(
        queryParameters: {
          'user_id': userId.toString(),
          'order_id': orderId.toString(),
        },
      );

      // 🔍 Print URL
      debugPrint("📌 Invoice Download URL: $uri");


      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      );



      // 🔍 Print status code
      debugPrint("📌 Status Code: ${response.statusCode}");

      // 🔍 Print headers
      debugPrint("📌 Response Headers: ${response.headers}");

      // 🔍 Print body length (PDF binary, so don't print full body)
      debugPrint("📌 Response Bytes Length: ${response.bodyBytes.length}");


      // if (response.statusCode != 200) return null;

      if (response.statusCode != 200) {
        debugPrint("❌ Error Response: ${response.body}");
        return null;
      }

      return response.bodyBytes;
    } catch (e) {
      debugPrint('❌ Download error: $e');
      return null;
    }
  }

  //order history details
  static Future<OrderHistoryDetailsModel?> fetchOrderHistoryDetails({
    required int orderId,
    required int productId,
  }) async {
    debugPrint('🚀 fetchOrderHistoryDetails() START');

    final prefs = await SharedPreferences.getInstance();
    final userId = int.tryParse(prefs.getString('user_id') ?? '0') ?? 0;
    final token = prefs.getString('auth_token') ?? '';

    debugPrint('👤 User ID: $userId');
    debugPrint('🔑 Token exists: ${token.isNotEmpty}');
    debugPrint('📦 Order ID: $orderId');
    debugPrint('🛒 Product ID: $productId');

    if (userId == 0 || token.isEmpty) {
      debugPrint('❌ EXIT: User not logged in or token missing');
      return null;
    }

    /// 🔹 Build GET URL with query params
    final uri = Uri.parse(ApiService.orderHistoryDetails).replace(
      queryParameters: {
        'user_id': userId.toString(),
        'order_id': orderId.toString(),
        'product_id': productId.toString(),
      },
    );

    debugPrint('🌐 API URL (GET): $uri');

    try {
      debugPrint('⏳ Sending GET request...');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint('📥 Status Code: ${response.statusCode}');
      debugPrint('📥 Response Headers: ${response.headers}');
      debugPrint('📥 Raw Response Body:\n${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ API SUCCESS → Parsing JSON');

        final model = orderHistoryDetailsModelFromJson(response.body);

        debugPrint('📊 Parsed Status: ${model.status}');
        debugPrint('📨 Parsed Message: ${model.message}');
        debugPrint('📦 Data Length: ${model.data.length}');

        if (model.data.isNotEmpty) {
          debugPrint('🧾 Order Number: ${model.data.first.orderNumber}');
          debugPrint('🏠 Address Found: ${model.data.first.address != null}');
          debugPrint('📜 History Count: ${model.data.first.history.length}');
        }

        debugPrint('🎯 fetchOrderHistoryDetails() END SUCCESS');
        return model;
      } else {
        debugPrint('❌ API ERROR ${response.statusCode}');
        debugPrint('❌ Body: ${response.body}');
        return null;
      }
    } catch (e, stack) {
      debugPrint('🔥 EXCEPTION OCCURRED');
      debugPrint('❗ Error: $e');
      debugPrint('📍 StackTrace: $stack');
      return null;
    }
  }
}

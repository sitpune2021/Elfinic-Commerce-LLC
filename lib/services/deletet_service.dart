import 'dart:convert';
import 'package:elfinic_commerce_llc/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DeleteAccountService {
  static Future<Map<String, dynamic>> deleteAccount() async {
    debugPrint("🚀 DeleteAccountService → START");

    // STEP 2.1: SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    debugPrint("📦 SharedPreferences loaded");

    // STEP 2.2: Read values
    final userId = prefs.getString('user_id');
    final token = prefs.getString('auth_token') ?? '';

    debugPrint("👤 user_id: $userId");
    debugPrint("🔐 token exists: ${token.isNotEmpty}");

    // STEP 2.3: Auth check
    if (userId == null || token.isEmpty) {
      debugPrint("❌ User not authenticated");
      return {
        'success': false,
        'message': 'User not authenticated',
      };
    }

    final url = Uri.parse(ApiService.deleteUser);
    debugPrint("📡 DELETE Request URL: $url");

    try {
      debugPrint("📤 Sending DELETE request...");

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"user_id": userId}),
      );

      debugPrint("📥 Response Status: ${response.statusCode}");
      debugPrint("📥 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("✅ Account deleted successfully");
        return {
          'success': true,
          'message': 'Account deleted successfully',
        };
      } else {
        final data = jsonDecode(response.body);
        debugPrint("⚠️ Delete failed: ${data['message']}");
        return {
          'success': false,
          'message': data['message'] ?? 'Delete failed',
        };
      }
    } catch (e) {
      debugPrint("🔥 Exception: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}

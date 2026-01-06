import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class ReviewService {
  /// ✅ Check review eligibility (Bearer token + full debugPrint logs)
  static Future<bool> checkEligibility({
    required int productId,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🟡 CHECK REVIEW ELIGIBILITY START');

      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString('user_id') ?? '0') ?? 0;
      final token = prefs.getString('auth_token') ?? '';

      debugPrint('👤 User ID: $userId');
      debugPrint('🔑 Token present: ${token.isNotEmpty}');

      if (userId == 0 || token.isEmpty) {
        debugPrint('❌ User not logged in or token missing');
        return false;
      }

      final url = ApiService.reviewEligibility;

      final body = {
        "user_id": userId,
        "product_id": productId,
      };

      debugPrint('➡️ API URL: $url');
      debugPrint('➡️ METHOD: POST');
      debugPrint('➡️ HEADERS: Authorization: Bearer $token');
      debugPrint('➡️ BODY: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('⬅️ STATUS CODE: ${response.statusCode}');
      debugPrint('⬅️ RESPONSE BODY: ${response.body}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final eligible = data['eligible'] == true;
        debugPrint('✅ ELIGIBLE: $eligible');

        return eligible;
      }

      debugPrint('❌ Non-200 response');
      return false;
    } catch (e, st) {
      debugPrint('🔥 ELIGIBILITY ERROR: $e');
      debugPrint('📌 STACKTRACE: $st');
      return false;
    }
  }
}

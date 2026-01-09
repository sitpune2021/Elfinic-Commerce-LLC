import 'dart:convert';
import 'dart:io';
import 'package:elfinic_commerce_llc/model/get_review_model.dart';
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

  /// ADD REVIEW (Multipart Form Data)
  static Future<bool> addReview({
    required int productId,
    required int rating,
    String? title,
    String? content,
    List<File>? images,
    List<File>? videos,
    required Function(double) onProgress,
  }) async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🟡 ADD REVIEW START');

      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString('user_id') ?? '0') ?? 0;
      final token = prefs.getString('auth_token') ?? '';

      debugPrint('👤 USER ID: $userId');
      debugPrint('🔑 TOKEN EXISTS: ${token.isNotEmpty}');

      if (userId == 0 || token.isEmpty) {
        debugPrint('❌ AUTH ERROR: user or token missing');
        return false;
      }

      final uri = Uri.parse(ApiService.addProductReview);
      final request = http.MultipartRequest('POST', uri);

      /// HEADERS
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      /// REQUIRED FIELDS
      request.fields['user_id'] = userId.toString();
      request.fields['product_id'] = productId.toString();
      request.fields['rating'] = rating.toString();

      /// OPTIONAL FIELDS
      if (title?.isNotEmpty == true) request.fields['title'] = title!;
      if (content?.isNotEmpty == true) request.fields['content'] = content!;

      /// DEBUG FIELDS
      debugPrint('➡️ FORM FIELDS:');
      request.fields.forEach((k, v) {
        debugPrint('   $k : $v');
      });

      /// FILES
      for (final img in images ?? []) {
        debugPrint('🖼️ IMAGE: ${img.path}');
        request.files.add(
          await http.MultipartFile.fromPath('image[]', img.path),
        );
      }

      for (final vid in videos ?? []) {
        debugPrint('🎥 VIDEO: ${vid.path}');
        request.files.add(
          await http.MultipartFile.fromPath('video[]', vid.path),
        );
      }

      debugPrint('➡️ API URL: ${uri.toString()}');
      debugPrint('➡️ METHOD: POST');
      debugPrint(
          '➡️ FILE COUNT: image=${images?.length ?? 0}, video=${videos?.length ?? 0}');

      /// SEND REQUEST
      final streamedResponse = await request.send();

      final totalBytes = streamedResponse.contentLength ?? 0;
      int receivedBytes = 0;

      debugPrint('⬅️ STATUS: ${streamedResponse.statusCode}');
      debugPrint('⬅️ TOTAL BYTES: $totalBytes');

      await for (final chunk in streamedResponse.stream) {
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          final progress = receivedBytes / totalBytes;
          onProgress(progress.clamp(0.0, 1.0));
          debugPrint(
            '📤 UPLOAD PROGRESS: ${(progress * 100).toStringAsFixed(1)}%',
          );
        }
      }

      debugPrint('⬅️ UPLOAD COMPLETE');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      return streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201;
    } catch (e, st) {
      debugPrint('🔥 ADD REVIEW ERROR: $e');
      debugPrint('📌 STACKTRACE:\n$st');
      return false;
    }
  }

  static Future<GetReviewModel?> getReviewsByProduct(int productId) async {
    try {
      debugPrint('🟡 GET PRODUCT REVIEWS START');

      final url = ApiService.getProductSubmittedReview(productId);

      debugPrint('➡️ URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint('⬅️ STATUS: ${response.statusCode}');
      debugPrint('⬅️ BODY: ${response.body}');

      if (response.statusCode == 200) {
        return getReviewModelFromJson(response.body);
      }

      return null;
    } catch (e, st) {
      debugPrint('🔥 GET REVIEW ERROR: $e');
      debugPrint('📌 STACKTRACE: $st');
      return null;
    }
  }
}

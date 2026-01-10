import 'dart:convert';
import 'dart:io';

import 'package:elfinic_commerce_llc/model/UserProfileModel.dart';
import 'package:elfinic_commerce_llc/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  // get profile data
  static Future<UserProfileModel?> getUserProfileData() async {
    try {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString('user_id') ?? '0') ?? 0;
      final token = prefs.getString('auth_token') ?? '';

      debugPrint('👤 User ID: $userId');
      debugPrint('🔑 Token present: ${token.isNotEmpty}');

      if (userId == 0 || token.isEmpty) {
        debugPrint('❌ User not logged in or token missing');
        return null;
      }

      final uri = Uri.parse(ApiService.getUserProfileData);

      debugPrint('➡️ URL: $uri');

      // ✅ GET WITH BODY (your required way)
      final request = http.Request('GET', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // ✅ bearer token
      });

      request.body = jsonEncode({
        "user_id": userId,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('⬅️ STATUS: ${response.statusCode}');
      debugPrint('⬅️ BODY: ${response.body}');

      if (response.statusCode == 200) {
        return userProfileModelFromJson(response.body);
      }

      return null;
    } catch (e, st) {
      debugPrint('🔥 GET REVIEW ERROR: $e');
      debugPrint('📌 STACKTRACE: $st');
      return null;
    }
  }

  // update profile data
  static Future<Map<String, dynamic>> updateUserProfile({
    required String name,
    required String mobile,
    File? photo,
    required Function(double progress) onProgress,
  }) async {
    try {
      debugPrint("🟡 [UPDATE PROFILE] API CALL STARTED");

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final token = prefs.getString('auth_token') ?? '';

      debugPrint("👤 User ID: $userId");
      debugPrint("🔐 Token exists: ${token.isNotEmpty}");

      if (userId == null || token.isEmpty) {
        debugPrint("❌ User not authenticated");
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      final uri = Uri.parse(ApiService.updateUserProfileData);
      debugPrint("🌐 API URL: $uri");

      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['user_id'] = userId;
      request.fields['name'] = name;
      request.fields['mobile'] = mobile;

      debugPrint("📝 Fields added");

      if (photo != null) {
        debugPrint("🖼 Adding photo: ${photo.path}");
        request.files.add(
          await http.MultipartFile.fromPath('photo', photo.path),
        );
      } else {
        debugPrint("ℹ️ No photo selected");
      }

      debugPrint("🚀 Sending request...");
      onProgress(0.3); // fake progress start

      final streamedResponse = await request.send();

      onProgress(0.7); // fake progress mid

      final response = await http.Response.fromStream(streamedResponse);

      onProgress(1.0); // fake progress end

      debugPrint("📥 Status Code: ${response.statusCode}");
      debugPrint("📥 Response Body: ${response.body}");

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        debugPrint("✅ Profile updated successfully");
        return {
          'success': true,
          'message': body['message'] ?? 'Profile updated',
        };
      } else {
        debugPrint("❌ Update failed");
        return {
          'success': false,
          'message': body['message'] ?? 'Update failed',
        };
      }
    } catch (e, stack) {
      debugPrint("🔥 EXCEPTION OCCURRED");
      debugPrint("Error: $e");
      debugPrint("StackTrace: $stack");

      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}

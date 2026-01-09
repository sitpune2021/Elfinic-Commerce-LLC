import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:elfinic_commerce_llc/services/api_service.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordService {
  static Future<Map<String, dynamic>> sendOtp({
    required String mobile,
  }) async {
    try {
      // 🔹 Step 1: Print API URL
      debugPrint("🔵 ForgotPassword API URL: ${ApiService.forgotOtpSend}");

      // 🔹 Step 2: Print request body
      final requestBody = {
        "mobile": mobile,
      };
      debugPrint("📤 Request Body: ${jsonEncode(requestBody)}");

      // 🔹 Step 3: API Call
      final response = await http.post(
        Uri.parse(ApiService.forgotOtpSend),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // 🔹 Step 4: Print status code
      debugPrint("✅ Status Code: ${response.statusCode}");

      // 🔹 Step 5: Print raw response body
      debugPrint("📥 Response Body: ${response.body}");

      // 🔹 Step 6: Decode response
      final data = jsonDecode(response.body);
      debugPrint("📦 Decoded Response: $data");

      // 🔹 Step 7: Handle success / failure
      if (response.statusCode == 200) {
        debugPrint("🟢 OTP sent successfully");

        return {
          "success": true,
          "data": data,
        };
      } else {
        debugPrint("🔴 API Error: ${data["message"]}");

        return {
          "success": false,
          "message": data["message"] ?? "Something went wrong",
        };
      }
    } catch (e, stackTrace) {
      // 🔹 Step 8: Catch exception
      debugPrint("❌ Exception Occurred: $e");
      debugPrint("📛 StackTrace: $stackTrace");

      return {
        "success": false,
        "message": "Network error. Please try again.",
      };
    }
  }

  // verify otp _+ set password
  static Future<Map<String, dynamic>> verifyOtpAndSetPassword({
    required String mobile,
    required String otp,
    required String password,
  }) async {
    try {
      debugPrint("🔵 Reset Password API: ${ApiService.forgotOtpVerify}");

      final body = {
        "mobile": mobile,
        "otp": otp,
        "password": password,
      };

      debugPrint("📤 Request Body: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse(ApiService.forgotOtpVerify),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      debugPrint("📥 Response: $data");

      if (response.statusCode == 200) {
        return {"success": true};
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Network error",
      };
    }
  }
}

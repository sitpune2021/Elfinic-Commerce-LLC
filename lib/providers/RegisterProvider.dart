import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/RegisterResponse.dart';
import 'package:flutter/foundation.dart';
import '../model/RegisterResponse.dart';
import '../services/api_service.dart';

class RegisterProvider with ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  RegisterResponse? registerResponse;

  final ApiService _apiService = ApiService();

  Future<void> registerUser({
    required String name,
    required String email,
    required String mobile,
    required String username,
    required String password,
    required String passwordConfirmation,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      registerResponse = await _apiService.register(
        name: name,
        email: email,
        mobile: mobile,
        username: username,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (registerResponse!.status.toLowerCase() != "success") {
        errorMessage = registerResponse!.message;
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}

/*
class RegisterProvider with ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  RegisterResponse? registerResponse;

  Future<void> registerUser({
    required String name,
    required String email,
    required String mobile,
    required String username,
    required String password,
    required String passwordConfirmation,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final url = Uri.parse('https://business.elfinic.com/api/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "mobile": mobile,
          "username": username,
          "password": password,
          "password_confirmation": passwordConfirmation,
        }),
      );

      /// 🔹 Debugging logs
      debugPrint("➡️ Register API Request: ${url.toString()}");
      debugPrint("📩 Request Body: ${jsonEncode({
        "name": name,
        "email": email,
        "mobile": mobile,
        "username": username,
        "password": password,
        "password_confirmation": passwordConfirmation,
      })}");
      debugPrint("⬅️ Response Status: ${response.statusCode}");
      debugPrint("⬅️ Response Body: ${response.body}");

      /// ✅ Handle both 200 & 201
      if (response.statusCode == 200 || response.statusCode == 201) {
        registerResponse = RegisterResponse.fromRawJson(response.body);

        if (registerResponse!.status.toLowerCase() == "success") {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("auth_token", registerResponse!.token);

          debugPrint("✅ Registration Success: Token saved = ${registerResponse!.token}");
        } else {
          errorMessage = registerResponse!.message;
          debugPrint("⚠️ Registration Failed: $errorMessage");
        }
      } else {
        errorMessage = "Registration failed: ${response.statusCode}";
        debugPrint("❌ Error: $errorMessage");
      }
    } catch (e, st) {
      errorMessage = e.toString();
      debugPrint("🔥 Exception during registration: $errorMessage");
      debugPrint("StackTrace: $st");
    }

    isLoading = false;
    notifyListeners();
  }
}
*/

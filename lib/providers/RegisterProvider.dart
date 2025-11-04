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


// ignore_for_file: file_names

import '../model/RegisterResponse.dart';
import '../services/api_service.dart';

import 'package:flutter/material.dart';

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

      if (registerResponse?.status != "success") {
        errorMessage = registerResponse?.message;
      }
    } catch (e) {
      debugPrint("REGISTER ERROR: $e");
      errorMessage = "Network error. Please try again.";
    }

    isLoading = false;
    notifyListeners();
  }
}

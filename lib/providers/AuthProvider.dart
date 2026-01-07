// ignore_for_file: file_names

import 'package:flutter/material.dart';

import '../model/LoginResponse.dart';
import '../services/api_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _authService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LoginResponse? _loginResponse;
  LoginResponse? get loginResponse => _loginResponse;

  /// Login function with proper error handling
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _loginResponse = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);

      if (response.status.toLowerCase() == "success" &&
          response.token != null &&
          response.user != null) {
        _loginResponse = response;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", response.token!);
        await prefs.setString("user_id", response.user!.id.toString());
        await prefs.setString("user_name", response.user!.name);
        await prefs.setString("user_email", response.user!.email);
      } else {
        _loginResponse = null;
        _errorMessage = response.message ?? "Invalid email or password";
      }
    } catch (e) {
      _loginResponse = null;

      if (e is Exception) {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        _errorMessage = "Something went wrong. Please try again.";
      }

      debugPrint("Login error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optional: Logout function to clear saved user info
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("user_id");
    await prefs.remove("user_name");
    await prefs.remove("user_email");

    _loginResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
}

/*
class AuthProvider with ChangeNotifier {
  final ApiService _authService = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LoginResponse? _loginResponse;
  LoginResponse? get loginResponse => _loginResponse;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _loginResponse = await _authService.login(email, password);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
*/

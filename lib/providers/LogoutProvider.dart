import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/LogoutResponse.dart';


import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class LogoutProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  LogoutResponse? _logoutResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LogoutResponse? get logoutResponse => _logoutResponse;

  /// ✅ LOGOUT FUNCTION
  Future<void> logout(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _logoutResponse = await _apiService.logout(email, password);

      if (_logoutResponse?.status == "success") {
        // ✅ Clear SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        print("✅ Logout successful. All session data removed.");
      } else {
        _errorMessage = _logoutResponse?.message ?? "Logout failed.";
        print("⚠️ Logout failed: $_errorMessage");
      }
    } catch (e) {
      _errorMessage = "Error: $e";
      print("🔥 Exception during logout: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}

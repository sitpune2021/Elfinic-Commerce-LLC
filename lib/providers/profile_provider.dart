import 'dart:convert';

import 'package:elfinic_commerce_llc/model/LoginResponse.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user_data");

    if (userJson != null) {
      _user = User.fromJson(jsonDecode(userJson));
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearProfile() {
    _user = null;
    notifyListeners();
  }
}

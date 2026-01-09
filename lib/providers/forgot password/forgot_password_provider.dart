import 'package:elfinic_commerce_llc/services/forgot_password_service.dart';
import 'package:flutter/material.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> sendOtp(String mobile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ForgotPasswordService.sendOtp(mobile: mobile);

    _isLoading = false;

    if (response["success"] == true) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = response["message"];
      notifyListeners();
      return false;
    }
  }

  // 🔹 VERIFY OTP + SET PASSWORD (SAME API)
  Future<bool> verifyOtpAndSetPassword({
    required String mobile,
    required String otp,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await ForgotPasswordService.verifyOtpAndSetPassword(
      mobile: mobile,
      otp: otp,
      password: password,
    );

    _isLoading = false;

    if (response["success"] == true) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = response["message"];
      notifyListeners();
      return false;
    }
  }
}

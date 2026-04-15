import 'dart:io';

import 'package:elfinic_commerce_llc/model/LoginResponse.dart';
import 'package:elfinic_commerce_llc/model/UserProfileModel.dart';
import 'package:elfinic_commerce_llc/services/profile_service.dart';
import 'package:flutter/material.dart';

class ProfileProvider with ChangeNotifier {
  // 🔹 Logged-in user (from prefs)
  User? _user;
  User? get user => _user;

  // 🔹 Profile API data
  UserProfileModel? _profile;
  UserProfileModel? get profile => _profile;

  // 🔹 Loading & error
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  double _uploadProgress = 0.0;
  String? _errorMessage;

  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;


  // get profile data
  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await ProfileService.getUserProfileData();
      if (_profile == null) {
        _error = 'Failed to load profile';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // UPDATE PROFILE
  Future<bool> updateProfile({
    required String name,
    required String mobile,
    File? photo,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();

    final result = await ProfileService.updateUserProfile(
      name: name,
      mobile: mobile,
      photo: photo,
      onProgress: (progress) {
        _uploadProgress = progress;
        notifyListeners();
      },
    );
    if (result['success'] == true) {
      _profile = UserProfileModel(
        status: _profile!.status,
        data: Data(
          id: _profile!.data.id,
          name: name,
          email: _profile!.data.email,
          mobile: mobile,
          photo: photo != null ? photo.path : _profile!.data.photo,
        ),
      );

      _isLoading = false;
      _uploadProgress = 0.0;
      notifyListeners();

      // optional background refresh
      fetchUserProfile();

      return true;
    } else {
      _isLoading = false;
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  void clearProfile() {
    _user = null;
    _profile = null;
    notifyListeners();
  }
}

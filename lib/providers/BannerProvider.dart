import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/BannersResponse.dart';


import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/BannersResponse.dart';
import '../services/api_service.dart';

class BannerProvider with ChangeNotifier {
  List<BannerData> _banners = [];
  bool _isLoading = false;
  String? _error;

  List<BannerData> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// ✅ Now exactly like fetchCategories format
  Future<void> fetchBanners({required String type}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Uri url = ApiService.getBannersByTypeUrl(type);

      final response = await http.get(url);

      /// ✅ Unified logging just like categories
      logApiCall(
        method: 'GET',
        url: url,
        response: response,
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['status'] == 'success') {
          final List data = jsonData['data'];

          _banners = data
              .map<BannerData>((e) => BannerData.fromJson(e))
              .toList();
        } else {
          _error = jsonData['message'] ?? 'Failed to load banners';
        }
      } else {
        throw Exception(
            'Failed to load banners (${response.statusCode})');
      }
    } catch (e, st) {
      debugPrint("fetchBanners error: $e\n$st");
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearBanners() {
    _banners.clear();
    notifyListeners();
  }
}


// class BannerProvider with ChangeNotifier {
//   List<BannerData> _banners = [];
//   bool _isLoading = false;
//   String? _error;
//
//   List<BannerData> get banners => _banners;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//
//   Future<void> fetchBanners() async {
//     if (_isLoading) return;
//
//     _isLoading = true;
//     _error = null;
//     notifyListeners();
//
//     final String url = '${ApiService.baseUrl}/api/getBannersByType?type=slider';
//     try {
//       print('📡 Fetching Banners from: $url');
//
//       final response = await http.get(Uri.parse(url));
//
//       print('🔹 Response Status Code: ${response.statusCode}');
//       print('🔹 Raw Response Body: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//
//         if (jsonResponse['status'] == 'success') {
//           final List data = jsonResponse['data'];
//           _banners = data.map((e) => BannerData.fromJson(e)).toList();
//           print('✅ Banners fetched: ${_banners.length}');
//         } else {
//           _error = jsonResponse['message'] ?? 'Failed to fetch banners';
//           print('⚠️ Error Message: $_error');
//         }
//       } else {
//         _error = 'Error: ${response.statusCode}';
//         print('❌ HTTP Error: $_error');
//       }
//     } catch (e) {
//       _error = 'Failed to fetch banners: $e';
//       print('🚨 Exception: $e');
//     }
//
//     _isLoading = false;
//     notifyListeners();
//   }
// }

// providers/address_provider.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/AddressModel.dart';
// providers/address_provider.dart (Enhanced logging version)
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/AddressModel.dart';

// providers/address_provider.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/AddressModel.dart';


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/AddressModel.dart';
import '../services/api_service.dart';

class AddressProvider with ChangeNotifier {
  static const String _baseUrl = 'https://admin.elfinic.com/api';
  // static String _baseUrl = ApiService.baseUrl;

  bool _isLoading = false;
  String? _errorMessage;
  List<Address> _addresses = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Address> get addresses => _addresses;


  /// ✅ Reset loading state
  void resetLoading() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// ✅ Fetch all saved addresses for the logged-in user
  Future<void> fetchAddresses() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final userId = prefs.getString('user_id') ?? '';

      final url = Uri.parse('$_baseUrl/addresses/getallAdresses?user_id=$userId');

      // Debug print the URL and headers
      print('📡 [GET ADDRESSES]');
      print('🔗 URL: $url');
      print('🔐 Token: ${token.isNotEmpty ? "Provided ✅" : "Not Provided ❌"}');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      // Use the new logApiCall function
      logApiCall(
        method: 'GET',
        url: url,
        response: response,
        headers: {
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        tag: 'GET ADDRESSES',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          _addresses =
              (decoded['data'] as List).map((e) => Address.fromJson(e)).toList();
          print('✅ Fetched ${_addresses.length} addresses');
        } else {
          _addresses = [];
          print('⚠️ No addresses found in response');
        }
      } else {
        _errorMessage =
        'Failed to fetch addresses. Status: ${response.statusCode}';
        _addresses = [];
        print('❌ Error fetching addresses: $_errorMessage');
      }
    } catch (e, stackTrace) {
      _errorMessage = 'Network error: $e';
      _addresses = [];
      print('🚨 Exception in fetchAddresses: $e');
      print(stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logApiCall({
    required String method,
    required Uri url,
    required http.Response response,
    Map<String, String>? headers,
    String? tag,
  }) {
    debugPrint('${tag != null ? '[$tag] ' : ''}➡️ API [$method] ${url.toString()}');
    if (headers != null) {
      debugPrint('📋 Headers: $headers');
    }
    debugPrint('📊 Status: ${response.statusCode}');
    debugPrint('📦 Response: ${response.body}');
  }
/*
  Future<void> fetchAddresses() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final userId = prefs.getString('user_id') ?? '';

      final url = Uri.parse('$_baseUrl/addresses/getallAdresses?user_id=$userId');

      // Debug print the URL and headers
      print('📡 [GET ADDRESSES]');
      print('🔗 URL: $url');
      print('🔐 Token: ${token.isNotEmpty ? "Provided ✅" : "Not Provided ❌"}');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      // Debug print response status and body
      print('📊 STATUS CODE: ${response.statusCode}');
      print('📦 RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 'success' && decoded['data'] != null) {
          _addresses =
              (decoded['data'] as List).map((e) => Address.fromJson(e)).toList();
          print('✅ Fetched ${_addresses.length} addresses');
        } else {
          _addresses = [];
          print('⚠️ No addresses found in response');
        }
      } else {
        _errorMessage =
        'Failed to fetch addresses. Status: ${response.statusCode}';
        _addresses = [];
        print('❌ Error fetching addresses: $_errorMessage');
      }
    } catch (e, stackTrace) {
      _errorMessage = 'Network error: $e';
      _addresses = [];
      print('🚨 Exception in fetchAddresses: $e');
      print(stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
*/

  bool get hasAddresses => _addresses.isNotEmpty;

  /// ✅ Add new address
  Future<bool> addAddress(Address address) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newAddress = await ApiService.addAddressApi(address: address);
      _addresses.add(newAddress);
      notifyListeners();
      print('✅ Address added successfully (ID: ${newAddress.id})');
      return true;
    } catch (e, stackTrace) {
      _errorMessage = 'Error adding address: $e';
      print('🚨 Exception in addAddress(): $e');
      print(stackTrace);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Update an existing address
  Future<bool> updateAddress(Address address) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await ApiService.updateAddressApi(address: address);
      if (success) {
        print('🎉 Address updated successfully!');
        // Refresh the addresses list
        await fetchAddresses();
        return true;
      } else {
        _errorMessage = 'Failed to update address';
        print('❌ API Error: $_errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      print('💥 Exception: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Delete an address
  Future<bool> deleteAddress(int addressId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await ApiService.deleteAddressApi(addressId: addressId);
      if (success) {
        // Remove the address from the local list
        _addresses.removeWhere((address) => address.id == addressId);
        notifyListeners();
        print('✅ Address deleted successfully (ID: $addressId)');
        return true;
      } else {
        _errorMessage = 'Failed to delete address';
        return false;
      }
    } catch (e, stackTrace) {
      _errorMessage = 'Error deleting address: $e';
      print('🚨 Exception in deleteAddress(): $e');
      print(stackTrace);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

  /// ✅ Clear error messages


// class AddressService {
//   static const String baseUrl = 'https://business.elfinic.com/api';
//
//   Future<Map<String, dynamic>> addAddress(Address address, {String? authToken}) async {
//     final url = '$baseUrl/addresses/addaddress';
//     final requestBody = address.toJson();
//
//     // Prepare headers with auth token if available
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };
//
//     if (authToken != null && authToken.isNotEmpty) {
//       headers['Authorization'] = 'Bearer $authToken';
//     }
//
//     // Print detailed request information
//     print('\n' + '='*50);
//     print('🌐 API REQUEST DETAILS');
//     print('='*50);
//     print('📡 METHOD: POST');
//     print('🔗 URL: $url');
//     print('⏰ Timestamp: ${DateTime.now()}');
//     print('🔐 AUTH: ${authToken != null ? "Bearer Token Provided" : "No Auth Token"}');
//     print('📦 REQUEST BODY:');
//     _printFormattedJson(requestBody);
//     print('📋 HEADERS:');
//     headers.forEach((key, value) {
//       if (key == 'Authorization' && authToken != null) {
//         print('   - $key: Bearer ***${authToken.substring(authToken.length - 8)}'); // Show last 8 chars for debugging
//       } else {
//         print('   - $key: $value');
//       }
//     });
//     print('='*50 + '\n');
//
//     try {
//       final stopwatch = Stopwatch()..start();
//       final response = await http.post(
//         Uri.parse(url),
//         headers: headers,
//         body: json.encode(requestBody),
//       );
//       stopwatch.stop();
//
//       // Print detailed response information
//       print('\n' + '='*50);
//       print('📨 API RESPONSE DETAILS');
//       print('='*50);
//       print('⏱️  Response Time: ${stopwatch.elapsedMilliseconds}ms');
//       print('📊 STATUS CODE: ${response.statusCode}');
//       print('🔗 RESPONSE URL: ${response.request?.url}');
//       print('📄 RESPONSE BODY:');
//       _printFormattedJsonResponse(response.body);
//       print('📋 RESPONSE HEADERS:');
//       response.headers.forEach((key, value) => print('   - $key: $value'));
//       print('='*50 + '\n');
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);
//
//         print('🎉 API CALL SUCCESSFUL');
//         print('💬 Message: ${responseData['message']}');
//         if (responseData['data'] != null && responseData['data']['id'] != null) {
//           print('🆔 New Address ID: ${responseData['data']['id']}');
//         } else {
//           print('🆔 New Address ID: Not provided in response');
//         }
//
//         return {
//           'success': true,
//           'data': Address.fromJson(responseData['data']),
//           'message': responseData['message'],
//         };
//       } else if (response.statusCode == 401) {
//         print('🔒 UNAUTHORIZED: Invalid or missing authentication token');
//         return {
//           'success': false,
//           'message': 'Authentication failed. Please login again.',
//         };
//       } else if (response.statusCode == 403) {
//         print('🚫 FORBIDDEN: Access denied');
//         return {
//           'success': false,
//           'message': 'Access denied. You do not have permission to perform this action.',
//         };
//       } else if (response.statusCode == 422) {
//         // Validation errors
//         final Map<String, dynamic> errorData = json.decode(response.body);
//         print('📝 VALIDATION ERRORS:');
//         if (errorData['errors'] != null) {
//           errorData['errors'].forEach((key, value) {
//             print('   - $key: $value');
//           });
//         }
//         return {
//           'success': false,
//           'message': errorData['message'] ?? 'Please check your input and try again.',
//         };
//       } else {
//         final Map<String, dynamic> errorData = json.decode(response.body);
//
//         print('❌ API CALL FAILED');
//         print('💬 Error Message: ${errorData['message'] ?? 'Unknown error'}');
//         print('🔍 Error Details: $errorData');
//
//         return {
//           'success': false,
//           'message': errorData['message'] ?? 'Failed to add address. Status: ${response.statusCode}',
//         };
//       }
//     } catch (e, stackTrace) {
//       print('\n' + '='*50);
//       print('🚨 EXCEPTION DETAILS');
//       print('='*50);
//       print('💥 Exception: $e');
//       print('📛 Exception Type: ${e.runtimeType}');
//       print('🔍 Stack Trace:');
//       print(stackTrace);
//       print('='*50 + '\n');
//
//       return {
//         'success': false,
//         'message': 'Network error: $e',
//       };
//     }
//   }
//
//   // Helper method to print formatted JSON
//   void _printFormattedJson(Map<String, dynamic> json) {
//     final encoder = JsonEncoder.withIndent('  ');
//     print(encoder.convert(json));
//   }
//
//   // Helper method to print formatted JSON response
//   void _printFormattedJsonResponse(String responseBody) {
//     try {
//       final jsonResponse = json.decode(responseBody);
//       final encoder = JsonEncoder.withIndent('  ');
//       print(encoder.convert(jsonResponse));
//     } catch (e) {
//       print('⚠️  Could not parse JSON response');
//       print('Raw response: $responseBody');
//     }
//   }
//
//   // Optional: Add method to get addresses if needed
//   Future<Map<String, dynamic>> getAddresses({String? authToken}) async {
//     final url = '$baseUrl/addresses';
//
//     Map<String, String> headers = {
//       'Accept': 'application/json',
//     };
//
//     if (authToken != null && authToken.isNotEmpty) {
//       headers['Authorization'] = 'Bearer $authToken';
//     }
//
//     print('\n🌐 GET Addresses from: $url');
//
//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: headers,
//       );
//
//       if (response.statusCode == 200) {
//         final List<dynamic> responseData = json.decode(response.body);
//         print('✅ Retrieved ${responseData.length} addresses');
//         return {
//           'success': true,
//           'data': responseData.map((item) => Address.fromJson(item)).toList(),
//         };
//       } else {
//         return {
//           'success': false,
//           'message': 'Failed to fetch addresses. Status: ${response.statusCode}',
//         };
//       }
//     } catch (e) {
//       print('🚨 Error fetching addresses: $e');
//       return {
//         'success': false,
//         'message': 'Network error: $e',
//       };
//     }
//   }
// }
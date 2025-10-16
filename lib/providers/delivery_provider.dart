// providers/delivery_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/delivery_type.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';
class DeliveryProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<DeliveryType> _deliveryTypes = [];
  DeliveryType? _selectedType;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DeliveryType> get deliveryTypes => _deliveryTypes;
  DeliveryType? get selectedType => _selectedType;

  Future<void> fetchDeliveryTypes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _deliveryTypes = await ApiService.fetchDeliveryTypes();

      // Select "Normal" by default
      _selectedType = _deliveryTypes.firstWhere(
            (type) => type.type.toLowerCase() == 'normal',
        orElse: () => _deliveryTypes.isNotEmpty
            ? _deliveryTypes.first
            : DeliveryType(
          id: 0,
          type: 'Normal',
          charge: 0,
          minOrderAmount: 0,
          days: 'N/A',
        ),
      );

    } catch (e) {
      _errorMessage = 'Failed to fetch delivery types: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectType(DeliveryType type) {
    _selectedType = type;
    notifyListeners();
  }

  double get selectedDeliveryCost => _selectedType?.charge ?? 0.0;
}
/*
class DeliveryProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<DeliveryType> _deliveryTypes = [];
  DeliveryType? _selectedType;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DeliveryType> get deliveryTypes => _deliveryTypes;
  DeliveryType? get selectedType => _selectedType;

  Future<void> fetchDeliveryTypes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // const url = 'https://admin.elfinic.com/api/delivery-charges/getallDeliveryType';

    final url = '${ApiService.baseUrl}/api/delivery-charges/getallDeliveryType';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          _deliveryTypes = (data['data'] as List)
              .map((e) => DeliveryType.fromJson(e))
              .toList();

          // Select "Normal" by default
          _selectedType = _deliveryTypes.firstWhere(
                (type) => type.type.toLowerCase() == 'normal',
            orElse: () => _deliveryTypes.isNotEmpty
                ? _deliveryTypes.first
                : DeliveryType(
              id: 0,
              type: 'Normal',
              charge: 0,
              minOrderAmount: 0,
              days: 'N/A',
            ),


    );

        } else {
          _errorMessage = data['message'] ?? 'Failed to fetch delivery types';
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectType(DeliveryType type) {
    _selectedType = type;
    notifyListeners();
  }

  double get selectedDeliveryCost => _selectedType?.charge ?? 0.0;
}
*/

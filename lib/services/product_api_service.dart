import 'dart:convert';
import 'package:elfinic_commerce_llc/model/search_product_list_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ProductApiService {
  static const String _baseUrl =
      'https://admin.elfinic.com/api/getProductsFilterList';

  Future<SearchProductFilterListModel> getProducts({
    required String name,
    required int page,
    required int perPage,
  }) async {
    debugPrint("========== SERVICE START ==========");
    debugPrint("Keyword  : $name");
    debugPrint("Page     : $page");
    debugPrint("PerPage  : $perPage");

    final url = Uri.parse("$_baseUrl?name=$name&page=$page&per_page=$perPage");

    debugPrint("URL      : $url");

    try {
      final response = await http.get(url);
      debugPrint("Status   : ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List list = decoded['data'] ?? [];

        debugPrint("Items    : ${list.length}");
        debugPrint("========== SERVICE END ==========\n");

        return SearchProductFilterListModel.fromJson(decoded);
      } else {
        debugPrint("SERVICE ERROR");
        throw Exception("API Error");
      }
    } catch (e) {
      debugPrint("SERVICE EXCEPTION : $e");
      rethrow;
    }
  }
}

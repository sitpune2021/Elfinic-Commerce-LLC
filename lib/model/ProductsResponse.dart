import 'dart:convert';
import 'dart:convert';

import 'dart:convert';
import 'dart:convert';

class ProductsResponse {
  final bool status;
  final List<Product> data;

  ProductsResponse({
    required this.status,
    required this.data,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      status: json['status']?.toString().toLowerCase() == "success",
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  factory ProductsResponse.fromRawJson(String str) =>
      ProductsResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

class Product {
  final int id;
  final String name;
  final int categoryId;
  final List<int> subcategoryIds; // now from proper list
  final String sku;
  final String barcode;
  final List<String> images;      // now from proper list
  final String? productThumb;
  final String? productOptions;
  final String? productValues;
  final String description;
  final double price;
  final double discountPrice;
  final int stock;
  final int quantity;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.subcategoryIds,
    required this.sku,
    required this.barcode,
    required this.images,
    this.productThumb,
    this.productOptions,
    this.productValues,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.stock,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      categoryId: int.tryParse(json['category_id'].toString()) ?? 0,
      subcategoryIds: (json['subcategory_id'] as List<dynamic>? ?? [])
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList(),
      sku: json['sku'] ?? '',
      barcode: json['barcode'] ?? '',
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      productThumb: json['product_thumb'],
      productOptions: json['product_options']?.toString(),
      productValues: json['product_values']?.toString(),
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString().replaceAll(',', '')) ?? 0,
      discountPrice: double.tryParse(json['discount_price'].toString().replaceAll(',', '')) ?? 0,
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'subcategory_id': subcategoryIds,
      'sku': sku,
      'barcode': barcode,
      'images': images,
      'product_thumb': productThumb,
      'product_options': productOptions,
      'product_values': productValues,
      'description': description,
      'price': price.toString(),
      'discount_price': discountPrice.toString(),
      'stock': stock.toString(),
      'quantity': quantity,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}




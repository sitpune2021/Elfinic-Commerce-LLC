import 'dart:convert';


import 'dart:convert';
import 'dart:convert';

class ProductsResponse {
  final bool status;
  final String message;
  final Pagination? pagination;
  final List<Product> data;

  ProductsResponse({
    required this.status,
    required this.message,
    this.pagination,
    required this.data,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    bool parsedStatus = false;

    if (rawStatus is bool) {
      parsedStatus = rawStatus;
    } else if (rawStatus is String) {
      parsedStatus = ['true', 'success', '1', 'yes']
          .contains(rawStatus.toLowerCase().trim());
    } else if (rawStatus is num) {
      parsedStatus = rawStatus != 0;
    }

    return ProductsResponse(
      status: parsedStatus,
      message: json['message']?.toString() ?? '',
      pagination: json['pagination'] != null
          ? Pagination.fromJson(
          Map<String, dynamic>.from(json['pagination']))
          : null,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  factory ProductsResponse.fromRawJson(String str) =>
      ProductsResponse.fromJson(json.decode(str));

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'pagination': pagination?.toJson(),
    'data': data.map((e) => e.toJson()).toList(),
  };
}
class Pagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: _parseInt(json['current_page']),
      lastPage: _parseInt(json['last_page']),
      perPage: _parseInt(json['per_page']),
      total: _parseInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'last_page': lastPage,
    'per_page': perPage,
    'total': total,
  };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
class Product {
  final int id;
  final String name;
  final String? slug;
  final String? brand;
  final String? category;
  final List<String> subcategory;
  final double price;
  final double discountPrice;
  final double totalPrice;
  final int stock;
  final String sku;
  final int quantity;
  final String status;
  final String? showSection;
  final int ratingCount;
  final double averageRating;
  final List<String> images;
  final String? productThumb;
  final String? imagePath;

  Product({
    required this.id,
    required this.name,
    this.slug,
    this.brand,
    this.category,
    required this.subcategory,
    required this.price,
    required this.discountPrice,
    required this.totalPrice,
    required this.stock,
    required this.sku,
    required this.quantity,
    required this.status,
    this.showSection,
    required this.ratingCount,
    required this.averageRating,
    required this.images,
    this.productThumb,
    this.imagePath,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      brand: json['brand']?.toString(),
      category: json['category']?.toString(),
      subcategory: _parseStringList(json['subcategory']),
      price: _parseDouble(json['price']),
      discountPrice: _parseDouble(json['discount_price']),
      totalPrice: _parseDouble(json['total_price']),
      stock: _parseInt(json['stock']),
      sku: json['sku']?.toString() ?? '',
      quantity: _parseInt(json['quantity']),
      status: json['status']?.toString() ?? '',
      showSection: json['show_section']?.toString(),
      ratingCount: _parseInt(json['ratingCount']),
      averageRating: _parseDouble(json['averageRating']),
      images: _parseStringList(json['images']),
      productThumb: json['product_thumb']?.toString(),
      imagePath: json['image_path']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'brand': brand,
    'category': category,
    'subcategory': subcategory,
    'price': price,
    'discount_price': discountPrice,
    'total_price': totalPrice,
    'stock': stock,
    'sku': sku,
    'quantity': quantity,
    'status': status,
    'show_section': showSection,
    'ratingCount': ratingCount,
    'averageRating': averageRating,
    'images': images,
    'product_thumb': productThumb,
    'image_path': imagePath,
  };

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString().replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(
        value.toString().replaceAll(RegExp(r'[^\d.]'), '')) ??
        0.0;
  }
}












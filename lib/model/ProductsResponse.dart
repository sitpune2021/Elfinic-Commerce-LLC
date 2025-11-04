import 'dart:convert';
import 'dart:convert';

import 'dart:convert';
import 'dart:convert';

import 'dart:convert';
import 'dart:convert';

class ProductsResponse {
  final bool status;
  final String message;
  final List<Product> data;

  ProductsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
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
  final String? brand;
  final String? category;
  final String? subcategory;
  final String? description;
  final double price;
  final double discountPrice;
  final double totalPrice;
  final int stock;
  final String? vendor;
  final String? vendorId;
  final String sku;
  final String? barcode;
  final String? gst;
  int quantity;
  final String status;
  final int ratingCount;
  final double averageRating;
  final List<String> images;
  final String? productThumb;
  final List<ProductOption> options;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    this.brand,
    this.category,
    this.subcategory,
    this.description,
    required this.price,
    required this.discountPrice,
    required this.totalPrice,
    required this.stock,
    this.vendor,
    this.vendorId,
    required this.sku,
    this.barcode,
    this.gst,
    required this.quantity,
    required this.status,
    required this.ratingCount,
    required this.averageRating,
    required this.images,
    this.productThumb,
    required this.options,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'],
      category: json['category'],
      subcategory: json['subcategory'],
      description: json['description'],
      price: _parseDouble(json['price']),
      discountPrice: _parseDouble(json['discount_price']),
      totalPrice: _parseDouble(json['total_price']),
      stock: _parseInt(json['stock']),
      vendor: json['vendor'],
      vendorId: _parseVendorId(json['vendorId']),
      sku: json['sku'] ?? '',
      barcode: json['barcode'],
      gst: _parseGst(json['gst']),
      quantity: _parseInt(json['quantity']),
      status: json['status']?.toString() ?? '',
      ratingCount: _parseInt(json['ratingCount']),
      averageRating: _parseDouble(json['averageRating']),
      images: _parseImages(json['images']),
      productThumb: json['product_thumb'],
      options: _parseOptions(json['options']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static String? _parseVendorId(dynamic vendorId) {
    if (vendorId == null) return null;
    if (vendorId is String) return vendorId;
    return vendorId.toString();
  }

  static String? _parseGst(dynamic gst) {
    if (gst == null) return null;
    if (gst is String) return gst;
    return gst.toString();
  }

  static List<String> _parseImages(dynamic images) {
    if (images == null) return [];
    if (images is List) {
      return images
          .whereType<String>()
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    return [];
  }

  static List<ProductOption> _parseOptions(dynamic options) {
    if (options == null) return [];
    if (options is List) {
      return options
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductOption.fromJson(e))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'subcategory': subcategory,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'total_price': totalPrice,
      'stock': stock,
      'vendor': vendor,
      'vendorId': vendorId,
      'sku': sku,
      'barcode': barcode,
      'gst': gst,
      'quantity': quantity,
      'status': status,
      'ratingCount': ratingCount,
      'averageRating': averageRating,
      'images': images,
      'product_thumb': productThumb,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }

  // Helper methods
  bool get hasDiscount => discountPrice > 0 && discountPrice < price;

  double get discountPercentage => hasDiscount
      ? ((price - discountPrice) / price * 100)
      : 0;

  double get effectivePrice => hasDiscount ? discountPrice : price;

  // Copy with method for immutability
  Product copyWith({
    int? id,
    String? name,
    String? brand,
    String? category,
    String? subcategory,
    String? description,
    double? price,
    double? discountPrice,
    double? totalPrice,
    int? stock,
    String? vendor,
    String? vendorId,
    String? sku,
    String? barcode,
    String? gst,
    int? quantity,
    String? status,
    int? ratingCount,
    double? averageRating,
    List<String>? images,
    String? productThumb,
    List<ProductOption>? options,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      stock: stock ?? this.stock,
      vendor: vendor ?? this.vendor,
      vendorId: vendorId ?? this.vendorId,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      gst: gst ?? this.gst,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      ratingCount: ratingCount ?? this.ratingCount,
      averageRating: averageRating ?? this.averageRating,
      images: images ?? this.images,
      productThumb: productThumb ?? this.productThumb,
      options: options ?? this.options,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class ProductOption {
  final String optionType;
  final String displayType;
  final List<String>? size;
  final List<String>? color;
  final List<String>? choices;

  ProductOption({
    required this.optionType,
    required this.displayType,
    this.size,
    this.color,
    this.choices,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      optionType: json['option_type'] ?? '',
      displayType: json['display_type'] ?? '',
      size: (json['size'] as List?)?.map((e) => e.toString()).toList(),
      color: (json['color'] as List?)?.map((e) => e.toString()).toList(),
      choices: (json['choices'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option_type': optionType,
      'display_type': displayType,
      'size': size,
      'color': color,
      'choices': choices,
    };
  }
}

/*
class ProductsResponse {
  final bool status;
  final String message;
  final List<Product> data;

  ProductsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
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
  final String? brand;
  final String? category;
  final String? subcategory;
  final String? description;
  final double price;
  final double discountPrice;
  final double totalPrice;
  final int stock;
  final String? vendor;
  final String? vendorId;
  final String sku;
  final String? barcode;
  final String? gst;
  int quantity;
  final String status;
  final int ratingCount;
  final double averageRating;
  final List<String> images;
  final String? productThumb;
  final List<ProductOption> options;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    this.brand,
    this.category,
    this.subcategory,
    this.description,
    required this.price,
    required this.discountPrice,
    required this.totalPrice,
    required this.stock,
    this.vendor,
    this.vendorId,
    required this.sku,
    this.barcode,
    this.gst,
    required this.quantity,
    required this.status,
    required this.ratingCount,
    required this.averageRating,
    required this.images,
    this.productThumb,
    required this.options,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'],
      category: json['category'],
      subcategory: json['subcategory'],
      description: json['description'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      discountPrice: double.tryParse(json['discount_price']?.toString() ?? '0') ?? 0.0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      vendor: json['vendor'],
      vendorId: json['vendorId']?.toString(),
      sku: json['sku'] ?? '',
      barcode: json['barcode'],
      gst: json['gst']?.toString(),
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? '',
      ratingCount: int.tryParse(json['ratingCount']?.toString() ?? '0') ?? 0,
      averageRating: double.tryParse(json['averageRating']?.toString() ?? '0') ?? 0.0,
      images: _parseImages(json['images']),
      productThumb: json['product_thumb'],
      options: _parseOptions(json['options']),
    );
  }

  static List<String> _parseImages(dynamic images) {
    if (images == null) return [];
    if (images is List) {
      return images.whereType<String>().where((e) => e.trim().isNotEmpty).toList();
    }
    return [];
  }

  static List<ProductOption> _parseOptions(dynamic options) {
    if (options == null) return [];
    if (options is List) {
      return options
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductOption.fromJson(e))
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'subcategory': subcategory,
      'description': description,
      'price': price.toString(),
      'discount_price': discountPrice.toString(),
      'total_price': totalPrice.toString(),
      'stock': stock,
      'vendor': vendor,
      'vendorId': vendorId,
      'sku': sku,
      'barcode': barcode,
      'gst': gst,
      'quantity': quantity,
      'status': status,
      'ratingCount': ratingCount,
      'averageRating': averageRating,
      'images': images,
      'product_thumb': productThumb,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }

  // Helper methods
  bool get hasDiscount => discountPrice > 0 && discountPrice < price;
  double get discountPercentage => hasDiscount ? ((price - discountPrice) / price * 100) : 0;
  double get effectivePrice => hasDiscount ? discountPrice : price;
}

class ProductOption {
  final String optionType;
  final String displayType;
  final List<String>? size;
  final List<String>? color;

  ProductOption({
    required this.optionType,
    required this.displayType,
    this.size,
    this.color,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      optionType: json['option_type'] ?? '',
      displayType: json['display_type'] ?? '',
      size: _parseStringList(json['size']),
      color: _parseStringList(json['color']),
    );
  }

  static List<String>? _parseStringList(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.whereType<String>().toList();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'option_type': optionType,
      'display_type': displayType,
      'size': size,
      'color': color,
    };
  }

  List<String>? get availableOptions => size ?? color;
}
*/







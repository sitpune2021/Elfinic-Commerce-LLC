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
    // Accept both boolean true and strings like "success" or "true"
    final rawStatus = json['status'];
    bool parsedStatus = false;
    if (rawStatus is bool) {
      parsedStatus = rawStatus;
    } else if (rawStatus is String) {
      final s = rawStatus.toLowerCase().trim();
      parsedStatus = (s == 'true' || s == 'success' || s == '1' || s == 'yes');
    } else if (rawStatus is num) {
      parsedStatus = rawStatus != 0;
    }

    return ProductsResponse(
      status: parsedStatus,
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) {
        try {
          return Product.fromJson(Map<String, dynamic>.from(e));
        } catch (err) {
          // If a single product is malformed, print and skip it
          print('⚠️ Product parse error in ProductsResponse.fromJson: $err — raw: $e');
          return null;
        }
      })
          .where((p) => p != null)
          .map((p) => p as Product)
          .toList(),
    );
  }

  factory ProductsResponse.fromRawJson(String str) =>
      ProductsResponse.fromJson(json.decode(str) as Map<String, dynamic>);

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.map((e) => e.toJson()).toList(),
  };
}


class Product {
  final int id;
  final String name;
  final String? brand;
  final String? category;
  final List<String> subcategory;
  final String? productDetails;
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
  final int quantity;
  final String status;
  final String? showSection;
  final int ratingCount;
  final double averageRating;
  final List<String> images;
  final String? productThumb;
  final List<ProductOption> options;
  final List<ProductVariant> variants;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    this.brand,
    this.category,
    required this.subcategory,
    this.productDetails,
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
    this.showSection,
    required this.ratingCount,
    required this.averageRating,
    required this.images,
    this.productThumb,
    required this.options,
    required this.variants,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString(),
      category: json['category']?.toString(),
      subcategory: _parseStringList(json['subcategory']),
      productDetails: json['product_details']?.toString(),
      description: json['description']?.toString(),
      price: _parsePrice(json['price']),
      discountPrice: _parsePrice(json['discount_price']),
      totalPrice: _parsePrice(json['total_price']),
      stock: _parseInt(json['stock']),
      vendor: json['vendor']?.toString(),
      vendorId: json['vendorId']?.toString(),
      sku: json['sku']?.toString() ?? '',
      barcode: json['barcode']?.toString(),
      gst: json['gst']?.toString(),
      quantity: _parseInt(json['quantity']),
      status: json['status']?.toString() ?? '',
      showSection: json['show_section']?.toString(),
      ratingCount: _parseInt(json['ratingCount']),
      averageRating: _parseDouble(json['averageRating']),
      images: _parseStringList(json['images']),
      productThumb: json['product_thumb']?.toString(),
      options: _parseOptions(json['options']),
      variants: _parseVariants(json['variants']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'subcategory': subcategory,
      'product_details': productDetails,
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
      'show_section': showSection,
      'ratingCount': ratingCount,
      'averageRating': averageRating,
      'images': images,
      'product_thumb': productThumb,
      'options': options.map((e) => e.toJson()).toList(),
      'variants': variants.map((e) => e.toJson()).toList(),
      'isFavorite': isFavorite,
    };
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is String) {
      // Remove commas and any non-numeric characters except decimal point
      final cleaned = value.replaceAll(',', '').replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is String) {
      // Remove any non-numeric characters
      final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
      return int.tryParse(cleaned) ?? 0;
    }
    if (value is int) return value;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is String) {
      // Remove commas and any non-numeric characters except decimal point
      final cleaned = value.replaceAll(',', '').replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }

  static List<ProductOption> _parseOptions(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductOption.fromJson(e))
          .toList();
    }
    return [];
  }

  static List<ProductVariant> _parseVariants(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductVariant.fromJson(e))
          .toList();
    }
    return [];
  }
}

class ProductOption {
  final String optionType;
  final String displayType;
  final String name;
  final List<String> connectingImage;

  ProductOption({
    required this.optionType,
    required this.displayType,
    required this.name,
    required this.connectingImage,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      optionType: json['option_type']?.toString() ?? '',
      displayType: json['display_type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      connectingImage: Product._parseStringList(json['connecting_image']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option_type': optionType,
      'display_type': displayType,
      'name': name,
      'connecting_image': connectingImage,
    };
  }
}

class ProductVariant {
  final int id;
  final String variant;
  final double? priceDifference;
  final double? variantPrice;
  final double? costOfGoods;
  final String? sku;
  final int inventory;
  final double? shippingWeight;
  final String status;

  ProductVariant({
    required this.id,
    required this.variant,
    this.priceDifference,
    this.variantPrice,
    this.costOfGoods,
    this.sku,
    required this.inventory,
    this.shippingWeight,
    required this.status,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: Product._parseInt(json['id']),
      variant: json['variant']?.toString() ?? '',
      priceDifference: _parseNullableDouble(json['price_difference']),
      variantPrice: _parseNullableDouble(json['variant_price']),
      costOfGoods: _parseNullableDouble(json['cost_of_goods']),
      sku: json['sku']?.toString(),
      inventory: Product._parseInt(json['inventory']),
      shippingWeight: _parseNullableDouble(json['shipping_weight']),
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'variant': variant,
      'price_difference': priceDifference,
      'variant_price': variantPrice,
      'cost_of_goods': costOfGoods,
      'sku': sku,
      'inventory': inventory,
      'shipping_weight': shippingWeight,
      'status': status,
    };
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      if (value.isEmpty) return null;
      final cleaned = value.replaceAll(',', '').replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned);
    }
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return null;
  }
}


// class ProductsResponse {
//   final bool status;
//   final String message;
//   final List<Product> data;
//
//   ProductsResponse({
//     required this.status,
//     required this.message,
//     required this.data,
//   });
//
//   factory ProductsResponse.fromJson(Map<String, dynamic> json) {
//     return ProductsResponse(
//       status: json['status'] ?? false,
//       message: json['message'] ?? '',
//       data: (json['data'] as List<dynamic>? ?? [])
//           .map((e) => Product.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'status': status,
//       'message': message,
//       'data': data.map((e) => e.toJson()).toList(),
//     };
//   }
//
//   factory ProductsResponse.fromRawJson(String str) =>
//       ProductsResponse.fromJson(json.decode(str));
//
//   String toRawJson() => json.encode(toJson());
// }
//
// class Product {
//   final int id;
//   final String name;
//   final String? brand;
//   final String? category;
//   final String? subcategory;
//   final String? description;
//   final double price;
//   final double discountPrice;
//   final double totalPrice;
//   final int stock;
//   final String? vendor;
//   final String? vendorId;
//   final String sku;
//   final String? barcode;
//   final String? gst;
//   int quantity;
//   final String status;
//   final int ratingCount;
//   final double averageRating;
//   final List<String> images;
//   final String? productThumb;
//   final List<ProductOption> options;
//   bool isFavorite;
//
//   Product({
//     required this.id,
//     required this.name,
//     this.brand,
//     this.category,
//     this.subcategory,
//     this.description,
//     required this.price,
//     required this.discountPrice,
//     required this.totalPrice,
//     required this.stock,
//     this.vendor,
//     this.vendorId,
//     required this.sku,
//     this.barcode,
//     this.gst,
//     required this.quantity,
//     required this.status,
//     required this.ratingCount,
//     required this.averageRating,
//     required this.images,
//     this.productThumb,
//     required this.options,
//     this.isFavorite = false,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       brand: json['brand'],
//       category: json['category'],
//       subcategory: json['subcategory'],
//       description: json['description'],
//       price: _parseDouble(json['price']),
//       discountPrice: _parseDouble(json['discount_price']),
//       totalPrice: _parseDouble(json['total_price']),
//       stock: _parseInt(json['stock']),
//       vendor: json['vendor'],
//       vendorId: _parseVendorId(json['vendorId']),
//       sku: json['sku'] ?? '',
//       barcode: json['barcode'],
//       gst: _parseGst(json['gst']),
//       quantity: _parseInt(json['quantity']),
//       status: json['status']?.toString() ?? '',
//       ratingCount: _parseInt(json['ratingCount']),
//       averageRating: _parseDouble(json['averageRating']),
//       images: _parseImages(json['images']),
//       productThumb: json['product_thumb'],
//       options: _parseOptions(json['options']),
//     );
//   }
//
//   static double _parseDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) {
//       return double.tryParse(value) ?? 0.0;
//     }
//     return 0.0;
//   }
//
//   static int _parseInt(dynamic value) {
//     if (value == null) return 0;
//     if (value is int) return value;
//     if (value is double) return value.toInt();
//     if (value is String) {
//       return int.tryParse(value) ?? 0;
//     }
//     return 0;
//   }
//
//   static String? _parseVendorId(dynamic vendorId) {
//     if (vendorId == null) return null;
//     if (vendorId is String) return vendorId;
//     return vendorId.toString();
//   }
//
//   static String? _parseGst(dynamic gst) {
//     if (gst == null) return null;
//     if (gst is String) return gst;
//     return gst.toString();
//   }
//
//   static List<String> _parseImages(dynamic images) {
//     if (images == null) return [];
//     if (images is List) {
//       return images
//           .whereType<String>()
//           .where((e) => e.trim().isNotEmpty)
//           .toList();
//     }
//     return [];
//   }
//
//   static List<ProductOption> _parseOptions(dynamic options) {
//     if (options == null) return [];
//     if (options is List) {
//       return options
//           .whereType<Map<String, dynamic>>()
//           .map((e) => ProductOption.fromJson(e))
//           .toList();
//     }
//     return [];
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'brand': brand,
//       'category': category,
//       'subcategory': subcategory,
//       'description': description,
//       'price': price,
//       'discount_price': discountPrice,
//       'total_price': totalPrice,
//       'stock': stock,
//       'vendor': vendor,
//       'vendorId': vendorId,
//       'sku': sku,
//       'barcode': barcode,
//       'gst': gst,
//       'quantity': quantity,
//       'status': status,
//       'ratingCount': ratingCount,
//       'averageRating': averageRating,
//       'images': images,
//       'product_thumb': productThumb,
//       'options': options.map((e) => e.toJson()).toList(),
//     };
//   }
//
//   // Helper methods
//   bool get hasDiscount => discountPrice > 0 && discountPrice < price;
//
//   double get discountPercentage => hasDiscount
//       ? ((price - discountPrice) / price * 100)
//       : 0;
//
//   double get effectivePrice => hasDiscount ? discountPrice : price;
//
//   // Copy with method for immutability
//   Product copyWith({
//     int? id,
//     String? name,
//     String? brand,
//     String? category,
//     String? subcategory,
//     String? description,
//     double? price,
//     double? discountPrice,
//     double? totalPrice,
//     int? stock,
//     String? vendor,
//     String? vendorId,
//     String? sku,
//     String? barcode,
//     String? gst,
//     int? quantity,
//     String? status,
//     int? ratingCount,
//     double? averageRating,
//     List<String>? images,
//     String? productThumb,
//     List<ProductOption>? options,
//     bool? isFavorite,
//   }) {
//     return Product(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       brand: brand ?? this.brand,
//       category: category ?? this.category,
//       subcategory: subcategory ?? this.subcategory,
//       description: description ?? this.description,
//       price: price ?? this.price,
//       discountPrice: discountPrice ?? this.discountPrice,
//       totalPrice: totalPrice ?? this.totalPrice,
//       stock: stock ?? this.stock,
//       vendor: vendor ?? this.vendor,
//       vendorId: vendorId ?? this.vendorId,
//       sku: sku ?? this.sku,
//       barcode: barcode ?? this.barcode,
//       gst: gst ?? this.gst,
//       quantity: quantity ?? this.quantity,
//       status: status ?? this.status,
//       ratingCount: ratingCount ?? this.ratingCount,
//       averageRating: averageRating ?? this.averageRating,
//       images: images ?? this.images,
//       productThumb: productThumb ?? this.productThumb,
//       options: options ?? this.options,
//       isFavorite: isFavorite ?? this.isFavorite,
//     );
//   }
// }
//
// class ProductOption {
//   final String optionType;
//   final String displayType;
//   final List<String>? size;
//   final List<String>? color;
//   final List<String>? choices;
//
//   ProductOption({
//     required this.optionType,
//     required this.displayType,
//     this.size,
//     this.color,
//     this.choices,
//   });
//
//   factory ProductOption.fromJson(Map<String, dynamic> json) {
//     return ProductOption(
//       optionType: json['option_type'] ?? '',
//       displayType: json['display_type'] ?? '',
//       size: (json['size'] as List?)?.map((e) => e.toString()).toList(),
//       color: (json['color'] as List?)?.map((e) => e.toString()).toList(),
//       choices: (json['choices'] as List?)?.map((e) => e.toString()).toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'option_type': optionType,
//       'display_type': displayType,
//       'size': size,
//       'color': color,
//       'choices': choices,
//     };
//   }
// }








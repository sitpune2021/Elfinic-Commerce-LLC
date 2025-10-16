import 'dart:convert';

/// Main response model for Add to Cart API
class AddToCartResponse {
  final String status;
  final String message;
  final CartItem? data;

  AddToCartResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AddToCartResponse.fromJson(Map<String, dynamic> json) {
    return AddToCartResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? CartItem.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "data": data?.toJson(),
    };
  }

  static AddToCartResponse fromRawJson(String str) =>
      AddToCartResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

/// Cart item details
class CartItem {
  final int id;
  final int productId;
  final int userId;
  final int quantity;
  final CartProduct? product;

  CartItem({
    required this.id,
    required this.productId,
    required this.userId,
    required this.quantity,
    this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      product:
      json['product'] != null ? CartProduct.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "product_id": productId,
      "user_id": userId,
      "quantity": quantity,
      "product": product?.toJson(),
    };
  }
}

/// Cart product model
class CartProduct {
  final int id;
  final String name;
  final String sku;
  final String barcode;
  final List<String> images;
  final String productThumb;
  final String? productOptions;
  final String? productValues;
  final String description;
  final String price;
  final String discountPrice;
  final int stock;
  final String status;

  CartProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.images,
    required this.productThumb,
    this.productOptions,
    this.productValues,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.stock,
    required this.status,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      barcode: json['barcode'] ?? '',
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      productThumb: json['product_thumb'] ?? '',
      productOptions: json['product_options'],
      productValues: json['product_values'],
      description: json['description'] ?? '',
      price: json['price'] ?? '',
      discountPrice: json['discount_price'] ?? '',
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "sku": sku,
      "barcode": barcode,
      "images": images,
      "product_thumb": productThumb,
      "product_options": productOptions,
      "product_values": productValues,
      "description": description,
      "price": price,
      "discount_price": discountPrice,
      "stock": stock.toString(),
      "status": status,
    };
  }
}

class UserCartItem {
  final int cartId;
  final int productId;
  final int userId;
  int quantity;
  final UserCartProduct product;

  UserCartItem({
    required this.cartId,
    required this.productId,
    required this.userId,
    required this.quantity,
    required this.product,
  });

  factory UserCartItem.fromJson(Map<String, dynamic> json) {
    return UserCartItem(
      cartId: json['cart_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      product: UserCartProduct.fromJson(json['product'] ?? {}),
    );
  }
}
class UserCartProduct {
  final int id;
  final String name;
  final String sku;
  final String barcode;
  final List<String> images;
  final String thumb;
  final String description;
  final String price;
  final String discountPrice;
  final String totalPrice;
  final int stock;
  final String status;
  final String brand;
  final String category;
  final String subcategory;
  final String vendor;
  final String vendorId;
  final int ratingCount;
  final double averageRating;
  final List<CartProductOption> options;

  UserCartProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.images,
    required this.thumb,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.totalPrice,
    required this.stock,
    required this.status,
    required this.brand,
    required this.category,
    required this.subcategory,
    required this.vendor,
    required this.vendorId,
    required this.ratingCount,
    required this.averageRating,
    required this.options,
  });

  factory UserCartProduct.fromJson(Map<String, dynamic> json) {
    return UserCartProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      barcode: json['barcode'] ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      thumb: json['product_thumb'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0',
      discountPrice: json['discount_price']?.toString() ?? '0',
      totalPrice: json['total_price']?.toString() ?? '0',
      stock: json['stock'] ?? 0,
      status: json['status'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      vendor: json['vendor'] ?? '',
      vendorId: json['vendorId']?.toString() ?? '',
      ratingCount: json['ratingCount'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      options: (json['options'] as List?)
          ?.map((e) => CartProductOption.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class CartProductOption {
  final String optionType;
  final String displayType;
  final List<String>? size;
  final List<String>? choices;

  CartProductOption({
    required this.optionType,
    required this.displayType,
    this.size,
    this.choices,
  });

  factory CartProductOption.fromJson(Map<String, dynamic> json) {
    return CartProductOption(
      optionType: json['option_type'] ?? '',
      displayType: json['display_type'] ?? '',
      size: (json['size'] as List?)?.map((e) => e.toString()).toList(),
      choices: (json['choices'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}


/*class UserCartItem {
  final int cartId;
  final int productId;
  final int userId;
  int quantity;
  final UserCartProduct product;

  UserCartItem({
    required this.cartId,
    required this.productId,
    required this.userId,
    required this.quantity,
    required this.product,
  });

  factory UserCartItem.fromJson(Map<String, dynamic> json) {
    return UserCartItem(
      cartId: json['cart_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      product: UserCartProduct.fromJson(json['product'] ?? {}),
    );
  }
}

class UserCartProduct {
  final int id;
  final String name;
  final String sku;
  final String barcode;
  final List<String> images;
  final String thumb;
  final String description;
  final String price;
  final String discountPrice;
  final int stock;
  final String status;

  UserCartProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.images,
    required this.thumb,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.stock,
    required this.status,
  });

  factory UserCartProduct.fromJson(Map<String, dynamic> json) {
    return UserCartProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      barcode: json['barcode'] ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      thumb: json['product_thumb'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0',
      discountPrice: json['discount_price']?.toString() ?? '0',
      stock: json['stock'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}*/

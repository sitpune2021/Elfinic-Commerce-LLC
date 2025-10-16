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
}

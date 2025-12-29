
class CartProductVariant {
  final int id;
  final String variant;
  final String variantPrice;
  final int inventory;
  final String status;

  CartProductVariant({
    required this.id,
    required this.variant,
    required this.variantPrice,
    required this.inventory,
    required this.status,
  });

  factory CartProductVariant.fromJson(Map<String, dynamic> json) {
    return CartProductVariant(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      variant: json['variant'] ?? '',
      variantPrice: json['variant_price']?.toString() ?? '0',
      inventory: int.tryParse(json['inventory']?.toString() ?? '') ?? 0,
      status: json['status'] ?? '',
    );
  }

  bool get isInStock => inventory > 0 && status.toLowerCase() != 'out of stock';
}

class UserCartProduct {
  final int id;
  final String name;
  final String? slug;
  final String price;
  final String discountPrice;
  final String totalPrice;
  final int stock;
  final String thumb;
  final List<String> images;
  final List<CartProductVariant> variants;

  UserCartProduct({
    required this.id,
    required this.name,
    this.slug,
    required this.price,
    required this.discountPrice,
    required this.totalPrice,
    required this.stock,
    required this.thumb,
    required this.images,
    required this.variants,
  });

  factory UserCartProduct.fromJson(Map<String, dynamic> json) {
    return UserCartProduct(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'],
      price: json['price']?.toString() ?? '0',
      discountPrice: json['discount_price']?.toString() ?? '0',
      totalPrice: json['total_price']?.toString() ?? '',
      stock: int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      thumb: json['product_thumb'] ?? '',
      images: (json['images'] as List? ?? []).map((e) => e.toString()).toList(),
      variants: (json['variants'] as List? ?? [])
          .map((e) => CartProductVariant.fromJson(e))
          .toList(),
    );
  }

  bool get isInStock => stock > 0;
}

extension CartVariantSelector on UserCartProduct {
  int? get selectedVariantId {
    if (variants.isEmpty) return null;

    for (final v in variants) {
      if (v.isInStock) return v.id;
    }
    return variants.first.id;
  }
}


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
      cartId: int.tryParse(json['cart_id'].toString()) ?? 0,
      productId: int.tryParse(json['product_id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 1,
      product: UserCartProduct.fromJson(json['product']),
    );
  }
}






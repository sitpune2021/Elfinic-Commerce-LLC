
/*
class WishlistItem {
  final int id;
  final int userId;
  final int productId;
  final DateTime? createdAt;
  final WishlistProduct product;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    this.createdAt,
    required this.product,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      productId: int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      product: WishlistProduct.fromJson(json['product'] ?? {}),
    );
  }
}

class WishlistProduct {
  final int id;
  final String name;
  final String? categoryId;
  final String? subcategoryId;
  final String? vendorId;
  final String? sku;
  final String? barcode;
  final String? brand;
  final String? gst;
  final String? images;
  final String? productThumb;
  final String? description;
  final String? showSection;
  final String price;
  final String? discountPrice;
  final String? discountType;
  final String? gstRate;
  final String? gstType;
  final String? totalPrice;
  final String? hsnCode;
  final String? stock;
  final int? quantity;
  final String? status;

  WishlistProduct({
    required this.id,
    required this.name,
    this.categoryId,
    this.subcategoryId,
    this.vendorId,
    this.sku,
    this.barcode,
    this.brand,
    this.gst,
    this.images,
    this.productThumb,
    this.description,
    this.showSection,
    required this.price,
    this.discountPrice,
    this.discountType,
    this.gstRate,
    this.gstType,
    this.totalPrice,
    this.hsnCode,
    this.stock,
    this.quantity,
    this.status,
  });

  factory WishlistProduct.fromJson(Map<String, dynamic> json) {
    return WishlistProduct(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? 'Unknown Product',
      categoryId: json['category_id']?.toString(),
      subcategoryId: json['subcategory_id']?.toString(),
      vendorId: json['vendor_id']?.toString(),
      sku: json['sku']?.toString(),
      barcode: json['barcode']?.toString(),
      brand: json['brand']?.toString(),
      gst: json['gst']?.toString(),
      images: json['images']?.toString(),
      productThumb: json['product_thumb']?.toString(),
      description: json['description']?.toString(),
      showSection: json['show_section']?.toString(),
      price: json['price']?.toString() ?? '0',
      discountPrice: json['discount_price']?.toString(),
      discountType: json['discount_type']?.toString(),
      gstRate: json['gst_rate']?.toString(),
      gstType: json['gst_type']?.toString(),
      totalPrice: json['total_price']?.toString(),
      hsnCode: json['hsn_code']?.toString(),
      stock: json['stock']?.toString(),
      quantity: json['quantity'] != null
          ? int.tryParse(json['quantity'].toString())
          : 0,
      status: json['status']?.toString(),
    );
  }
}*/

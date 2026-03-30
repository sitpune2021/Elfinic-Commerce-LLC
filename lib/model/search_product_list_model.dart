import 'dart:convert';

SearchProductFilterListModel searchProductFilterListModelFromJson(String str) =>
    SearchProductFilterListModel.fromJson(json.decode(str));

String searchProductFilterListModelToJson(SearchProductFilterListModel data) =>
    json.encode(data.toJson());

class SearchProductFilterListModel {
  final String status;
  final String message;
  final Pagination pagination;
  final List<Product> data;

  SearchProductFilterListModel({
    required this.status,
    required this.message,
    required this.pagination,
    required this.data,
  });

  factory SearchProductFilterListModel.fromJson(Map<String, dynamic> json) {
    return SearchProductFilterListModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      pagination: Pagination.fromJson(json['pagination']),
      data: (json['data'] as List)
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'pagination': pagination.toJson(),
        'data': data.map((e) => e.toJson()).toList(),
      };
}

class Product {
  final int id;
  final String name;
  final String slug;
  final String? brand;
  final String category;
  final List<String> subcategory;
  final String price;
  final String discountPrice;
  final String totalPrice;
  final String stock;
  final String? vendor;
  final String vendorId;
  final int? userId;
  final String sku;
  final String? barcode;
  final String? gst;
  final int quantity;
  final String status;
  final String showSection;
  final int ratingCount;
  final int averageRating;
  final List<String> images;
  final String productThumb;
  final String imagePath;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.brand,
    required this.category,
    required this.subcategory,
    required this.price,
    required this.discountPrice,
    required this.totalPrice,
    required this.stock,
    this.vendor,
    required this.vendorId,
    this.userId,
    required this.sku,
    this.barcode,
    this.gst,
    required this.quantity,
    required this.status,
    required this.showSection,
    required this.ratingCount,
    required this.averageRating,
    required this.images,
    required this.productThumb,
    required this.imagePath,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      brand: json['brand'],
      category: json['category'] ?? '',
      subcategory:
      (json['subcategory'] as List?)?.map((e) => e.toString()).toList() ?? [],
      price: json['price']?.toString() ?? '0',
      discountPrice: json['discount_price']?.toString() ?? '0',
      totalPrice: json['total_price']?.toString() ?? '0',
      stock: json['stock']?.toString() ?? '0',
      vendor: json['vendor'],
      vendorId: json['vendorId']?.toString() ?? '',
      userId: json['user_id'],
      sku: json['sku'] ?? '',
      barcode: json['barcode'],
      gst: json['gst'],
      quantity: json['quantity'] ?? 0,
      status: json['status'] ?? '',
      showSection: json['show_section'] ?? '',
      ratingCount: json['ratingCount'] ?? 0,
      averageRating: json['averageRating'] ?? 0,
      images:
      (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      productThumb: json['product_thumb']?.toString() ?? '',
      imagePath: json['image_path']?.toString() ?? '',
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
        'vendor': vendor,
        'vendorId': vendorId,
        'user_id': userId,
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
        'image_path': imagePath,
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
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'last_page': lastPage,
        'per_page': perPage,
        'total': total,
      };
}

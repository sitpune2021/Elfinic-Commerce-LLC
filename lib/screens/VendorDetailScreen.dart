import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;



import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'ProductDetailPage.dart';

import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'ProductDetailPage.dart';

class VendorDetailScreen extends StatefulWidget {
  final int vendorId;

  const VendorDetailScreen({super.key, required this.vendorId});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  /// ---------------- PRICE LOGIC ----------------
  double _calculateFinalPrice(ProductModel p) {
    final price = double.tryParse(p.price) ?? 0;
    final discount = double.tryParse(p.discountPrice) ?? 0;
    return price - discount;
  }

  bool _shouldShowDiscount(ProductModel p) {
    final price = double.tryParse(p.price) ?? 0;
    final discount = double.tryParse(p.discountPrice) ?? 0;
    return price > 0 && discount > 0 && discount < price;
  }

  String _calculateDiscountPercentage(ProductModel p) {
    final price = double.tryParse(p.price) ?? 0;
    final discount = double.tryParse(p.discountPrice) ?? 0;
    if (price > 0 && discount > 0 && discount < price) {
      final percentage = ((discount / price) * 100).round();
      return "$percentage% OFF";
    }
    return "";
  }

  @override
  void initState() {
    super.initState();

    final provider = context.read<VendorDetailProvider>();

    Future.microtask(() {
      provider.fetchVendorDetail(widget.vendorId);
      provider.fetchCategories(widget.vendorId);
    });

    /// PAGINATION
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 120) {
        provider.fetchProducts(
          vendorId: widget.vendorId,
          categoryId: provider.selectedCategoryId ?? 0,
          loadMore: true,
        );
      }
    });
  }

  /// ---------------- PRODUCT CARD (SAME AS HomeScreen) ----------------
  Widget _buildProductCard(ProductModel product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.44;

    String? imageUrl = product.image.isNotEmpty ? product.image : null;

    return GestureDetector(
      onTap: () => _onProductTap(product),
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1 / 1.25,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      child: imageUrl != null
                          ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => _buildProductImageShimmer(),
                        errorWidget: (_, __, ___) => _buildErrorImage(),
                      )
                          : _buildErrorImage(),
                    ),
                  ),
                  if (_shouldShowDiscount(product))
                    Positioned(
                      top: 5,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _calculateDiscountPercentage(product),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (_shouldShowDiscount(product)) ...[
                          Text(
                            "₹${product.price}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          "₹${_calculateFinalPrice(product).toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          product.averageRating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "(${product.ratingCount})",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImageShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 130,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Image.asset(
      "assets/images/no_product_img2.png",
      height: 130,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(title: const Text("Elfinic Store")),
      body: Consumer<VendorDetailProvider>(
        builder: (context, provider, _) {
          final vendor = provider.vendor;

          if (provider.isLoading && provider.vendor == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              /// ---------------- VENDOR SECTION ----------------
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Colors.indigo, Colors.blue]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text(vendor?.fullName[0] ?? "U"),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vendor?.fullName ?? "",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Text(vendor?.email ?? "",
                              style: const TextStyle(
                                  color: Colors.white70)),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              /// ---------------- CATEGORY SECTION ----------------
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: provider.categories.length,
                    itemBuilder: (context, index) {
                      final cat = provider.categories[index];
                      final isSelected =
                          provider.selectedCategoryId == cat.id;

                      return GestureDetector(
                        onTap: () {
                          provider.fetchProducts(
                            vendorId: widget.vendorId,
                            categoryId: cat.id,
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.indigo
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected ? Colors.indigo : Colors.grey.shade300),
                          ),
                          child: Center(
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              /// ---------------- LOADING STATE ----------------
              if (provider.isProductLoading && provider.products.isEmpty)
                SliverToBoxAdapter(
                  child: _buildProductGridShimmer(),
                ),

              /// ---------------- PRODUCTS GRID ----------------
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55, // Matches HomeScreen card ratio
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index >= provider.products.length) {
                        return const SizedBox.shrink();
                      }
                      return _buildProductCard(provider.products[index]);
                    },
                    childCount: provider.products.length,
                  ),
                ),
              ),

              /// ---------------- LOAD MORE INDICATOR ----------------
              if (provider.isLoadMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductGridShimmer() {
    return SizedBox(
      height: 340,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.44,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 80,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onProductTap(ProductModel product) {
    if (product.slug == null || product.slug!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product details not available")),
      );
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailScreen(
              slug: product.slug!,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class VendorDetailProvider with ChangeNotifier {
  VendorDetail? vendor;

  List<CategoryModel> categories = [];
  List<ProductModel> products = [];

  bool isLoading = false;
  bool isCategoryLoading = false;
  bool isProductLoading = false;
  bool isLoadMore = false;

  int? selectedCategoryId;
  int currentPage = 1;
  int lastPage = 1;

  /// ---------------- Vendor ----------------
  Future<void> fetchVendorDetail(int vendorId) async {
    isLoading = true;
    notifyListeners();

    final res = await http.get(
      Uri.parse(
          "https://admin.elfinic.com/api/getVendorDetails?vendor_id=$vendorId"),
    );

    if (res.statusCode == 200) {
      vendor = VendorDetail.fromJson(json.decode(res.body));
    }

    isLoading = false;
    notifyListeners();
  }

  /// ---------------- Categories ----------------
  Future<void> fetchCategories(int vendorId) async {
    isCategoryLoading = true;
    notifyListeners();

    final url =
        "https://admin.elfinic.com/api/categories-by-vendor?vendor_id=$vendorId";

    print("📡 CATEGORY API URL: $url");

    try {
      final res = await http.get(Uri.parse(url));

      print("📥 CATEGORY RESPONSE BODY: ${res.body}");

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        categories = (data['data'] as List)
            .map((e) => CategoryModel.fromJson(e))
            .toList();

        /// 🔥 AUTO SELECT FIRST CATEGORY
        if (categories.isNotEmpty) {
          selectedCategoryId = categories.first.id;

          /// 🔥 LOAD FIRST CATEGORY PRODUCTS
          await fetchProducts(
            vendorId: vendorId,
            categoryId: selectedCategoryId!,
          );
        }
      }
    } catch (e) {
      print("❌ CATEGORY ERROR: $e");
    }

    isCategoryLoading = false;
    notifyListeners();
  }

  /// ---------------- Products ----------------
  Future<void> fetchProducts({
    required int vendorId,
    required int categoryId,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (currentPage >= lastPage) return;
      currentPage++;
      isLoadMore = true;
    } else {
      currentPage = 1;
      products.clear();
      isProductLoading = true;
    }

    selectedCategoryId = categoryId;
    notifyListeners();

    final url =
        "https://admin.elfinic.com/api/products-by-vendor-category"
        "?vendor_id=$vendorId"
        "&category_id=$categoryId"
        "&per_page=10"
        "&page=$currentPage";

    print("📡 PRODUCT API: $url");

    try {
      final res = await http.get(Uri.parse(url));

      print("📥 PRODUCT RESPONSE: ${res.body}");

      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        List list = data['data'];
        final pagination = data['pagination'];

        currentPage = pagination['current_page']; // ✅ FIX
        lastPage = pagination['last_page'];

        products.addAll(
          list.map((e) => ProductModel.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      print("❌ PRODUCT ERROR: $e");
    }

    isProductLoading = false;
    isLoadMore = false;
    notifyListeners();
  }



}


class VendorDetail {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String? address;
  final String? zipCode;
  final double rating;
  final String ratingCount;

  VendorDetail({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.address,
    this.zipCode,
    required this.rating,
    required this.ratingCount,
  });

  factory VendorDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data']['vendorInfo'];

    return VendorDetail(
      id: data['id'],
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'],
      zipCode: data['zipCode'],
      rating: (data['rating'] ?? 0).toDouble(),
      ratingCount: data['rating_count'] ?? '0',
    );
  }
}


class CategoryModel {
  final int id;
  final String name;

  CategoryModel({
    required this.id,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['category_id'],
      name: json['category_name'] ?? '',
    );
  }
}

class ProductModel {
  final int id;
  final String name;
  final String price;
  final String discountPrice;
  final double averageRating;
  final int ratingCount;
  final String image;
  final String? slug; // ✅ ADD

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.discountPrice,
    required this.averageRating,
    required this.ratingCount,
    required this.image,
    this.slug,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String img = '';

    if (json['product_thumb'] != null &&
        json['product_thumb'].toString().isNotEmpty) {
      img = json['image_path'] + json['product_thumb'];
    }
    return ProductModel(
      id: json['id'],
      name: json['name'] ?? '',
      price: json['price'].toString(),
      discountPrice: json['discount_price'].toString(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      image: img,
      slug: json['slug'], // ✅ IMPORTANT
    );
  }
}



import 'package:elfinic_commerce_llc/screens/ProductDetailPage.dart';
import 'package:flutter/material.dart';

import '../model/ProductsResponse.dart';
import '../providers/WishlistProvider.dart';
import '../services/api_service.dart';
import 'DashboardScreen.dart';

import 'home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:provider/provider.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../model/ProductsResponse.dart';
import '../providers/WishlistProvider.dart';

import '../model/WishlistProductItem.dart'; // your WishlistItem model
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Product> _wishlistProducts = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final token = prefs.getString('auth_token');

      if (userId == null || token == null) {
        setState(() => _errorMessage = 'User not logged in');
        return;
      }

      final url = Uri.parse('${ApiService.baseUrl}/api/getWishlist?user_id=$userId');
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final List<dynamic> products = data['data'];
          setState(() {
            _wishlistProducts = products.isNotEmpty
                ? List<Product>.from(
              products.map((product) => Product.fromJson(product)),
            )
                : [];
            _errorMessage = products.isEmpty ? 'Your wishlist is empty!' : '';
          });
        } else {
          setState(() =>
          _errorMessage = data['message'] ?? 'Failed to load wishlist');
        }
      } else {
        setState(() => _errorMessage = 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error loading wishlist: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleWishlist(int productId) async {
    final provider = Provider.of<WishlistProvider>(context, listen: false);
    final success = await provider.toggleWishlist(productId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.isInWishlist(productId)
              ? "Added to wishlist ❤️"
              : "Removed from wishlist 💔"),
          backgroundColor: provider.isInWishlist(productId)
              ? Colors.green
              : Colors.redAccent,
        ),
      );
      _loadWishlist();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update wishlist"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Wishlist'),
            backgroundColor: const Color(0xffc98a35),
            foregroundColor: Colors.white,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    '${wishlistProvider.wishlistCount}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFF8F9FA),
          body: _isLoading
              ? const Center(
              child: CircularProgressIndicator(color: Color(0xffc98a35)))
              : _wishlistProducts.isEmpty
              ? _buildEmptyWishlist()
              : LayoutBuilder(
            builder: (context, constraints) {
              // Responsive grid settings
              int crossAxisCount = 2;
              double childAspectRatio = 0.7;

              if (constraints.maxWidth > 1200) {
                crossAxisCount = 5;
                childAspectRatio = 0.8;
              } else if (constraints.maxWidth > 900) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 3;
              }

              return RefreshIndicator(
                onRefresh: _loadWishlist,
                color: const Color(0xffc98a35),
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: _wishlistProducts.length,
                  itemBuilder: (context, index) {
                    final product = _wishlistProducts[index];
                    if (!wishlistProvider.isInWishlist(product.id)) {
                      return const SizedBox.shrink();
                    }
                    return _buildWishlistCard(product);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Your wishlist is empty ❤️',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add products you love and they\'ll appear here!',
              style: TextStyle(fontSize: 14, color: Colors.black45),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffc98a35),
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Shopping',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Important: Use min to avoid expanding
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: _buildProductImage(product),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Consumer<WishlistProvider>(
                    builder: (context, provider, child) {
                      return GestureDetector(
                        onTap: () => _toggleWishlist(product.id),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: Offset(0, 2)),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.favorite,
                            color: provider.isInWishlist(product.id)
                                ? Colors.red
                                : Colors.grey,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Discount Badge
                if (product.hasDiscount)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${product.discountPercentage.round()}% OFF",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Use Expanded to constrain the text content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space evenly
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Price Section
                    Row(
                      children: [
                        if (product.hasDiscount) ...[
                          Text(
                            "₹${product.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          "₹${product.effectivePrice.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xffc98a35),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Rating and Stock Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.orangeAccent),
                            const SizedBox(width: 2),
                            Text(
                              product.averageRating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "(${product.ratingCount})",
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 4),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        //   decoration: BoxDecoration(
                        //     color: product.stock > 0 ? Colors.green[100] : Colors.red[100],
                        //     borderRadius: BorderRadius.circular(4),
                        //   ),
                        //   child: Text(
                        //     product.stock > 0 ? "In Stock" : "Out of Stock",
                        //     style: TextStyle(
                        //       fontSize: 10,
                        //       color: product.stock > 0 ? Colors.green : Colors.red,
                        //       fontWeight: FontWeight.w500,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildProductImage(Product product) {
    final baseUrl = ApiService.baseUrl;
    String? imageFile;

    if (product.images.isNotEmpty) {
      imageFile = product.images.first;
    } else if (product.productThumb != null && product.productThumb!.isNotEmpty) {
      imageFile = product.productThumb;
    }

    if (imageFile == null || imageFile.isEmpty) {
      return Image.asset(
        "assets/images/no_product_img2.png",
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    final imageUrl = "$baseUrl/assets/img/products-images/$imageFile";

    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      errorWidget: (context, url, error) => Image.asset(
        "assets/images/no_product_img2.png",
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
/*class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<WishlistItem> _wishlistItems = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final token = prefs.getString('auth_token');

      if (userId == null || token == null) {
        setState(() => _errorMessage = 'User not logged in');
        return;
      }

      // final url = Uri.parse('https://admin.elfinic.com/api/getWishlist?user_id=$userId');
      final url =
          Uri.parse('${ApiService.baseUrl}/api/getWishlist?user_id=$userId');
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['data'] != null) {
          final List<dynamic> items = data['data'];
          setState(() {
            _wishlistItems = items.isNotEmpty
                ? List<WishlistItem>.from(
                    items.map((item) => WishlistItem.fromJson(item)),
                  )
                : [];
            _errorMessage = items.isEmpty ? 'Your wishlist is empty!' : '';
          });
        } else {
          setState(() =>
              _errorMessage = data['message'] ?? 'Failed to load wishlist');
        }
      } else {
        setState(() => _errorMessage = 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error loading wishlist: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleWishlist(int productId) async {
    final provider = Provider.of<WishlistProvider>(context, listen: false);
    final success = await provider.toggleWishlist(productId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.isInWishlist(productId)
              ? "Added to wishlist ❤️"
              : "Removed from wishlist 💔"),
          backgroundColor: provider.isInWishlist(productId)
              ? Colors.green
              : Colors.redAccent,
        ),
      );
      _loadWishlist();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update wishlist"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Product _convertToProduct(WishlistProduct wishlistProduct) {
    return Product(
      id: wishlistProduct.id,
      name: wishlistProduct.name,
      brand: wishlistProduct.brand,
      category: wishlistProduct.categoryId, // Map categoryId to category
      subcategory: wishlistProduct.subcategoryId, // Map subcategoryId to subcategory
      description: wishlistProduct.description,
      price: double.tryParse(
        (wishlistProduct.price ?? '0').replaceAll(',', '').trim(),
      ) ?? 0.0,
      discountPrice: double.tryParse(
        (wishlistProduct.discountPrice ?? '0').replaceAll(',', '').trim(),
      ) ?? 0.0,
      totalPrice: double.tryParse(
        (wishlistProduct.totalPrice ?? '0').replaceAll(',', '').trim(),
      ) ?? 0.0,
      stock: int.tryParse(wishlistProduct.stock ?? '0') ?? 0,
      // vendor: wishlistProduct.vendor,
      vendorId: wishlistProduct.vendorId,
      sku: wishlistProduct.sku ?? '',
      barcode: wishlistProduct.barcode,
      gst: wishlistProduct.gst,
      quantity: wishlistProduct.quantity ?? 0,
      status: wishlistProduct.status ?? '',
      ratingCount: 0, // Wishlist doesn't include this field
      averageRating: 0.0, // Wishlist doesn't include this field
      images: (wishlistProduct.images?.isNotEmpty ?? false)
          ? wishlistProduct.images!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList()
          : [],
      productThumb: wishlistProduct.productThumb,
      options: const [], // Wishlist doesn't include options
      isFavorite: true,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistProvider>(
      builder: (context, wishlistProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Wishlist'),
            backgroundColor: const Color(0xffc98a35),
            foregroundColor: Colors.white,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    '${wishlistProvider.wishlistCount}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFF8F9FA),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xffc98a35)))
              : _wishlistItems.isEmpty
                  ? _buildEmptyWishlist()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive grid settings
                        int crossAxisCount = 2;
                        double childAspectRatio = 0.7;

                        if (constraints.maxWidth > 1200) {
                          crossAxisCount = 5;
                          childAspectRatio = 0.8;
                        } else if (constraints.maxWidth > 900) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth > 600) {
                          crossAxisCount = 3;
                        }

                        return RefreshIndicator(
                          onRefresh: _loadWishlist,
                          color: const Color(0xffc98a35),
                          child: GridView.builder(
                            padding: const EdgeInsets.all(10),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: childAspectRatio,
                            ),
                            itemCount: _wishlistItems.length,
                            itemBuilder: (context, index) {
                              final item = _wishlistItems[index];
                              if (!wishlistProvider
                                  .isInWishlist(item.productId)) {
                                return const SizedBox.shrink();
                              }
                              return _buildWishlistCard(item);
                            },
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Your wishlist is empty ❤️',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add products you love and they’ll appear here!',
              style: TextStyle(fontSize: 14, color: Colors.black45),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffc98a35),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Shopping',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistCard(WishlistItem wishlistItem) {
    final product = wishlistItem.product;

    return GestureDetector(
      onTap: () {
        final productForDetail = _convertToProduct(product);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProductDetailScreen(product: productForDetail)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: _buildProductImage(product),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Consumer<WishlistProvider>(
                    builder: (context, provider, child) {
                      return GestureDetector(
                        onTap: () => _toggleWishlist(wishlistItem.productId),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: Offset(0, 2)),
                            ],
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.favorite,
                            color: provider.isInWishlist(wishlistItem.productId)
                                ? Colors.red
                                : Colors.grey,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, height: 1.2),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_shouldShowDiscount(product)) ...[
                        Text(
                          "₹${double.tryParse(product.price)?.toStringAsFixed(2) ?? '0.00'}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        "₹${_calculateFinalPrice(product).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xffc98a35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.orangeAccent),
                      SizedBox(width: 2),
                      Text("4.8", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateFinalPrice(WishlistProduct product) {
    final price = double.tryParse(product.price) ?? 0;
    final discount = double.tryParse(product.discountPrice ?? '0') ?? 0;
    if (price > 0 && discount > 0 && discount < price) {
      return price - discount;
    }
    return price;
  }

  bool _shouldShowDiscount(WishlistProduct product) {
    final price = double.tryParse(product.price) ?? 0;
    final discount = double.tryParse(product.discountPrice ?? '0') ?? 0;
    return price > 0 && discount > 0 && discount < price;
  }

  Widget _buildProductImage(WishlistProduct product) {
    // const baseUrl = "https://admin.elfinic.com";
    final baseUrl = ApiService.baseUrl;
    String? imageFile;

    if (product.images != null && product.images!.isNotEmpty) {
      imageFile = product.images!.split(',').first.trim();
    } else if (product.productThumb != null &&
        product.productThumb!.isNotEmpty) {
      imageFile = product.productThumb;
    }

    if (imageFile == null || imageFile.isEmpty) {
      return Image.asset(
        "assets/images/no_product_img2.png",
        height: 130,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    final imageUrl = "$baseUrl/assets/img/products-images/$imageFile";

    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      errorWidget: (context, url, error) => Image.asset(
        "assets/images/no_product_img2.png",
        height: 130,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

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

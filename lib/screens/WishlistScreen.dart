import 'package:elfinic_commerce_llc/screens/ProductDetailPage.dart';
import 'package:flutter/foundation.dart';
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

      final url = Uri.parse(
          '${ApiService.baseUrl}/api/getProductByType?user_id=$userId&type=Wishlist');

      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json"
      });

      if (kDebugMode) {
        print("===== WISHLIST API RESPONSE =====");
        print("Status: ${response.statusCode}");
        print("Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['status'] == true) {
          final List<dynamic> list = jsonData['data'] ?? [];

          setState(() {
            _wishlistProducts = list
                .map((p) => Product.fromJson(p))
                .toList();

            if (_wishlistProducts.isEmpty) {
              _errorMessage = "Your wishlist is empty!";
            }
          });
        } else {
          setState(() => _errorMessage = jsonData["message"] ?? "Failed to load wishlist");
        }
      } else {
        setState(() => _errorMessage = "Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _errorMessage = "Error loading wishlist: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /*Future<void> _loadWishlist() async {
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
  }*/

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
  double _calculateDiscountedPrice(double originalPrice, double discountAmount) {
    // discountAmount is the flat discount (e.g., ₹10 off)
    if (discountAmount <= 0) return originalPrice;
    return originalPrice - discountAmount;
  }

  double _getDiscountAmount(Product product) {
    // Return the actual discount amount (₹10 in your example)
    // This depends on how your Product model stores discount information
    return product.discountPrice ?? 0.0;
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
                    // Price Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Final price after discount


                        // const SizedBox(height: 4),

                        // Original price and discount
                        Row(
                          children: [
                            Text(
                              "₹${_calculateDiscountedPrice(product.price, _getDiscountAmount(product)).toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffc98a35),
                              ),
                            ),
                            SizedBox(width: 5,),
                            // Original price (crossed out)
                            Text(
                              "₹${product.price.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),

                            // const SizedBox(width: 6),

                            // Discount amount
                            // Container(
                            //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            //   decoration: BoxDecoration(
                            //     color: Colors.red[50],
                            //     borderRadius: BorderRadius.circular(4),
                            //   ),
                            //   child: Text(
                            //     "₹${_getDiscountAmount(product).toStringAsFixed(0)} off",
                            //     style: TextStyle(
                            //       fontSize: 11,
                            //       color: Colors.red[700],
                            //       fontWeight: FontWeight.w500,
                            //     ),
                            //   ),
                            // ),
                          ],
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



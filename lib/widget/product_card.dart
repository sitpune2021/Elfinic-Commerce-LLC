import 'dart:async';
import 'package:elfinic_commerce_llc/model/search_product_list_model.dart';
import 'package:elfinic_commerce_llc/providers/WishlistProvider.dart';
import 'package:elfinic_commerce_llc/screens/ProductDetailPage.dart';
import 'package:elfinic_commerce_llc/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/image_zoom_screen.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final PageController _pageController;
  Timer? _timer;

  late final AnimationController _heartController;
  late final Animation<double> _scaleAnim;

  List<String> get _images {
    final p = widget.product;
    return p.images.isNotEmpty ? p.images : [p.productThumb];
  }

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _scaleAnim = Tween<double>(begin: 1, end: 1.3)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_heartController);

    // 🔄 Auto carousel
    if (_images.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!_pageController.hasClients) return;
        _currentIndex = (_currentIndex + 1) % _images.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return InkWell(
      // borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProductDetailScreen(
              //  product: widget.product, // ✅ FIXED
              slug: widget.product.slug, // keep as-is
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 🔑 no extra space
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 IMAGE + HEART
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _images.length,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemBuilder: (_, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ImageZoomScreen(
                                  images: _images,
                                  initialIndex: index,
                                  imagePath: product.imagePath,
                                ),
                              ),
                            );
                          },
                          child: Image.network(
                            product.imagePath + _images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imageError(),
                          ),
                        );
                      },
                    ),
                  ),

                  // ❤️ WISHLIST (PROVIDER ONLY)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlistProvider, _) {
                        final isWishlisted =
                            wishlistProvider.isInWishlist(product.id);

                        return ScaleTransition(
                          scale: _scaleAnim,
                          child: GestureDetector(
                            onTap: () async {
                              _heartController
                                  .forward()
                                  .then((_) => _heartController.reverse());

                              final prefs =
                                  await SharedPreferences.getInstance();
                              final userIdString = prefs.getString('user_id');
                              final userId =
                                  int.tryParse(userIdString ?? '0') ?? 0;

                              if (!context.mounted) return;

                              if (userId == 0) {
                                _showLoginRequiredDialog(context);
                                return;
                              }

                              final success = await wishlistProvider
                                  .toggleWishlist(product.id);

                              if (!context.mounted) return;

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isWishlisted
                                          ? 'Removed from wishlist ❤️‍🔥'
                                          : 'Added to wishlist ❤️',
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Failed to update wishlist ❌'),
                                  ),
                                );
                              }
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 16,
                              child: Icon(
                                isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isWishlisted ? Colors.red : Colors.grey,
                                size: 18,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 🔵 DOT INDICATOR
                  if (_images.length > 1)
                    Positioned(
                      bottom: 6,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _images.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 6,
                            width: _currentIndex == i ? 14 : 6,
                            decoration: BoxDecoration(
                              color: _currentIndex == i
                                  ? Colors.orange
                                  : Colors.white70,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 📄 DETAILS (NO EXTRA SPACE)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        "${product.averageRating} (${product.ratingCount})",
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (product.price != product.totalPrice)
                        Text(
                          "₹${product.price}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        "₹${product.totalPrice}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _imageError() {
    return Image.asset(
      'assets/images/no_image.png',
      fit: BoxFit.cover,
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Login Required"),
        content: const Text("Please login to add items to your wishlist."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_add_to_cart_button/flutter_add_to_cart_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../model/ProductsResponse.dart';
import '../model/Review.dart';
import '../providers/CartProvider.dart';
import '../providers/RecentViewProvider.dart';
import '../providers/ReviewProvider.dart';
import '../providers/WishlistProvider.dart';
import '../providers/product_provider.dart';
import '../services/api_service.dart';
import '../utils/BaseScreen.dart';

import 'CartScreen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool showProductDetails = true;
  bool showSizeChart = true;
  final PageController _pageController = PageController();
  int activeIndex = 0;

  // State variables
  String? selectedSize;
  String? selectedColor;
  bool isAddedToCart = false;
  int quantity = 0;
  bool isWishlisted = false;

  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 0;

  AddToCartButtonStateId _addToCartState = AddToCartButtonStateId.idle;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Wishlist + Cart + Reviews
      final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
      wishlistProvider.fetchWishlist();
      _refreshCartFromProvider();
      _refreshWishlistFromProvider();

      // Recent views
      final recentViewProvider = Provider.of<RecentViewProvider>(context, listen: false);
      recentViewProvider.getRecentViews();
      _addToRecentViews(widget.product.id);

      // ⭐ AUTO SELECT DEFAULT SIZE & COLOR
      if (_availableSizes.isNotEmpty) {
        setState(() => selectedSize = _availableSizes.first);
      }

      if (_availableColors.isNotEmpty) {
        setState(() => selectedColor = _availableColors.first);
      }
    });
  }


  /*@override
  void initState() {
    super.initState();
    // Fetch initial cart items when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
      wishlistProvider.fetchWishlist();
      _refreshCartFromProvider();
      _refreshWishlistFromProvider();

      // Fetch product reviews when screen loads
      final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
      reviewProvider.fetchProductReviews(widget.product.id);

      // Fetch recent views when screen loads
      final recentViewProvider = Provider.of<RecentViewProvider>(context, listen: false);
      recentViewProvider.getRecentViews();

      // Add current product to recent views when screen loads
      _addToRecentViews(widget.product.id);
    });
  }*/

  void _refreshCartFromProvider() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.fetchCartItems();
  }

  void _refreshWishlistFromProvider() {
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
    wishlistProvider.fetchWishlist();
  }

  String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = document.body?.text ?? '';
    return parsedString;
  }

  String _calculateDiscountPercentage() {
    final product = widget.product;

    if (product.discountPrice > 0 && product.price > 0) {
      final double calculatedPercentage = (product.discountPrice / product.price) * 100;
      final int roundedPercentage = calculatedPercentage.round();
      return "$roundedPercentage% Off";
    }

    return "";
  }

  double _calculateFinalPrice() {
    final product = widget.product;
    return product.totalPrice > 0 ? product.totalPrice : product.price;
  }

  double _calculateDiscountAmount() {
    final product = widget.product;
    return product.discountPrice;
  }

  bool _shouldShowDiscountBadge() {
    return widget.product.discountPrice > 0;
  }

  // Helper method to get all available colors from product options
  List<String> get _availableColors {
    final List<String> colors = [];

    // Check product options for colors
    for (final option in widget.product.options) {
      // Check if option type is "Color" or name contains color
      if (option.optionType.toLowerCase().contains('color') ||
          _isValidColorName(option.name)) {
        colors.add(option.name);
      }
    }

    // Also check variants for color information
    for (final variant in widget.product.variants) {
      final variantParts = variant.variant.toLowerCase().split('/');
      for (final part in variantParts) {
        final trimmedPart = part.trim();
        if (_isValidColorName(trimmedPart)) {
          colors.add(trimmedPart);
        }
      }
    }

    return colors.toSet().toList(); // Remove duplicates
  }

  // Helper method to check if a string is a valid color name
  bool _isValidColorName(String colorName) {
    final validColors = [
      'red', 'blue', 'green', 'yellow', 'orange', 'purple', 'pink',
      'brown', 'black', 'white', 'grey', 'gray', 'teal', 'cyan',
      'indigo', 'amber', 'lime', 'maroon', 'navy', 'olive', 'silver',
      'gold', 'beige', 'turquoise', 'lavender', 'coral', 'salmon',
      'magenta', 'violet'
    ];

    return validColors.contains(colorName.toLowerCase());
  }

  // Helper method to get all available sizes from product options
  List<String> get _availableSizes {
    final List<String> sizes = [];

    // Check product options for sizes
    for (final option in widget.product.options) {
      if (option.optionType.toLowerCase().contains('size')) {
        sizes.add(option.name);
      }
    }

    // Also check variants for size information
    for (final variant in widget.product.variants) {
      final variantParts = variant.variant.toLowerCase().split('/');
      for (final part in variantParts) {
        final trimmedPart = part.trim();
        if (_isValidSize(trimmedPart)) {
          sizes.add(trimmedPart);
        }
      }
    }

    return sizes.toSet().toList(); // Remove duplicates
  }

  bool _isValidSize(String size) {
    final validSizes = [
      'xs', 's', 'small', 'm', 'medium', 'l', 'large', 'xl', 'xxl', 'xxxl',
      '36', '38', '40', '42', '44', '46', '48'
    ];
    return validSizes.contains(size.toLowerCase());
  }

  // Helper method to get all available choices from product options
  List<String> get _availableChoices {
    final List<String> choices = [];
    for (final option in widget.product.options) {
      choices.add(option.name);
    }
    return choices.toSet().toList(); // Remove duplicates
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final int stock = product.stock;

    return BaseScreen(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: const Color(0xfffdf6ef),
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Consumer<CartProvider>(
              builder: (context, cartProvider, _) {
                final uniqueItemCount = cartProvider.cartItems.length;

                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CartScreen()),
                        );
                        final cartProvider =
                        Provider.of<CartProvider>(context, listen: false);
                        cartProvider.fetchCartItems();
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/shopping-cart.svg',
                        width: 26,
                        height: 26,
                        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                      ),
                    ),
                    if (uniqueItemCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$uniqueItemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with badge + fav + share
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      // Product Images PageView
                      SizedBox(
                        height: 350,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: product.images.isNotEmpty
                              ? product.images.length
                              : 1,
                          onPageChanged: (index) =>
                              setState(() => activeIndex = index),
                          itemBuilder: (context, index) {
                            if (product.images.isEmpty) {
                              return Image.asset(
                                "assets/images/no_product_img2.png",
                                fit: BoxFit.cover,
                              );
                            }

                            return CachedNetworkImage(
                              imageUrl:
                              "${ApiService.baseUrl}/assets/img/products-images/${product.images[index]}",
                              height: 350,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Image.asset(
                                "assets/images/no_product_img2.png",
                                fit: BoxFit.cover,
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                "assets/images/no_product_img2.png",
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),

                      // Discount Badge - Only show if there's an actual discount
                      if (_shouldShowDiscountBadge())
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _calculateDiscountPercentage(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Page Indicator
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 90),

                  // Center indicator
                  Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count:
                      product.images.isNotEmpty ? product.images.length : 1,
                      effect: const ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: Colors.orange,
                        dotColor: Colors.grey,
                      ),
                    ),
                  ),

                  // Right side icons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.black),
                        onPressed: () {},
                      ),
                      // Wishlist button using Consumer
                      Consumer<WishlistProvider>(
                        builder: (context, wishlistProvider, _) {
                          final isWishlisted =
                          wishlistProvider.isInWishlist(product.id);

                          return IconButton(
                            icon: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isWishlisted ? Colors.red : Colors.black,
                            ),
                            onPressed: () async {
                              final prefs =
                              await SharedPreferences.getInstance();
                              final userIdString =
                              prefs.getString('user_id');
                              final userId =
                                  int.tryParse(userIdString ?? '0') ?? 0;

                              if (userId == 0) {
                                _showLoginRequiredDialog(context);
                                return;
                              }

                              final success = await wishlistProvider
                                  .toggleWishlist(product.id);

                              if (success) {
                                final message = isWishlisted
                                    ? 'Removed from wishlist ❤️‍🔥'
                                    : 'Added to wishlist ❤️';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Failed to update wishlist ❌')),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // Title + Rating + Stock
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text(
                            "${product.averageRating} (${product.ratingCount} Ratings)"),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: stock > 0
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stock > 0 ? "In stock" : "Out of stock",
                            style: TextStyle(
                              color: stock > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // Color Selection - ONLY SHOW IF WE HAVE COLORS
              if (_availableColors.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            "Color: ${selectedColor ?? "Select Color"}",
                            style:
                            const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _buildColorOptions(),
                      ),
                    ),
                  ],
                ),

              // Size Selection
              if (_availableSizes.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            "Size: ${selectedSize ?? "Select Size"}",
                            style:
                            const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    // Size Options
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _buildSizeOptions(),
                      ),
                    ),
                  ],
                ),

              // Choices Selection (for other options)
              if (_availableChoices.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            "Options: ${_getSelectedChoice() ?? "Select Option"}",
                            style:
                            const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    // Choice Options
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _buildChoiceOptions(),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 10),

              // Description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Description",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: ReadMoreText(
                  parseHtmlString(product.description ?? ''),
                  trimLines: 2,
                  colorClickableText: Colors.blue,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: ' Read more',
                  trimExpandedText: ' Read less',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  moreStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  lessStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),

              // Product Details expandable
              ExpansionTile(
                title: const Text(
                  "Product Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: [
                  ProductDetailsTable(
                    details: {
                      "Pack of": "1",
                      "Style Code": product.sku,
                      "Brand": product.brand ?? "Not specified",
                      "Category": product.category ?? "Not specified",
                      "Subcategory": product.subcategory.join(", "),
                      "Stock": product.stock.toString(),
                      "Selected Color": selectedColor ?? "Not selected",
                      "Selected Size": selectedSize ?? "Not selected",
                    },
                  ),
                ],
              ),

              // Vendor Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vendor Title
                  const Padding(
                    padding: EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 4),
                    child: Text(
                      "Vendor",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Vendor Details
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ReadMoreText(
                      parseHtmlString(product.vendor ?? 'No vendor information'),
                      trimLines: 2,
                      colorClickableText: Colors.blue,
                      trimMode: TrimMode.Line,
                      trimCollapsedText: ' Read more',
                      trimExpandedText: ' Read less',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      moreStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                      lessStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),

              // Size Chart expandable
              ExpansionTile(
                initiallyExpanded: showSizeChart,
                title: const Text("Size Chart",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("Size")),
                        DataColumn(label: Text("Chart")),
                        DataColumn(label: Text("Brand Size")),
                        DataColumn(label: Text("Shoulder")),
                        DataColumn(label: Text("Length")),
                      ],
                      rows: List.generate(
                        5,
                            (index) => const DataRow(cells: [
                          DataCell(Text("38")),
                          DataCell(Text("40.94")),
                          DataCell(Text("XS")),
                          DataCell(Text("17.52")),
                          DataCell(Text("26.54")),
                        ]),
                      ),
                    ),
                  )
                ],
              ),

              // Reviews
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reviews Header
                    Row(
                      children: [
                        const Text(
                          "Reviews & Feedback",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        // Rating Row - Clickable to show reviews
                        Consumer<ReviewProvider>(
                          builder: (context, reviewProvider, _) {
                            // Get the latest rating stats
                            final reviewStats = reviewProvider
                                .getProductReviewStats(widget.product.id);
                            final averageRating =
                            reviewStats['averageRating'] as double;
                            final totalReviews =
                            reviewStats['totalReviews'] as int;

                            return GestureDetector(
                              onTap: () => _showProductReviews(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.orange, size: 20),
                                    const SizedBox(width: 5),
                                    Text(
                                      totalReviews > 0
                                          ? "${averageRating.toStringAsFixed(1)} out of 5"
                                          : "No ratings yet",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.arrow_forward_ios,
                                        size: 14, color: Colors.grey),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Add Review Form
                    _buildReviewForm(),
                  ],
                ),
              ),

              // Similar Products
              _buildSimilarProductsList(),

              _buildRecentViewsSection(),

              const SizedBox(height: 50),
            ],
          ),
        ),

        bottomNavigationBar: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            final int quantity =
            cartProvider.getQuantityForProduct(product.id);
            final bool isInCart = quantity > 0;

            return Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🏷️ Price Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Final price (after discount)
                        Text(
                          "₹${_calculateFinalPrice().toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Show original price and savings only if there's a discount
                        if (_calculateDiscountAmount() > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Original price with strikethrough
                              Text(
                                "₹${widget.product.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const Spacer(),

                    // 🛒 Add to Cart Button
                    SizedBox(
                      height: 50,
                      width: 140,
                      child: AddToCartButton(
                        trolley: const Icon(Icons.shopping_cart,
                            color: Colors.white, size: 22),
                        text: const Text(
                          'Add to Cart',
                          textAlign: TextAlign.center,
                          style:
                          TextStyle(fontSize: 14, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                        ),
                        check: const Icon(Icons.check,
                            color: Colors.white, size: 40),
                        borderRadius: BorderRadius.circular(12),
                        backgroundColor: Colors.blue.shade900,
                        stateId: _addToCartState,
                        onPressed: (stateId) async {
                          if (stateId == AddToCartButtonStateId.idle) {
                            setState(() => _addToCartState =
                                AddToCartButtonStateId.loading);

                            await Future.delayed(
                                const Duration(seconds: 1));

                            // ✅ Add to Cart
                            await cartProvider.addToCart(product, 1);

                            setState(() => _addToCartState =
                                AddToCartButtonStateId.done);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                const Text("Item added to cart!"),
                                action: SnackBarAction(
                                  label: "View Cart",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                          const CartScreen()),
                                    );
                                  },
                                ),
                              ),
                            );

                            await Future.delayed(
                                const Duration(seconds: 2));
                            if (mounted) {
                              setState(() => _addToCartState =
                                  AddToCartButtonStateId.idle);
                            }
                          } else if (stateId ==
                              AddToCartButtonStateId.done) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CartScreen()),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ⚡ Buy Now Button
                    SizedBox(
                      height: 50,
                      width: 140,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Buy Now logic
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD39841),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.flash_on,
                            color: Colors.white, size: 20),
                        label: const Text(
                          "BUY NOW",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to build color options
  // List<Widget> _buildColorOptions() {
  //   return _availableColors.map((colorName) {
  //     final bool isSelected = selectedColor == colorName;
  //     final Color colorValue = _getColorFromString(colorName);
  //
  //     return GestureDetector(
  //       onTap: () => setState(() => selectedColor = colorName),
  //       child: Container(
  //         width: 36,
  //         height: 36,
  //         decoration: BoxDecoration(
  //           shape: BoxShape.circle,
  //           color: colorValue,
  //           border: Border.all(
  //             color:
  //             colorValue == Colors.white ? Colors.grey : Colors.transparent,
  //             width: 1,
  //           ),
  //         ),
  //         child: isSelected
  //             ? Icon(
  //           Icons.check,
  //           size: 20,
  //           color:
  //           colorValue == Colors.white ? Colors.black : Colors.white,
  //         )
  //             : null,
  //       ),
  //     );
  //   }).toList();
  // }

  // Helper method to get color from string
  // Color _getColorFromString(String colorName) {
  //   final colorMap = {
  //     'red': Colors.red,
  //     'blue': Colors.blue,
  //     'green': Colors.green,
  //     'yellow': Colors.yellow,
  //     'orange': Colors.orange,
  //     'purple': Colors.purple,
  //     'pink': Colors.pink,
  //     'brown': Colors.brown,
  //     'black': Colors.black,
  //     'white': Colors.white,
  //     'grey': Colors.grey,
  //     'gray': Colors.grey,
  //     'teal': Colors.teal,
  //     'cyan': Colors.cyan,
  //     'indigo': Colors.indigo,
  //     'amber': Colors.amber,
  //     'lime': Colors.lime,
  //     'maroon': Color(0xFF800000),
  //     'navy': Color(0xFF000080),
  //     'olive': Color(0xFF808000),
  //     'silver': Color(0xFFC0C0C0),
  //     'gold': Color(0xFFFFD700),
  //     'beige': Color(0xFFF5F5DC),
  //     'turquoise': Color(0xFF40E0D0),
  //     'lavender': Color(0xFFE6E6FA),
  //     'coral': Color(0xFFFF7F50),
  //     'salmon': Color(0xFFFA8072),
  //     'magenta': Color(0xFFFF00FF),
  //     'violet': Color(0xFFEE82EE),
  //   };
  //
  //   // Clean the color name
  //   final cleanName = colorName.toLowerCase().trim();
  //
  //   // Try to find exact match
  //   final exactMatch = colorMap[cleanName];
  //   if (exactMatch != null) return exactMatch;
  //
  //   // Try to find partial match
  //   for (final entry in colorMap.entries) {
  //     if (cleanName.contains(entry.key)) {
  //       return entry.value;
  //     }
  //   }
  //
  //   // Generate a color from the string hash as fallback
  //   return _generateColorFromString(colorName);
  // }
  List<Widget> _buildColorOptions() {
    return _availableColors.map((colorName) {
      final bool isSelected = selectedColor == colorName;

      final Color colorValue = _getColorFromString(colorName);

      return Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => selectedColor = colorName),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorValue,
                border: Border.all(
                  color: isSelected ? Colors.orange : Colors.grey,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: isSelected
                  ? Icon(
                Icons.check,
                color: colorValue.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              )
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            colorName.toUpperCase(),
            style: const TextStyle(fontSize: 10),
          ),
        ],
      );
    }).toList();
  }

  Color _getColorFromString(String colorName) {
    final colorMap = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'brown': Colors.brown,
      'black': Colors.black,
      'white': Colors.white,
      'grey': Colors.grey,
      'gray': Colors.grey,
      'teal': Colors.teal,
      'cyan': Colors.cyan,
      'indigo': Colors.indigo,
      'amber': Colors.amber,
      'lime': Colors.lime,
      'maroon': Color(0xFF800000),
      'navy': Color(0xFF000080),
      'olive': Color(0xFF808000),
      'silver': Color(0xFFC0C0C0),
      'gold': Color(0xFFFFD700),
      'beige': Color(0xFFF5F5DC),
      'turquoise': Color(0xFF40E0D0),
      'lavender': Color(0xFFE6E6FA),
      'coral': Color(0xFFFF7F50),
      'salmon': Color(0xFFFA8072),
      'magenta': Color(0xFFFF00FF),
      'violet': Color(0xFFEE82EE),
    };

    final clean = colorName.toLowerCase().trim();

    // 1️⃣ Exact match
    if (colorMap.containsKey(clean)) return colorMap[clean]!;

    // 2️⃣ Partial match: example → “navy blue”
    for (var key in colorMap.keys) {
      if (clean.contains(key)) return colorMap[key]!;
    }

    // 3️⃣ HEX COLOR support like "#FF5733"
    if (clean.startsWith("#") && clean.length == 7) {
      return Color(int.parse(clean.substring(1), radix: 16) + 0xFF000000);
    }

    // 4️⃣ Fallback → Generate color from string (works for ANY text)
    return _generateColorFromString(colorName);
  }

  // Generate a consistent color from string hash
  Color _generateColorFromString(String text) {
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }

    final int r = (hash & 0xFF0000) >> 16;
    final int g = (hash & 0x00FF00) >> 8;
    final int b = hash & 0x0000FF;

    return Color.fromRGBO(
      r.clamp(50, 200),
      g.clamp(50, 200),
      b.clamp(50, 200),
      1.0,
    );
  }

  // Helper method to build size options
  List<Widget> _buildSizeOptions() {
    return _availableSizes.map((size) {
      final bool isSelected = selectedSize == size;

      return GestureDetector(
        onTap: () => setState(() => selectedSize = size),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.grey,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? Colors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            size,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }).toList();
  }

  // Helper method to build choice options
  List<Widget> _buildChoiceOptions() {
    return _availableChoices.map((choice) {
      final bool isSelected = _getSelectedChoice() == choice;

      return GestureDetector(
        onTap: () => setState(() {
          selectedColor = choice;
        }),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.grey,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? Colors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            choice,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }).toList();
  }

  // Helper method to get selected choice
  String? _getSelectedChoice() {
    return selectedColor;
  }

  Widget _buildSimilarProductsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Similar Products",
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        // Similar Products List
        Consumer<ProductProvider>(
          builder: (context, productProvider, child) {
            // Filter products to show similar ones (same category/subcategory)
            final similarProducts =
            _getSimilarProducts(productProvider.products);

            return ProductListWidget(
              products: similarProducts,
              isLoading: productProvider.isLoading,
              onProductTap: _onSimilarProductTap,
              scrollDirection: Axis.horizontal,
              height: 250,
            );
          },
        ),
      ],
    );
  }

  List<Product> _getSimilarProducts(List<Product> allProducts) {
    final currentProduct = widget.product;

    // Filter products that are in the same category but exclude current product
    return allProducts.where((product) {
      final isSameCategory = product.category == currentProduct.category;
      final isNotCurrentProduct = product.id != currentProduct.id;
      return isSameCategory && isNotCurrentProduct;
    }).toList();
  }

  void _onSimilarProductTap(Product product) {
    // Add to recent views
    _addToRecentViews(product.id);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailScreen(product: product),
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

  Widget _buildRecentViewsSection() {
    return Consumer<RecentViewProvider>(
      builder: (context, recentViewProvider, child) {
        if (recentViewProvider.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (recentViewProvider.error != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'Error loading recent views',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      recentViewProvider.getRecentViews();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (recentViewProvider.recentViews.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recently Viewed",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Recent Views List
            _buildRecentViewList(recentViewProvider.recentViews),
          ],
        );
      },
    );
  }

  Widget _buildRecentViewList(List<Product> recentViews) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: recentViews.length,
        itemBuilder: (context, index) {
          final product = recentViews[index];
          return _buildRecentViewItem(product);
        },
      ),
    );
  }

  Widget _buildRecentViewItem(Product product) {
    final screenWidth = MediaQuery.of(context).size.width;

    String? imageUrl;
    if (product.images.isNotEmpty && product.images.first.isNotEmpty) {
      imageUrl =
      "${ApiService.baseUrl}/assets/img/products-images/${product.images.first}";
    } else if (product.productThumb != null &&
        product.productThumb!.isNotEmpty) {
      imageUrl =
      "${ApiService.baseUrl}/assets/img/products-images/${product.productThumb}";
    }

    return GestureDetector(
      onTap: () => _onRecentViewProductTap(product),
      child: Container(
        width: screenWidth * 0.44,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 130,
                width: double.infinity,
                child: imageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 300),
                  placeholder: (context, url) =>
                      _buildProductImageShimmer(),
                  errorWidget: (context, url, error) =>
                      _buildErrorImage(),
                )
                    : _buildErrorImage(),
              ),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  const SizedBox(height: 5),

                  // Price
                  Row(
                    children: [
                      if (_shouldShowDiscountForProduct(product)) ...[
                        Text(
                          "₹${product.price}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        "₹${_calculateFinalPriceForProduct(product).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text(
                          "${product.averageRating.toStringAsFixed(1)} (${product.ratingCount})"),
                      const Spacer(),
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

  double _calculateFinalPriceForProduct(Product product) {
    final double price = product.price;
    final double discount = product.discountPrice;

    if (price > 0 && discount > 0) {
      return price - discount;
    }
    return price;
  }

  bool _shouldShowDiscountForProduct(Product product) {
    final double price = product.price;
    final double discount = product.discountPrice;

    return price > 0 && discount > 0 && discount < price;
  }

  void _onRecentViewProductTap(Product product) {
    // Add to recent views again (updates the timestamp)
    _addToRecentViews(product.id);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailScreen(product: product),
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
      cacheHeight: 260,
      cacheWidth: 260,
      filterQuality: FilterQuality.low,
    );
  }

  Future<void> _addToRecentViews(int productId) async {
    try {
      await Provider.of<RecentViewProvider>(context, listen: false)
          .addRecentView(productId);
    } catch (e) {
      print('❌ Error in _addToRecentViews: $e');
    }
  }

  Widget _buildReviewForm() {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, _) {
        return Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Add Your Review",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Rating Selection
                const Text(
                  "Rating*",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRating = index + 1;
                        });
                      },
                      child: Icon(
                        index < _selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.orange,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Review Field
                const Text("Review*",
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: _reviewController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Write your review here...",
                    alignLabelWithHint: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                          color: Colors.blue.shade300, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                          color: Colors.blue.shade300, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                          color: Colors.blue.shade300, width: 1),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Error Message
                if (reviewProvider.error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      reviewProvider.error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                // Publish Button
                Row(
                  children: [
                    const Spacer(),
                    if (reviewProvider.isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12),
                        ),
                        onPressed: _submitReview,
                        child: const Text(
                          "Publish Review",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    final success = await reviewProvider.addReview(
      productId: widget.product.id,
      rating: _selectedRating,
      review: _reviewController.text,
    );

    if (success) {
      _reviewController.clear();
      setState(() {
        _selectedRating = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    }
  }

  void _showProductReviews(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewsBottomSheet(product: widget.product),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}

class ReviewsBottomSheet extends StatelessWidget {
  final Product product;

  const ReviewsBottomSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.reviews, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "Product Reviews",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Reviews Content
          Expanded(
            child: Consumer<ReviewProvider>(
              builder: (context, reviewProvider, _) {
                if (reviewProvider.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          "Loading reviews...",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (reviewProvider.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          "Failed to load reviews",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reviewProvider.error,
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            reviewProvider.fetchProductReviews(product.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final reviewStats =
                reviewProvider.getProductReviewStats(product.id);
                final productReviews = reviewStats['reviews'] as List<Review>;
                final averageRating = reviewStats['averageRating'] as double;
                final totalReviews = reviewStats['totalReviews'] as int;
                final ratingDistribution =
                reviewStats['ratingDistribution'] as Map<int, int>;
                final percentageDistribution =
                reviewStats['percentageDistribution'] as Map<int, double>;

                if (productReviews.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.reviews_outlined,
                            size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          "No Reviews Yet",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Be the first to share your thoughts about this product!",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade500,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Write a Review'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Rating Summary Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Average Rating Box
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade100),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      Icons.star,
                                      color: index < averageRating.floor()
                                          ? Colors.green
                                          : Colors.grey.shade300,
                                      size: 16,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$totalReviews ${totalReviews == 1 ? 'Review' : 'Reviews'}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 20),

                          // Rating Distribution
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RatingProgressBar(
                                  rating: 5,
                                  count: ratingDistribution[5] ?? 0,
                                  percentage: percentageDistribution[5] ?? 0.0,
                                  totalReviews: totalReviews,
                                ),
                                RatingProgressBar(
                                  rating: 4,
                                  count: ratingDistribution[4] ?? 0,
                                  percentage: percentageDistribution[4] ?? 0.0,
                                  totalReviews: totalReviews,
                                ),
                                RatingProgressBar(
                                  rating: 3,
                                  count: ratingDistribution[3] ?? 0,
                                  percentage: percentageDistribution[3] ?? 0.0,
                                  totalReviews: totalReviews,
                                ),
                                RatingProgressBar(
                                  rating: 2,
                                  count: ratingDistribution[2] ?? 0,
                                  percentage: percentageDistribution[2] ?? 0.0,
                                  totalReviews: totalReviews,
                                ),
                                RatingProgressBar(
                                  rating: 1,
                                  count: ratingDistribution[1] ?? 0,
                                  percentage: percentageDistribution[1] ?? 0.0,
                                  totalReviews: totalReviews,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Reviews Count and Filter
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "All Reviews ($totalReviews)",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    // Reviews List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: productReviews.length,
                        itemBuilder: (context, index) {
                          return ReviewItem(review: productReviews[index]);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewItem extends StatelessWidget {
  final Review review;

  const ReviewItem({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info and Rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                radius: 20,
                child: Icon(
                  Icons.person,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String?>(
                      future: _getStoredUserName(),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? "User",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Star Rating
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color: index < review.rating
                              ? Colors.green
                              : Colors.grey.shade300,
                          size: 16,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Review Text
          Text(
            review.review,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),

          // Verified Purchase Badge (Optional)
          if (review.rating >= 4)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green.shade100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.green.shade600, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    "Verified Purchase",
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class RatingProgressBar extends StatelessWidget {
  final int rating;
  final int count;
  final double percentage;
  final int totalReviews;

  const RatingProgressBar({
    super.key,
    required this.rating,
    required this.count,
    required this.percentage,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$rating',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.star, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: totalReviews == 0 ? 0 : count / totalReviews,
              backgroundColor: Colors.grey.shade200,
              valueColor:
              AlwaysStoppedAnimation<Color>(_getRatingColor(rating)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.orange.shade300;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Helper method to get stored user name
Future<String?> _getStoredUserName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("user_name");
}

// Improved date formatting
String _formatDate(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  } catch (e) {
    return dateString;
  }
}

void _showLoginRequiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Login Required"),
        content: const Text("Please login to add items to your wishlist."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: const Text("Login"),
          ),
        ],
      );
    },
  );
}

class ProductDetailsTable extends StatelessWidget {
  final Map<String, String> details;

  const ProductDetailsTable({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3), // key column
          1: FlexColumnWidth(5), // value column
        },
        children: details.entries.map((entry) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  entry.value,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
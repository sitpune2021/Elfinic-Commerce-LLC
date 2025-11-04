import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:readmore/readmore.dart';
import 'dart:convert';
import 'package:elfinic_commerce_llc/model/CategoriesResponse.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/ProductsResponse.dart';
import '../providers/CartProvider.dart';
import '../providers/WishlistProvider.dart';
import '../services/api_service.dart';
import '../utils/BaseScreen.dart';
import 'CartScreen.dart';
import 'package:collection/collection.dart';
import 'package:flutter_add_to_cart_button/flutter_add_to_cart_button.dart';

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

  @override
  void initState() {
    super.initState();
    // Fetch initial cart items when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
      wishlistProvider.fetchWishlist();
      _refreshCartFromProvider();
      _refreshWishlistFromProvider();
    });
  }

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

  AddToCartButtonStateId _addToCartState = AddToCartButtonStateId.idle;

  /// Calculate discount percentage
  /// Calculate discount percentage
  /// Calculate discount percentage
  /// Calculate discount percentage - FIXED VERSION
  String _calculateDiscountPercentage() {
    final product = widget.product;

    // Debug: Print values to see what's happening
    print('🟡 Discount Calculation Debug:');
    print('🟡 Original Price: ${product.price}');
    print('🟡 Discount Amount: ${product.discountPrice}');
    print('🟡 Product discountPercentage: ${product.discountPercentage}');

    if (product.hasDiscount && product.discountPrice > 0) {
      // Calculate percentage manually to ensure accuracy
      final double calculatedPercentage = (product.discountPrice / product.price) * 100;
      final int roundedPercentage = calculatedPercentage.round();

      print('🟡 Calculated Percentage: $calculatedPercentage%');
      print('🟡 Rounded Percentage: $roundedPercentage%');

      return "$roundedPercentage% Off";
    }

    return ""; // No discount
  }
  /// Calculate final price after discount
  /// Calculate final price after discount
  double _calculateFinalPrice() {
    final product = widget.product;

    // If there's a discount, subtract discount from original price
    if (product.hasDiscount && product.discountPrice > 0) {
      return product.price - product.discountPrice;
    }

    // Otherwise return the original price
    return product.price;
  }

  /// Calculate discount amount (how much user saves)
  double _calculateDiscountAmount() {
    final product = widget.product;

    if (product.hasDiscount && product.discountPrice > 0) {
      return product.discountPrice;
    }

    return 0.0;
  }
  /// Calculate discount amount

  /// Check if discount badge should be shown
  bool _shouldShowDiscountBadge() {
    // Use the helper method from Product class
    return widget.product.hasDiscount;
  }

  // Helper method to get all available colors from product options
// UPDATED: Helper method to get all available colors from product options
  List<String> get _availableColors {
    final List<String> colors = [];
    for (final option in widget.product.options) {
      // Check for color array
      if (option.color != null && option.color!.isNotEmpty) {
        colors.addAll(option.color!);
      }
      // ALSO check for choices array that contains color names
      if (option.choices != null && option.choices!.isNotEmpty) {
        // Filter choices that are valid color names
        final colorChoices = option.choices!.where((choice) =>
            _isValidColorName(choice)).toList();
        colors.addAll(colorChoices);
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
    for (final option in widget.product.options) {
      if (option.size != null && option.size!.isNotEmpty) {
        sizes.addAll(option.size!);
      }
    }
    return sizes.toSet().toList(); // Remove duplicates
  }

  // Helper method to get all available choices from product options
  List<String> get _availableChoices {
    final List<String> choices = [];
    for (final option in widget.product.options) {
      if (option.choices != null && option.choices!.isNotEmpty) {
        choices.addAll(option.choices!);
      }
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
                // Count unique items instead of total quantity
                final uniqueItemCount = cartProvider.cartItems.length;

                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CartScreen()),
                        );
                        final cartProvider =
                        Provider.of<CartProvider>(context, listen: false);
                        cartProvider.fetchCartItems();
                      },
                      icon: const Icon(Icons.shopping_cart_outlined,
                          color: Colors.black),
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

                            return Image.network(
                              "${ApiService.baseUrl}/assets/img/products-images/${product.images[index]}",
                              height: 350,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/no_product_img2.png",
                                  height: 350,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
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
                  // Empty box just to balance left side
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
                          final isWishlisted = wishlistProvider.isInWishlist(product.id);

                          return IconButton(
                            icon: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              color: isWishlisted ? Colors.red : Colors.black,
                            ),
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();
                              final userIdString = prefs.getString('user_id');
                              final userId = int.tryParse(userIdString ?? '0') ?? 0;

                              if (userId == 0) {
                                _showLoginRequiredDialog(context);
                                return;
                              }

                              print('🌀 Wishlist Toggle Triggered for Product ID: ${product.id}');

                              final success =
                              await wishlistProvider.toggleWishlist(product.id);

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
                                      content: Text('Failed to update wishlist ❌')),
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text("${product.averageRating} (${product.ratingCount} Ratings)"),
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
                              color:
                              stock > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // Color Selection
              // Color Selection - UPDATED VERSION

              // Color Selection - ALWAYS SHOW THIS SECTION
              // Color Selection - ONLY SHOW IF WE HAVE COLORS FROM API
              if (_buildColorOptions().isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            "Color: ${selectedColor ?? "Select Color"}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            "Size: ${selectedSize ?? "Select Size"}", // This will now show "small" or "Large"
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    // Size Options
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            "Options: ${_getSelectedChoice() ?? "Select Option"}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    // Choice Options
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      "Subcategory": product.subcategory ?? "Not specified",
                      "Stock": product.stock.toString(),
                      "Selected Color": selectedColor ?? "Not selected",
                      "Selected Size": selectedSize ?? "Not selected", // Update this line
                    },
                  ),
                ],
              ),

              // Size Chart expandable
              ExpansionTile(
                initiallyExpanded: showSizeChart,
                title: const Text("Size Chart",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      Row(
                        children: [
                          const Text("Reviews & feedback",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange),
                              const SizedBox(width: 5),
                              Text("${product.averageRating} out of 5"),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name & Email Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text("Name*",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        decoration: InputDecoration(
                                          hintText: "Name",
                                          contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                                color: Colors.blue.shade300,
                                                width: 1),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                                color: Colors.blue.shade300,
                                                width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                                color: Colors.blue.shade300,
                                                width: 1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text("Email*",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        decoration: InputDecoration(
                                          hintText: "Email",
                                          contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                                color: Colors.blue.shade300,
                                                width: 1),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                                color: Colors.blue.shade300,
                                                width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                                color: Colors.blue.shade300,
                                                width: 1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Review Field
                            const Text("Review*",
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            TextField(
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: "Write here",
                                alignLabelWithHint: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                      color: Colors.blue.shade300, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                      color: Colors.blue.shade300, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                      color: Colors.blue.shade300, width: 1),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Publish Button
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo.shade900,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28, vertical: 12),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  "Publish",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ]),
              ),

              // Similar Products
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Text("Similar Products",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(onPressed: () {}, child: const Text("View All"))
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Horizontal Product List
                  SizedBox(
                    height: 270,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image with Wishlist Button
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12)),
                                    child: Image.asset(
                                      "assets/images/w1.png",
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        icon: const Icon(Icons.favorite_border,
                                            color: Colors.orange),
                                        onPressed: () {},
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Product Info
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Lorem ipsum dolor sit amet consectetur.",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: const [
                                        Text(
                                          "₹4,148.00",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              decoration:
                                              TextDecoration.lineThrough),
                                        ),
                                        SizedBox(width: 6),
                                        Text("₹2,996.50",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: const [
                                        Icon(Icons.star,
                                            size: 16, color: Colors.orange),
                                        SizedBox(width: 4),
                                        Text("4.8",
                                            style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
        bottomNavigationBar: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            final int quantity = cartProvider.getQuantityForProduct(product.id);
            final bool isInCart = quantity > 0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    // 🏷️ Price Section
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
                              // Amount saved with percentage
                              // Amount saved with both amount and percentage
                              // Text(
                              //   "You save ₹${_calculateDiscountAmount().toStringAsFixed(2)} (${_calculateDiscountPercentage()})",
                              //   style: const TextStyle(
                              //     fontSize: 12,
                              //     color: Colors.green,
                              //     fontWeight: FontWeight.w500,
                              //   ),
                              // ),
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
                          style: TextStyle(fontSize: 14, color: Colors.white),
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

                            await Future.delayed(const Duration(seconds: 1));

                            // ✅ Add to Cart
                            await cartProvider.addToCart(product, 1);

                            setState(() =>
                            _addToCartState = AddToCartButtonStateId.done);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Item added to cart!"),
                                action: SnackBarAction(
                                  label: "View Cart",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const CartScreen()),
                                    );
                                  },
                                ),
                              ),
                            );

                            await Future.delayed(const Duration(seconds: 2));
                            if (mounted) {
                              setState(() => _addToCartState =
                                  AddToCartButtonStateId.idle);
                            }
                          } else if (stateId == AddToCartButtonStateId.done) {
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

  // SIMPLIFIED VERSION - Use this if above doesn't work
  // UPDATED: Only show default colors if API doesn't provide any
  // CLEAN VERSION: Only show API colors, no default colors
  List<Widget> _buildColorOptions() {
    // Only show colors from product options (API)
    if (_availableColors.isNotEmpty) {
      print('🟡 Using API colors: $_availableColors');
      return _availableColors.map((colorName) {
        final bool isSelected = selectedColor == colorName;
        final Color colorValue = _getColorFromString(colorName);

        return GestureDetector(
          onTap: () => setState(() => selectedColor = colorName),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorValue,
              border: Border.all(
                color: colorValue == Colors.white ? Colors.grey : Colors.transparent,
                width: 1,
              ),
            ),
            child: isSelected
                ? Icon(
              Icons.check,
              size: 20,
              color: colorValue == Colors.white ? Colors.black : Colors.white,
            )
                : null,
          ),
        );
      }).toList();
    }

    // If no colors from API, return empty list
    print('🔴 No API colors available');
    return [];
  }
  // Helper method to determine if we should show default colors
  bool _shouldShowDefaultColors() {
    // Check if the product has any color-related options at all
    final hasAnyColorOptions = widget.product.options.any((option) =>
    option.color != null && option.color!.isNotEmpty);

    // If product has no color options at all, show default colors
    if (!hasAnyColorOptions) {
      return true;
    }

    // If product has color options but they don't include black, show default colors
    final hasBlackColor = _availableColors.any((color) =>
        color.toLowerCase().contains('black'));

    return !hasBlackColor;
  }

  // Helper method to get color from string
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

    // Clean the color name
    final cleanName = colorName.toLowerCase().trim();

    // Try to find exact match
    final exactMatch = colorMap[cleanName];
    if (exactMatch != null) return exactMatch;

    // Try to find partial match
    for (final entry in colorMap.entries) {
      if (cleanName.contains(entry.key)) {
        return entry.value;
      }
    }

    // Generate a color from the string hash as fallback
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

  // Helper method to get color from string - COMPLETE VERSION



  // Helper method to build size options
  List<Widget> _buildSizeOptions() {
    return _availableSizes.map((size) {
      final bool isSelected = selectedSize == size; // Compare strings directly

      return GestureDetector(
        onTap: () => setState(() => selectedSize = size), // Store string directly
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
          // Store the selected choice (you might want to use a separate variable)
          // For simplicity, we'll just store it in selectedColor for now
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


/*
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
  int? selectedSize;
  bool isAddedToCart = false;
  int quantity = 0;
  bool isWishlisted = false;

  @override
  void initState() {
    super.initState();
    // Fetch initial cart items when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
      wishlistProvider.fetchWishlist();
      _refreshCartFromProvider();
      _refreshWishlistFromProvider();
    });
  }

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

  AddToCartButtonStateId _addToCartState = AddToCartButtonStateId.idle;

  /// Calculate discount percentage
  String _calculateDiscountPercentage() {
    final product = widget.product;

    // Use the helper method from Product class
    if (product.hasDiscount) {
      return "${product.discountPercentage.round()}% Off";
    }
    return ""; // No discount
  }

  /// Calculate final price after discount
  double _calculateFinalPrice() {
    // Use the helper method from Product class
    return widget.product.effectivePrice;
  }

  /// Check if discount badge should be shown
  bool _shouldShowDiscountBadge() {
    // Use the helper method from Product class
    return widget.product.hasDiscount;
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
                // Count unique items instead of total quantity
                final uniqueItemCount = cartProvider.cartItems.length;

                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CartScreen()),
                        );
                        final cartProvider =
                        Provider.of<CartProvider>(context, listen: false);
                        cartProvider.fetchCartItems();
                      },
                      icon: const Icon(Icons.shopping_cart_outlined,
                          color: Colors.black),
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

                            return Image.network(
                              "${ApiService.baseUrl}/assets/img/products-images/${product.images[index]}",
                              height: 350,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/no_product_img2.png",
                                  height: 350,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
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
                  // Empty box just to balance left side
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
                          final isWishlisted = wishlistProvider.isInWishlist(product.id);

                          return IconButton(
                            icon: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              color: isWishlisted ? Colors.red : Colors.black,
                            ),
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();
                              final userIdString = prefs.getString('user_id');
                              final userId = int.tryParse(userIdString ?? '0') ?? 0;

                              if (userId == 0) {
                                _showLoginRequiredDialog(context);
                                return;
                              }

                              print('🌀 Wishlist Toggle Triggered for Product ID: ${product.id}');

                              final success =
                              await wishlistProvider.toggleWishlist(product.id);

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
                                      content: Text('Failed to update wishlist ❌')),
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text("${product.averageRating} (${product.ratingCount} Ratings)"),
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
                              color:
                              stock > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // Size Selection
              if (product.options.isNotEmpty &&
                  product.options.any((option) => option.availableOptions != null))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            "Size: ${selectedSize != null ? selectedSize.toString() : ""}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),

                    // Dynamic Sizes from product options
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _buildSizeOptions(product),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 10),

              // Description
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Description",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      "Subcategory": product.subcategory ?? "Not specified",
                      "Stock": product.stock.toString(),
                    },
                  ),
                ],
              ),

              // Size Chart expandable
              ExpansionTile(
                initiallyExpanded: showSizeChart,
                title: const Text("Size Chart",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      Row(
                        children: [
                          const Text("Reviews & feedback",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange),
                              const SizedBox(width: 5),
                              Text("${product.averageRating} out of 5"),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name & Email Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text("Name*",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        decoration: InputDecoration(
                                          hintText: "Name",
                                          contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                                color: Colors.blue.shade300,
                                                width: 1),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                                color: Colors.blue.shade300,
                                                width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                                color: Colors.blue.shade300,
                                                width: 1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text("Email*",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        decoration: InputDecoration(
                                          hintText: "Email",
                                          contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                                color: Colors.blue.shade300,
                                                width: 1),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                                color: Colors.blue.shade300,
                                                width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(30),
                                            borderSide: BorderSide(
                                                color: Colors.blue.shade300,
                                                width: 1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Review Field
                            const Text("Review*",
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            TextField(
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: "Write here",
                                alignLabelWithHint: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                      color: Colors.blue.shade300, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                      color: Colors.blue.shade300, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                      color: Colors.blue.shade300, width: 1),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Publish Button
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo.shade900,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28, vertical: 12),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  "Publish",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ]),
              ),

              // Similar Products
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Text("Similar Products",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(onPressed: () {}, child: const Text("View All"))
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Horizontal Product List
                  SizedBox(
                    height: 270,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 180,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image with Wishlist Button
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12)),
                                    child: Image.asset(
                                      "assets/images/w1.png",
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        icon: const Icon(Icons.favorite_border,
                                            color: Colors.orange),
                                        onPressed: () {},
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Product Info
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Lorem ipsum dolor sit amet consectetur.",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: const [
                                        Text(
                                          "₹4,148.00",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              decoration:
                                              TextDecoration.lineThrough),
                                        ),
                                        SizedBox(width: 6),
                                        Text("₹2,996.50",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: const [
                                        Icon(Icons.star,
                                            size: 16, color: Colors.orange),
                                        SizedBox(width: 4),
                                        Text("4.8",
                                            style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
        bottomNavigationBar: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            final int quantity = cartProvider.getQuantityForProduct(product.id);
            final bool isInCart = quantity > 0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        Text(
                          "₹${_calculateFinalPrice().toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_shouldShowDiscountBadge())
                          Text(
                            "₹${product.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
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
                          style: TextStyle(fontSize: 14, color: Colors.white),
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

                            await Future.delayed(const Duration(seconds: 1));

                            // ✅ Add to Cart
                            await cartProvider.addToCart(product, 1);

                            setState(() =>
                            _addToCartState = AddToCartButtonStateId.done);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Item added to cart!"),
                                action: SnackBarAction(
                                  label: "View Cart",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const CartScreen()),
                                    );
                                  },
                                ),
                              ),
                            );

                            await Future.delayed(const Duration(seconds: 2));
                            if (mounted) {
                              setState(() => _addToCartState =
                                  AddToCartButtonStateId.idle);
                            }
                          } else if (stateId == AddToCartButtonStateId.done) {
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

  // Helper method to build size options from product data
  List<Widget> _buildSizeOptions(Product product) {
    final List<Widget> sizeWidgets = [];

    for (final option in product.options) {
      if (option.availableOptions != null && option.availableOptions!.isNotEmpty) {
        for (final size in option.availableOptions!) {
          sizeWidgets.add(
            GestureDetector(
              onTap: () => setState(() => selectedSize = int.tryParse(size) ?? 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: selectedSize == (int.tryParse(size) ?? 0)
                      ? Colors.orange
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    color: selectedSize == (int.tryParse(size) ?? 0)
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    // Fallback to default sizes if no sizes in product options
    if (sizeWidgets.isEmpty) {
      return [26, 28, 30, 32, 34, 36].map((size) {
        return GestureDetector(
          onTap: () => setState(() => selectedSize = size),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: selectedSize == size
                  ? Colors.orange
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              size.toString(),
              style: TextStyle(
                color: selectedSize == size
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList();
    }

    return sizeWidgets;
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

*/


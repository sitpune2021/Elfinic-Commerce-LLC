import 'package:cached_network_image/cached_network_image.dart';
import 'package:elfinic_commerce_llc/widget/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_add_to_cart_button/flutter_add_to_cart_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../providers/SimilarProductProvider.dart';
import '../providers/WishlistProvider.dart';
import '../services/api_service.dart';
import '../utils/BaseScreen.dart';

import 'CartScreen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:html/parser.dart' as html_parser;

// ===============================
// PRODUCT DETAIL MODELS
// ===============================

class ProductDetailResponse {
  final bool status;
  final String message;
  final ProductDetail? data;

  ProductDetailResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      status: json['status']?.toString().toLowerCase() == 'success',
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? ProductDetail.fromJson(
              Map<String, dynamic>.from(json['data']),
            )
          : null,
    );
  }
}

class ProductDetail {
  final int id;
  final String name;
  final String slug;
  final String? brand;
  final String? category;
  final List<String> subcategory;
  final String? productDetails;
  final String? description;
  final String? price;
  final String? discountPrice;
  final String? totalPrice;
  final String? stock;
  final String? sku;
  final String? barcode;
  final String? gst;
  final int quantity;
  final String status;
  final int ratingCount;
  final double averageRating;
  final List<String> images;
  final String? productThumb;
  final List<ProductOption> options;
  final List<ProductVariant> variants;
  final String? vendor;
  final String? vendorId;

  ProductDetail({
    required this.id,
    required this.name,
    required this.slug,
    this.brand,
    this.category,
    required this.subcategory,
    this.productDetails,
    this.description,
    this.price,
    this.discountPrice,
    this.totalPrice,
    this.stock,
    this.sku,
    this.barcode,
    this.gst,
    required this.quantity,
    required this.status,
    required this.ratingCount,
    required this.averageRating,
    required this.images,
    this.productThumb,
    required this.options,
    required this.variants,
    this.vendor,
    this.vendorId,
  });

  // ✅ REQUIRED: API → MODEL
  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      brand: json['brand']?.toString(),
      category: json['category']?.toString(),
      subcategory: _parseStringList(json['subcategory']),
      productDetails: json['product_details']?.toString(),
      description: json['description']?.toString(),
      price: json['price']?.toString(),
      discountPrice: json['discount_price']?.toString(),
      totalPrice: json['total_price']?.toString(),
      stock: json['stock']?.toString(),
      sku: json['sku']?.toString(),
      barcode: json['barcode']?.toString(),
      gst: json['gst']?.toString(),
      quantity: _parseInt(json['quantity']),
      status: json['status']?.toString() ?? '',
      ratingCount: _parseInt(json['ratingCount']),
      averageRating: _parseDouble(json['averageRating']),
      images: _parseStringList(json['images']),
      productThumb: json['product_thumb']?.toString(),
      options: (json['options'] as List? ?? [])
          .map((e) => ProductOption.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      variants: (json['variants'] as List? ?? [])
          .map((e) => ProductVariant.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      vendor: json['vendor']?.toString(),
      vendorId: json['vendorId']?.toString(),
    );
  }

  // ✅ OPTIONAL: LIST → DETAIL (used when slug not available)
  factory ProductDetail.fromProduct(Product product) {
    return ProductDetail(
      id: product.id,
      name: product.name,
      slug: product.slug ?? '',
      brand: product.brand,
      category: product.category,
      subcategory: product.subcategory,
      productDetails: null,
      description: null,
      price: product.price.toString(),
      discountPrice: product.discountPrice.toString(),
      totalPrice: product.totalPrice.toString(),
      stock: product.stock.toString(),
      sku: product.sku,
      barcode: null,
      gst: null,
      quantity: product.quantity,
      status: product.status,
      ratingCount: product.ratingCount,
      averageRating: product.averageRating,
      images: product.images,
      productThumb: product.productThumb,
      options: const [],
      variants: const [],
      vendor: null,
      vendorId: null,
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  static int _parseInt(dynamic value) =>
      int.tryParse(value?.toString() ?? '0') ?? 0;

  static double _parseDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '0') ?? 0.0;
}

class ProductOption {
  final String? optionType;
  final String? displayType;
  final String? size;
  final List<String> connectingImages;

  ProductOption({
    this.optionType,
    this.displayType,
    this.size,
    required this.connectingImages,
  });

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    return ProductOption(
      optionType: json['option_type']?.toString(),
      displayType: json['display_type']?.toString(),
      size: json['size']?.toString(),
      connectingImages: _parseConnectingImages(json['connecting_image']),
    );
  }

  static List<String> _parseConnectingImages(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value
          .expand((e) => e.toString().split(','))
          .map((e) => e.trim())
          .toList();
    }
    return [];
  }
}

class ProductVariant {
  final int id;
  final String? variant;
  final String? variantPrice;
  final String? priceDifference;
  final String? costOfGoods;
  final String? sku;
  final int inventory;
  final String? shippingWeight;
  final String status;

  ProductVariant({
    required this.id,
    this.variant,
    this.variantPrice,
    this.priceDifference,
    this.costOfGoods,
    this.sku,
    required this.inventory,
    this.shippingWeight,
    required this.status,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: _parseInt(json['id']),
      variant: json['variant']?.toString(),
      variantPrice: json['variant_price']?.toString(),
      priceDifference: json['price_difference']?.toString(),
      costOfGoods: json['cost_of_goods']?.toString(),
      sku: json['sku']?.toString(),
      inventory: _parseInt(json['inventory']),
      shippingWeight: json['shipping_weight']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }
}

// ===============================
// PRODUCT DETAIL SCREEN
// ===============================

class ProductDetailScreen extends StatefulWidget {
  final Product? product;
  final String? slug;

  const ProductDetailScreen({
    super.key,
    this.product,
    this.slug,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  int activeIndex = 0;
  String? selectedSize;
  String? selectedColor;
  String? selectedVariantName; // varient name

  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 0;
  AddToCartButtonStateId _addToCartState = AddToCartButtonStateId.idle;

  ProductDetail? _fetchedProduct;
  bool _isLoading = true;
  String _error = '';

  ProductVariant? _selectedVariant;

  @override
  void initState() {
    super.initState();
    _loadProductDetails();
  }

  void _loadProductDetails() {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    if (widget.slug != null && widget.slug!.isNotEmpty) {
      _fetchProductBySlug(widget.slug!);
    } else if (widget.product != null) {
      _initializeWithProduct(widget.product!);
    } else {
      setState(() {
        _isLoading = false;
        _error = 'No product information available';
      });
    }
  }

  Future<void> _fetchProductBySlug(String slug) async {
    try {
      final response = await ApiService().getProductBySlug(slug);

      if (response.status && response.data != null) {
        setState(() {
          _fetchedProduct = response.data!;
          _isLoading = false;
          _initializeSelectedOptions();
        });

        // Print variant information
        _printVariantInfo();
        _initializeProviders();
      } else {
        setState(() {
          _isLoading = false;
          _error = response.message;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error: $e';
      });
      debugPrint('Error fetching product by slug: $e');
    }
  }

  void _initializeWithProduct(Product product) {
    _fetchedProduct = ProductDetail.fromProduct(product);

    setState(() {
      _isLoading = false;
      _initializeSelectedOptions();
    });

    _initializeProviders();
  }

  void _initializeProviders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final similarProvider =
          Provider.of<SimilarProductProvider>(context, listen: false);

      similarProvider.fetchSimilarProducts(getProduct.id);

      final wishlistProvider =
          Provider.of<WishlistProvider>(context, listen: false);
      wishlistProvider.fetchWishlist();
      _refreshCartFromProvider();
      _refreshWishlistFromProvider();

      final recentViewProvider =
          Provider.of<RecentViewProvider>(context, listen: false);
      recentViewProvider.getRecentViews();
      _addToRecentViews(getProduct.id);

      final reviewProvider =
          Provider.of<ReviewProvider>(context, listen: false);

      reviewProvider.loadEligibility(getProduct.id); // ✅ ADD THIS

      reviewProvider.fetchProductReviews(getProduct.id);
    });
  }

  void _printVariantInfo() {
    final product = getProduct;
    if (product.variants.isNotEmpty) {
      debugPrint('📋 Product Variants for ${product.name}:');
      for (var variant in product.variants) {
        debugPrint('   ✅ Variant ID: ${variant.id}');
        debugPrint('      Name: ${variant.variant}');
        debugPrint('      Price: ${variant.variantPrice}');
        debugPrint('      Inventory: ${variant.inventory}');
        debugPrint('      Status: ${variant.status}');
        debugPrint('      ---');
      }
    } else {
      debugPrint('ℹ️ No variants found for this product');
    }
  }

  ProductDetail get getProduct {
    if (_fetchedProduct != null) return _fetchedProduct!;
    if (widget.product != null) {
      return ProductDetail.fromProduct(widget.product!);
    }
    throw Exception("Product not available");
  }

  //
  void _initializeSelectedOptions() {
    final product = getProduct;

    // Reset everything
    _selectedVariant = null;
    selectedSize = null;
    selectedColor = null;
    selectedVariantName = null;

    if (product.variants.isEmpty) {
      debugPrint('ℹ️ No variants available for this product');
      return;
    }

    final availableSizes = _availableSizes;
    final availableColors = _availableColors;

    // Step 1: Try selecting FIRST variant (safe default)
    _selectedVariant = product.variants.first;

    // Step 2: Set variant name
    selectedVariantName = _selectedVariant!.variant;

    // Step 3: Extract color & size from variant name
    if (selectedVariantName != null) {
      final parts = selectedVariantName!.split('/');

      // Format: product/color/size
      if (parts.length >= 3) {
        final color = parts[1].trim();
        final size = parts[2].trim();

        if (availableColors.contains(color)) {
          selectedColor = color;
        }

        if (availableSizes.contains(size)) {
          selectedSize = size;
        }
      }
      // Format: product/color OR product/size
      else if (parts.length == 2) {
        final value = parts[1].trim();

        if (availableSizes.contains(value)) {
          selectedSize = value;
        } else if (availableColors.contains(value)) {
          selectedColor = value;
        }
      }
    }

    // Step 4: Fallback if color/size still null
    selectedColor ??= availableColors.isNotEmpty ? availableColors.first : null;
    selectedSize ??= availableSizes.isNotEmpty ? availableSizes.first : null;

    // Step 5: Try to find exact matching variant again
    for (final variant in product.variants) {
      if (variant.variant == null) continue;

      final parts = variant.variant!.split('/');

      if (parts.length >= 3) {
        final vColor = parts[1].trim();
        final vSize = parts[2].trim();

        if ((selectedColor == null || vColor == selectedColor) &&
            (selectedSize == null || vSize == selectedSize)) {
          _selectedVariant = variant;
          selectedVariantName = variant.variant;
          break;
        }
      } else if (parts.length == 2) {
        final value = parts[1].trim();

        if ((selectedColor != null && value == selectedColor) ||
            (selectedSize != null && value == selectedSize)) {
          _selectedVariant = variant;
          selectedVariantName = variant.variant;
          break;
        }
      }
    }

    // Step 6: Final safety fallback
    _selectedVariant ??= product.variants.first;
    selectedVariantName ??= _selectedVariant!.variant;

    // Final debug
    debugPrint('✅ DEFAULT VARIANT INITIALIZED');
    debugPrint('   Variant Name: $selectedVariantName');
    debugPrint('   Color: $selectedColor');
    debugPrint('   Size: $selectedSize');
    debugPrint('   Variant ID: ${_selectedVariant!.id}');
  }

  //

  // // Replace the _initializeSelectedOptions method with this updated version:
  // void _initializeSelectedOptions() {
  //   final product = getProduct;
  //   _selectedVariant = null;

  //   // ALWAYS reset and set default values for each product
  //   selectedVariantName = null;
  //   selectedSize = null;
  //   selectedColor = null;

  //   if (product.variants.isEmpty) {
  //     debugPrint('ℹ️ No variants available for this product');
  //     return;
  //   }

  //   if (product.variants.isNotEmpty) {
  //     // Get available sizes and colors from options
  //     final availableSizes = _availableSizes;
  //     final availableColors = _availableColors;

  //     // ALWAYS set default size if available
  //     if (availableSizes.isNotEmpty) {
  //       selectedSize = availableSizes.first;
  //       print('🎯 Default size set to....: $selectedSize');
  //     }

  //     // ALWAYS set default color if available
  //     if (availableColors.isNotEmpty) {
  //       selectedColor = availableColors.first;
  //       print('🎯 Default color set to: $selectedColor');
  //     }

  //     // Try to find a variant matching the selected color/size
  //     for (final variant in product.variants) {
  //       if (variant.variant != null) {
  //         final variantParts = variant.variant!.split('/');

  //         // Handle variants with format: something/color/size
  //         if (variantParts.length >= 3) {
  //           final variantColor = variantParts[1].trim();
  //           final variantSize = variantParts[2].trim();

  //           if ((selectedColor == null || variantColor == selectedColor) &&
  //               (selectedSize == null || variantSize == selectedSize)) {
  //             _selectedVariant = variant;
  //             print('✅ Default variant selected: ${variant.variant}');
  //             break;
  //           }
  //         }
  //         // Handle variants with format: something/color OR something/size
  //         else if (variantParts.length == 2) {
  //           final variantValue = variantParts[1].trim();

  //           if ((selectedColor != null && variantValue == selectedColor) ||
  //               (selectedSize != null && variantValue == selectedSize)) {
  //             _selectedVariant = variant;
  //             print('✅ Default variant selected: ${variant.variant}');
  //             break;
  //           }
  //         }
  //       }
  //     }

  //     // If no exact match found and we have a size or color selected, find the first matching variant
  //     if (_selectedVariant == null) {
  //       for (final variant in product.variants) {
  //         if (variant.variant != null) {
  //           final variantParts = variant.variant!.split('/');

  //           if (variantParts.length >= 2) {
  //             final variantValue = variantParts[1].trim();

  //             if ((selectedColor != null && variantValue == selectedColor) ||
  //                 (selectedSize != null && variantValue == selectedSize)) {
  //               _selectedVariant = variant;
  //               print('✅ Fallback variant selected: ${variant.variant}');
  //               break;
  //             }
  //           }
  //         }
  //       }
  //     }

  //     // If still no variant selected, select the first available variant
  //     if (_selectedVariant == null && product.variants.isNotEmpty) {
  //       _selectedVariant = product.variants.first;
  //       print(
  //           '✅ First variant selected as default: ${_selectedVariant!.variant}');
  //     }

  //     // Print the final selected variant info
  //     _printSelectedVariantInfo();
  //   } else {
  //     print('ℹ️ No variants available for this product');
  //   }
  // }

  void _printSelectedVariantInfo() {
    if (_selectedVariant != null) {
      debugPrint('✅ SELECTED VARIANT:');
      debugPrint('   ID: ${_selectedVariant!.id}');
      debugPrint('   Name: ${_selectedVariant!.variant}');
      debugPrint('   Price: ${_selectedVariant!.variantPrice}');
      debugPrint('   Inventory: ${_selectedVariant!.inventory}');
      debugPrint('   Status: ${_selectedVariant!.status}');
    } else {
      debugPrint('ℹ️ No variant selected');
    }
  }

  void _updateSelectedVariant() {
    final product = getProduct;

    if (product.variants.isEmpty) {
      _selectedVariant = null;
      return;
    }

    debugPrint('🔍 SEARCHING FOR VARIANT:');
    debugPrint('   Selected Color: $selectedColor');
    debugPrint('   Selected Size: $selectedSize');

    // Find variant matching both color and size
    for (final variant in product.variants) {
      if (variant.variant != null) {
        final variantParts = variant.variant!.split('/');

        debugPrint('   Checking variant: ${variant.variant}');

        if (variantParts.length >= 3) {
          // Format: something/color/size
          final variantColor = variantParts[1].trim();
          final variantSize = variantParts[2].trim();

          if ((selectedColor == null || variantColor == selectedColor) &&
              (selectedSize == null || variantSize == selectedSize)) {
            _selectedVariant = variant;
            debugPrint(
                '✅ MATCHED VARIANT: ${variant.variant} (ID: ${variant.id})');
            return;
          }
        } else if (variantParts.length == 2) {
          // Format: something/color OR something/size
          final variantValue = variantParts[1].trim();

          if ((selectedColor != null && variantValue == selectedColor) ||
              (selectedSize != null && variantValue == selectedSize)) {
            _selectedVariant = variant;
            debugPrint(
                '✅ MATCHED VARIANT: ${variant.variant} (ID: ${variant.id})');
            return;
          }
        }
      }
    }

    // If no exact match found, find the first variant that matches at least one criteria
    for (final variant in product.variants) {
      if (variant.variant != null) {
        final variantParts = variant.variant!.split('/');

        if (variantParts.length >= 2) {
          final variantValue = variantParts[1].trim();

          if ((selectedColor != null && variantValue == selectedColor) ||
              (selectedSize != null && variantValue == selectedSize)) {
            _selectedVariant = variant;
            debugPrint(
                '⚠️ PARTIAL MATCH: ${variant.variant} (ID: ${variant.id})');
            return;
          }
        }
      }
    }
    _printSelectedVariantInfo();

    _selectedVariant = null;
  }

  void _refreshCartFromProvider() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.fetchCartItems();
  }

  void _refreshWishlistFromProvider() {
    final wishlistProvider =
        Provider.of<WishlistProvider>(context, listen: false);
    wishlistProvider.fetchWishlist();
  }

  String parseHtmlString(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? '';
  }

  String _calculateDiscountPercentage() {
    final product = getProduct;
    final price =
        double.tryParse(product.price?.replaceAll(',', '') ?? '0') ?? 0;
    final discountPrice = double.tryParse(product.discountPrice ?? '0') ?? 0;

    if (discountPrice > 0 && price > 0) {
      final double calculatedPercentage = (discountPrice / price) * 100;
      final int roundedPercentage = calculatedPercentage.round();
      return "$roundedPercentage% Off";
    }

    return "";
  }

  double _calculateFinalPrice() {
    final product = getProduct;
    final price =
        double.tryParse(product.price?.replaceAll(',', '') ?? '0') ?? 0;
    final discountPrice = double.tryParse(product.discountPrice ?? '0') ?? 0;

    return discountPrice > 0 ? discountPrice : price;
  }

  double _calculateDiscountAmount() {
    final product = getProduct;
    return double.tryParse(product.discountPrice ?? '0') ?? 0;
  }

  bool _shouldShowDiscountBadge() {
    return _calculateDiscountAmount() > 0;
  }

  List<String> get _availableColors {
    return getProduct.options
        .where((o) => o.optionType?.toLowerCase() == 'color')
        .map((o) => o.size ?? '')
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> get _availableSizes {
    return getProduct.options
        .where((o) => o.optionType?.toLowerCase() == 'size')
        .map((o) => o.size ?? '')
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
  }

  ProductDetail _convertToProduct(ProductDetail p,
      {ProductVariant? selectedVariant}) {
    // Use variant price if available, otherwise use product price
    String price = p.price ?? "0";
    String stock = p.stock ?? "0";
    String sku = p.sku ?? "";

    if (selectedVariant != null) {
      price = selectedVariant.variantPrice ?? price;
      stock = selectedVariant.inventory.toString();
      sku = selectedVariant.sku ?? sku;
    }

    final basePrice = double.tryParse(price.replaceAll(',', '')) ?? 0;
    final discount = double.tryParse(p.discountPrice ?? "0") ?? 0;
    final finalPrice = discount > 0 ? basePrice - discount : basePrice;

    return ProductDetail(
      id: p.id,
      name: p.name,
      slug: p.slug,
      brand: p.brand,
      category: p.category,
      subcategory: p.subcategory,
      price: price,
      discountPrice: p.discountPrice,
      totalPrice: finalPrice.toStringAsFixed(2),
      stock: stock,
      sku: sku,
      barcode: p.barcode,
      gst: p.gst,
      quantity: p.quantity,
      status: p.status,
      ratingCount: p.ratingCount,
      averageRating: p.averageRating,
      images: selectedVariant != null &&
              p.options.isNotEmpty &&
              p.options.first.connectingImages.isNotEmpty
          ? p.options.first.connectingImages
          : p.images,
      productThumb: p.productThumb,
      options: p.options,
      variants: p.variants,
      vendor: p.vendor,
      vendorId: p.vendorId,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_error.isNotEmpty) {
      return _buildErrorScreen();
    }

    return _buildProductDetailScreen();
  }

  Widget _buildLoadingScreen() {
    return BaseScreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomLoader(),
              SizedBox(height: 20),
              Text('Loading product details...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return BaseScreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 20),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadProductDetails,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetailScreen() {
    final product = getProduct;
    final int stock = int.tryParse(product.stock ?? '0') ?? 0;

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
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CartScreen(fromProductDetail: true)),
                        );
                        if (!context.mounted) return;
                        final cartProvider =
                            Provider.of<CartProvider>(context, listen: false);
                        cartProvider.fetchCartItems();
                      },
                      icon: SvgPicture.asset(
                        'assets/icons/shopping-cart.svg',
                        width: 26,
                        height: 26,
                        colorFilter: const ColorFilter.mode(
                            Colors.black, BlendMode.srcIn),
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
                padding: const EdgeInsets.all(1.0),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4.5,
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
                              fit: BoxFit.contain,
                            );
                          }

                          return Hero(
                            tag: 'product-image-${product.id}',
                            child: CachedNetworkImage(
                              imageUrl:
                                  "${ApiService.baseUrl}/assets/img/products-images/${product.images[index]}",
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              filterQuality: FilterQuality.high,
                              fadeInDuration: const Duration(milliseconds: 250),
                              placeholder: (context, url) => Container(
                                color: Colors.white,
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                "assets/images/no_product_img2.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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

              // Page Indicator
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 90),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.black),
                        onPressed: () {},
                      ),
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
                                final message = isWishlisted
                                    ? 'Removed from wishlist ❤️‍🔥'
                                    : 'Added to wishlist ❤️';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Failed to update wishlist ❌')),
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
                            color:
                                stock > 0 ? Colors.green[100] : Colors.red[100],
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

              // Color Selection
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
                            style: const TextStyle(fontWeight: FontWeight.w600),
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

              // // Size Selection
              // if (product.variants.isNotEmpty && _availableSizes.isNotEmpty)
              //   Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Padding(
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: 12, vertical: 8),
              //         child: Row(
              //           children: [
              //             Text(
              //               "Size: ${selectedSize ?? "Select Size"}",
              //               style: const TextStyle(fontWeight: FontWeight.w600),
              //             ),
              //             const Spacer(),
              //           ],
              //         ),
              //       ),
              //       Padding(
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: 12, vertical: 8),
              //         child: Wrap(
              //           spacing: 8,
              //           runSpacing: 8,
              //           children: _buildSizeOptions(),
              //         ),
              //       ),
              //     ],
              //   ),

              // Variant Selection
              if (product.variants.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            "Size: ${selectedVariantName ?? "Select Variant"}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _buildVariantOptions(),
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
                      "Style Code": product.sku ?? "Not specified",
                      "Brand": product.brand ?? "Not specified",
                      "Category": product.category ?? "Not specified",
                      "Subcategory": product.subcategory.join(", "),
                      "Stock": product.stock ?? "0",
                      "Selected Color": selectedColor ?? "Not selected",
                      "Selected Size": selectedSize ?? "Not selected",
                    },
                  ),
                ],
              ),

              // Vendor Section
              if (product.vendor != null && product.vendor!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ReadMoreText(
                        parseHtmlString(product.vendor!),
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

              // Reviews
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Reviews & Feedback",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Consumer<ReviewProvider>(
                          builder: (context, reviewProvider, _) {
                            final reviewStats = reviewProvider
                                .getProductReviewStats(product.id);
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
                                  border:
                                      Border.all(color: Colors.grey.shade200),
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

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildAvailableOfferContent(),
                    ),
                    const SizedBox(height: 10),
                    // _buildReviewForm(),

                    /// ✅ CONDITIONAL REVIEW FORM
                    Consumer<ReviewProvider>(
                      builder: (context, reviewProvider, _) {
                        if (reviewProvider.loading) return const SizedBox();
                        if (!reviewProvider.eligible) return const SizedBox();

                        if (reviewProvider.loading) {
                          return const SizedBox();
                        }

                        if (!reviewProvider.eligible) {
                          debugPrint('❌ Review form hidden (not eligible)');
                          return const SizedBox();
                        }

                        debugPrint('✅ Review form visible (eligible)');
                        return _buildReviewFormUI();
                      },
                    ),
                    ////////----
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
            final product = getProduct;
            cartProvider.getQuantityForProduct(product.id);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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
                        if (_calculateDiscountAmount() > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "₹${(double.tryParse(product.price?.replaceAll(',', '') ?? '0') ?? 0).toStringAsFixed(2)}",
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

                            final product = getProduct;
                            int? variantId;

                            // 🔥 LOGIC TO GET VARIANT ID
                            // 1. Check if we have a selected variant from options
                            if (_selectedVariant != null) {
                              variantId = _selectedVariant!.id;
                              debugPrint('✅ Selected variant ID: $variantId');
                              debugPrint(
                                  '✅ Selected variant name: ${_selectedVariant!.variant}');
                              debugPrint('✅ Selected color: $selectedColor');
                              debugPrint('✅ Selected size: $selectedSize');
                            }
                            // 2. If no variant selected but product has variants, use the first one
                            else if (product.variants.isNotEmpty) {
                              variantId = product.variants.first.id;
                              debugPrint(
                                  '✅ Using first variant ID: $variantId');
                              debugPrint(
                                  '⚠️ WARNING: No variant explicitly selected, using first available');
                            }
                            // 3. If product has no variants, variantId remains null
                            else {
                              debugPrint(
                                  'ℹ️ Product has no variants, adding without variant_id');
                            }

                            // Debug output
                            debugPrint('🛒 Adding to Cart:');
                            debugPrint('   Product ID: ${product.id}');
                            debugPrint('   Product Name: ${product.name}');
                            debugPrint('   Variant ID: $variantId');
                            debugPrint(
                                '   Selected Variant Object: $_selectedVariant');
                            try {
                              await cartProvider.addToCart(
                                product,
                                1,
                                variantId:
                                    variantId, // 🔥 PASS VARIANT ID (could be null)
                              );

                              setState(() => _addToCartState =
                                  AddToCartButtonStateId.done);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(variantId != null
                                      ? "Item added"
                                      // ? "Item added to cart (Variant: ${_selectedVariant?.variant ?? variantId})"
                                      : "Item added to cart!"),
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
                            } catch (e) {
                              if (!context.mounted) return;
                              debugPrint('❌ Error adding to cart: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to add to cart: $e')),
                              );
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
                    SizedBox(
                      height: 50,
                      width: 140,
                      child: ElevatedButton.icon(
                        onPressed: _buyNow,
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

  List<Widget> _buildColorOptions() {
    return _availableColors.map((colorName) {
      final bool isSelected = selectedColor == colorName;
      final Color colorValue = _getColorFromString(colorName);

      return Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedColor = colorName;
                _updateSelectedVariant();
              });
            },
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

    if (colorMap.containsKey(clean)) return colorMap[clean]!;

    for (var key in colorMap.keys) {
      if (clean.contains(key)) return colorMap[key]!;
    }

    if (clean.startsWith("#") && clean.length == 7) {
      return Color(int.parse(clean.substring(1), radix: 16) + 0xFF000000);
    }

    return _generateColorFromString(colorName);
  }

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

  List<Widget> _buildVariantOptions() {
    return getProduct.variants.map((variant) {
      final isSelected = _selectedVariant?.id == variant.id;
      final variantName = variant.variant ?? '';

      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedVariant = variant;
            selectedVariantName = variantName;

            final parts = variantName.split('/');
            if (parts.length >= 3) {
              selectedColor = parts[1].trim();
              selectedSize = parts[2].trim();
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.grey,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? Colors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            variantName,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildSizeOptions() {
    return _availableSizes.map((size) {
      final bool isSelected = selectedSize == size;

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedSize = size;
            _updateSelectedVariant();
          });
        },
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

  Widget _buildSimilarProductsList() {
    return Consumer<SimilarProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CustomLoader()),
          );
        }

        if (provider.error.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Failed to load similar products",
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (provider.products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(
                "Similar Products",
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ProductListWidget(
              products: provider.products,
              isLoading: false,
              onProductTap: _onSimilarProductTap,
              scrollDirection: Axis.horizontal,
              height: 344,
            ),
          ],
        );
      },
    );
  }

  void _onSimilarProductTap(Product product) {
    if (product.slug == null || product.slug!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product not available")),
      );
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailScreen(
          product: product,
          slug: product.slug!,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
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
            child: Center(child: CustomLoader()),
          );
        }

        if (recentViewProvider.error != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                children: [
                  const Text('Error loading recent views',
                      style: TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => recentViewProvider.getRecentViews(),
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
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
    _addToRecentViews(product.id);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailScreen(product: product, slug: product.slug),
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
      debugPrint('❌ Error in _addToRecentViews: $e');
    }
  }

  // offer
  Widget _buildAvailableOfferContent() {
    bool showAll = false;

    final List<String> offers = [
      'Free delivery on orders over ₹500',
      'Special Price Get extra 8% off T&C',
      'Bank Offer 10% instant discount on SBI Credit Card EMI Transactions, '
          'up to ₹1,500 on orders of ₹5,000 and above',
      'No Cost EMI on select cards for orders above ₹3,000 T&C',
      'Partner Offer Sign up for Amazon Pay ICICI Credit Card and get ₹750 '
          'Amazon.in Gift Card T&C',
      'Additional Offer 15% off on first order',
      'Seasonal Sale Extra 20% off on selected items',
      'Buy 1 Get 1 Free on premium products',
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        final visibleOffers = showAll ? offers : offers.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Offers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...visibleOffers.map(_buildOfferItem),
            GestureDetector(
              onTap: () {
                setState(() {
                  showAll = !showAll;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  showAll ? 'Show Less -' : 'Show More +',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _BottomInfo(icon: Icons.verified, label: 'Original Products'),
                _BottomInfo(icon: Icons.money, label: 'Cash on Delivery'),
                _BottomInfo(icon: Icons.schedule, label: '7-day Returns'),
              ],
            ),
          ],
        );
      },
    );
  }

  // Widget _buildAvailableOfferContent() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         'Available Offers',
  //         style: TextStyle(
  //           fontSize: 18,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       _buildOfferItem('Free delivery on orders over ₹500'),
  //       _buildOfferItem('Special Price Get extra 8% off T&C'),
  //       _buildOfferItem(
  //         'Bank Offer 10% instant discount on SBI Credit Card EMI Transactions, '
  //         'up to ₹1,500 on orders of ₹5,000 and above',
  //       ),
  //       _buildOfferItem(
  //         'No Cost EMI on select cards for orders above ₹3,000 T&C',
  //       ),
  //       _buildOfferItem(
  //         'Partner Offer Sign up for Amazon Pay ICICI Credit Card and get ₹750 '
  //         'Amazon.in Gift Card T&C',
  //       ),
  //       _buildOfferItem('Additional Offer 15% off on first order'),
  //       _buildOfferItem('Seasonal Sale Extra 20% off on selected items'),
  //       _buildOfferItem('Buy 1 Get 1 Free on premium products'),
  //       const SizedBox(height: 8),
  //       const Text(
  //         'Show Less -',
  //         style: TextStyle(
  //           color: Colors.blue,
  //           fontSize: 14,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //       const SizedBox(height: 16),
  //       const Divider(),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //         children: const [
  //           _BottomInfo(icon: Icons.verified, label: 'Original Products'),
  //           _BottomInfo(icon: Icons.money, label: 'Cash on Delivery'),
  //           _BottomInfo(icon: Icons.schedule, label: '7-day Returns'),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buildOfferItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.local_offer, size: 18, color: Colors.indigo),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildReviewFormUI() {
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
                const Text("Add Your Review",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text("Rating*",
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedRating = index + 1),
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
                      borderSide:
                          BorderSide(color: Colors.blue.shade300, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Colors.blue.shade300, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Colors.blue.shade300, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (reviewProvider.error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      reviewProvider.error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Row(
                  children: [
                    const Spacer(),
                    if (reviewProvider.isLoading)
                      const CustomLoader()
                    else
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade900,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
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
          const SnackBar(content: Text('Please select a rating')));
      return;
    }

    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please write a review')));
      return;
    }

    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    final success = await reviewProvider.addReview(
      productId: getProduct.id,
      rating: _selectedRating,
      review: _reviewController.text,
    );

    if (success) {
      _reviewController.clear();
      setState(() => _selectedRating = 0);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')));
    }
  }

  void _showProductReviews(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewsBottomSheet(product: getProduct),
    );
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              child: const Text("Login"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _buyNow() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    final product = _convertToProduct(getProduct);

    // 1️⃣ Add to cart if not already present
    final qty = cartProvider.getQuantityForProduct(product.id);
    if (qty == 0) {
      await cartProvider.addToCart(product, 1);
    }

    // 2️⃣ Build checkout cart list (ONLY this product)
    cartProvider.cartItems.firstWhere(
      (e) => e.product.id == product.id,
    );

// or _calculateFinalPrice()

    /*// 3️⃣ Open Address Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressScreen(
          fromProfile: false,
          subtotalAmount: subtotal,
          cartItems: [selectedCartItem],
          appliedCoupon: null,
          couponDiscount: 0,
        ),
      ),
    );*/
  }
}

// ===============================
// SUPPORTING WIDGETS
// ===============================

class ProductDetailsTable extends StatelessWidget {
  final Map<String, String> details;

  const ProductDetailsTable({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(5),
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

class ReviewsBottomSheet extends StatelessWidget {
  final ProductDetail product;

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
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.reviews, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                const Text("Product Reviews",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<ReviewProvider>(
              builder: (context, reviewProvider, _) {
                if (reviewProvider.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomLoader(),
                        SizedBox(height: 16),
                        Text("Loading reviews...",
                            style: TextStyle(color: Colors.grey)),
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
                        Text("Failed to load reviews",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700)),
                        const SizedBox(height: 8),
                        Text(reviewProvider.error,
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () =>
                              reviewProvider.fetchProductReviews(product.id),
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
                        Text("No Reviews Yet",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text(
                            "Be the first to share your thoughts about this product!",
                            style: TextStyle(color: Colors.grey.shade500),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
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
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                      color: Colors.green),
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
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "All Reviews ($totalReviews)",
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                radius: 20,
                child:
                    Icon(Icons.person, color: Colors.blue.shade600, size: 20),
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
                              fontWeight: FontWeight.w600, fontSize: 16),
                        );
                      },
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(review.createdAt),
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
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
          Text(
            review.review,
            style: const TextStyle(
                fontSize: 14, height: 1.5, color: Colors.black87),
          ),
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
                        fontWeight: FontWeight.w500),
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
          Text('$rating',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
                fontWeight: FontWeight.w500),
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

Future<String?> _getStoredUserName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("user_name");
}

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

class _BottomInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BottomInfo({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: Colors.green),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

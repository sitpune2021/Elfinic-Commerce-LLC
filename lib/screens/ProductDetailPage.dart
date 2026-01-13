// ignore_for_file: file_names

import 'dart:io';
import 'package:elfinic_commerce_llc/model/get_review_model.dart';
import 'package:elfinic_commerce_llc/utils/image_preview_dialog.dart';
import 'package:elfinic_commerce_llc/utils/video_player_dialog.dart';
import 'package:elfinic_commerce_llc/widget/full_screen_image_view.dart';
import 'package:elfinic_commerce_llc/widget/full_screen_video_player.dart';
import 'package:path/path.dart' as p;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:elfinic_commerce_llc/utils/app_colors.dart';
import 'package:elfinic_commerce_llc/widget/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_add_to_cart_button/flutter_add_to_cart_button.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../model/ProductsResponse.dart';
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

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int activeIndex = 0;
  String? selectedSize;
  String? selectedColor;
  String? selectedVariantName; // varient name

  bool _isAdding = false;
  bool _isAdded = false;

  late AnimationController _heartController;
  late Animation<double> _scaleAnim;

  final TextEditingController _reviewController = TextEditingController();
  AddToCartButtonStateId _addToCartState = AddToCartButtonStateId.idle;

  ProductDetail? _fetchedProduct;
  bool _isLoading = true;
  String _error = '';

  ProductVariant? _selectedVariant;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  //===================== compress ========================
  Future<File?> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    final xFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // 🔥 balanced quality
    );

    if (xFile == null) return null;
    return File(xFile.path);
  }

  Future<File?> _compressVideo(File file) async {
    final info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
      includeAudio: true,
      deleteOrigin: false,
    );

    if (info == null || info.file == null) return null;

    return info.file; // ✅ File?
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
    final provider = context.read<ReviewProvider>();
    const maxSize = 20 * 1024 * 1024;

    if (provider.images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    if (picked == null) return;

    final image = File(picked.path);

    final compressed = await _compressImage(image);
    if (compressed == null) return;

    final size = await compressed.length();
    if (size > maxSize) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image must be under 20 MB')),
      );
      return;
    }

    provider.addImages([compressed]);
  }

  Future<void> _pickImagesFromGallery(BuildContext context) async {
    final provider = context.read<ReviewProvider>();
    const maxSize = 20 * 1024 * 1024;

    if (provider.images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }

    final remaining = 5 - provider.images.length;

    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;

    if (pickedFiles.length > remaining) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only $remaining more images allowed')),
      );
    }

    for (final xFile in pickedFiles.take(remaining)) {
      final image = File(xFile.path);

      final compressed = await _compressImage(image);
      if (compressed == null) continue;

      final size = await compressed.length();
      if (size > maxSize) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image must be under 20 MB')),
        );
        continue;
      }

      provider.addImages([compressed]);
    }
  }

  // ======================= UPDATED VIDEO PICK WITH INSTANT LOADING =======================
  Future<void> _pickVideoFromCamera(BuildContext context) async {
    final provider = context.read<ReviewProvider>();
    const maxSize = 20 * 1024 * 1024;

    if (provider.videos.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only 1 video allowed')),
      );
      return;
    }

    // 1️⃣ Open video picker
    final picked = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 30),
    );

    // 2️⃣ If user cancelled, return early
    if (picked == null) return;

    // 3️⃣ ✅ IMMEDIATELY show loading state BEFORE any processing
    // This ensures the loader appears right after picker closes
    provider.setVideoProcessing(true);

    try {
      final video = File(picked.path);

      // 4️⃣ Compress video (heavy operation)
      final compressed = await _compressVideo(video);

      if (compressed == null) {
        provider.setVideoProcessing(false);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to compress video')),
        );
        return;
      }

      // 5️⃣ Check size
      final size = await compressed.length();
      if (size > maxSize) {
        provider.setVideoProcessing(false);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video must be under 20 MB')),
        );
        return;
      }

      // 6️⃣ Add video (this will generate thumbnail and update UI)
      await provider.addVideo(compressed);

      debugPrint('✅ Video processing complete');
    } catch (e) {
      debugPrint('❌ Error processing video: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      // 7️⃣ ✅ Always hide loader when done
      provider.setVideoProcessing(false);
    }
  }

  Future<void> _pickVideoFromGallery(BuildContext context) async {
    final provider = context.read<ReviewProvider>();
    const maxSize = 20 * 1024 * 1024;

    if (provider.videos.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only 1 video allowed')),
      );
      return;
    }

    // 1️⃣ Open gallery picker
    final picked = await _picker.pickVideo(source: ImageSource.gallery);

    // 2️⃣ If user cancelled, return early
    if (picked == null) return;

    // 3️⃣ ✅ IMMEDIATELY show loading state
    provider.setVideoProcessing(true);

    try {
      final video = File(picked.path);

      // 4️⃣ Compress video
      final compressed = await _compressVideo(video);

      if (compressed == null) {
        provider.setVideoProcessing(false);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to compress video')),
        );
        return;
      }

      // 5️⃣ Check size
      final size = await compressed.length();
      if (size > maxSize) {
        provider.setVideoProcessing(false);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video must be under 20 MB')),
        );
        return;
      }

      // 6️⃣ Add video and generate thumbnail
      await provider.addVideo(compressed);

      debugPrint('✅ Video processing complete');
    } catch (e) {
      debugPrint('❌ Error processing video: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      // 7️⃣ ✅ Always hide loader
      provider.setVideoProcessing(false);
    }
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImagesFromGallery(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoSourceSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              onTap: () {
                Navigator.pop(context);
                _pickVideoFromCamera(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickVideoFromGallery(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProductDetails();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.3).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeOut,
    ));

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<ReviewProvider>().loadProductReviews(product.id);
    // });
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

      reviewProvider.loadProductReviews(getProduct.id);
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
  void dispose() {
    _heartController.dispose();
    _reviewController.dispose();

    super.dispose();
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
        backgroundColor: Colors.white,
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
                      Consumer<WishlistProvider>(
                        builder: (context, wishlistProvider, _) {
                          final isWishlisted =
                              wishlistProvider.isInWishlist(product.id);

                          return IconButton(
                            icon: ScaleTransition(
                              scale: _scaleAnim,
                              child: Icon(
                                isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isWishlisted ? Colors.red : Colors.black,
                              ),
                            ),
                            onPressed: () async {
                              // 🔥 Trigger heart animation
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
                            if (reviewProvider.isLoading) {
                              return const CustomLoader();
                            }

                            final stats =
                                reviewProvider.getProductReviewStats();
                            final averageRating =
                                stats['averageRating'] as double;
                            final totalReviews = stats['totalReviews'] as int;

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
                    // SizedBox(
                    //   height: 50,
                    //   width: 140,
                    //   child: AddToCartButton(
                    //     trolley: const Icon(Icons.shopping_cart,
                    //         color: Colors.white, size: 22),
                    //     text: const Text(
                    //       'Add to Cart',
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(fontSize: 14, color: Colors.white),
                    //       maxLines: 1,
                    //       overflow: TextOverflow.fade,
                    //     ),
                    //     check: const Icon(Icons.check,
                    //         color: Colors.white, size: 40),
                    //     borderRadius: BorderRadius.circular(12),
                    //     backgroundColor: Colors.blue.shade900,
                    //     stateId: _addToCartState,
                    //     onPressed: (stateId) async {
                    //       if (stateId == AddToCartButtonStateId.idle) {
                    //         setState(() => _addToCartState =
                    //             AddToCartButtonStateId.loading);

                    //         final product = getProduct;
                    //         int? variantId;

                    //         // 🔥 LOGIC TO GET VARIANT ID
                    //         // 1. Check if we have a selected variant from options
                    //         if (_selectedVariant != null) {
                    //           variantId = _selectedVariant!.id;
                    //           debugPrint('✅ Selected variant ID: $variantId');
                    //           debugPrint(
                    //               '✅ Selected variant name: ${_selectedVariant!.variant}');
                    //           debugPrint('✅ Selected color: $selectedColor');
                    //           debugPrint('✅ Selected size: $selectedSize');
                    //         }
                    //         // 2. If no variant selected but product has variants, use the first one
                    //         else if (product.variants.isNotEmpty) {
                    //           variantId = product.variants.first.id;
                    //           debugPrint(
                    //               '✅ Using first variant ID: $variantId');
                    //           debugPrint(
                    //               '⚠️ WARNING: No variant explicitly selected, using first available');
                    //         }
                    //         // 3. If product has no variants, variantId remains null
                    //         else {
                    //           debugPrint(
                    //               'ℹ️ Product has no variants, adding without variant_id');
                    //         }

                    //         // Debug output
                    //         debugPrint('🛒 Adding to Cart:');
                    //         debugPrint('   Product ID: ${product.id}');
                    //         debugPrint('   Product Name: ${product.name}');
                    //         debugPrint('   Variant ID: $variantId');
                    //         debugPrint(
                    //             '   Selected Variant Object: $_selectedVariant');
                    //         try {
                    //           await cartProvider.addToCart(
                    //             product,
                    //             1,
                    //             variantId:
                    //                 variantId, // 🔥 PASS VARIANT ID (could be null)
                    //           );

                    //           setState(() => _addToCartState =
                    //               AddToCartButtonStateId.done);
                    //           if (!context.mounted) return;
                    //           ScaffoldMessenger.of(context).showSnackBar(
                    //             SnackBar(
                    //               content: Text(variantId != null
                    //                   ? "Item added"
                    //                   // ? "Item added to cart (Variant: ${_selectedVariant?.variant ?? variantId})"
                    //                   : "Item added to cart!"),
                    //               action: SnackBarAction(
                    //                 label: "View Cart",
                    //                 onPressed: () {
                    //                   Navigator.push(
                    //                     context,
                    //                     MaterialPageRoute(
                    //                         builder: (_) => const CartScreen()),
                    //                   );
                    //                 },
                    //               ),
                    //             ),
                    //           );

                    //           await Future.delayed(const Duration(seconds: 2));
                    //           if (mounted) {
                    //             setState(() => _addToCartState =
                    //                 AddToCartButtonStateId.idle);
                    //           }
                    //         } catch (e) {
                    //           if (!context.mounted) return;
                    //           debugPrint('❌ Error adding to cart: $e');
                    //           ScaffoldMessenger.of(context).showSnackBar(
                    //             SnackBar(
                    //                 content: Text('Failed to add to cart: $e')),
                    //           );
                    //           setState(() => _addToCartState =
                    //               AddToCartButtonStateId.idle);
                    //         }
                    //       } else if (stateId == AddToCartButtonStateId.done) {
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (_) => const CartScreen()),
                    //         );
                    //       }
                    //     },
                    //   ),
                    // ),
                    SizedBox(
                      height: 50,
                      width: 140,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isAdding
                            ? null
                            : () async {
                                setState(() {
                                  _isAdding = true;
                                });

                                final product = getProduct;
                                int? variantId;

                                // 🔥 VARIANT LOGIC (UNCHANGED)
                                if (_selectedVariant != null) {
                                  variantId = _selectedVariant!.id;
                                } else if (product.variants.isNotEmpty) {
                                  variantId = product.variants.first.id;
                                }

                                try {
                                  await cartProvider.addToCart(
                                    product,
                                    1,
                                    variantId: variantId,
                                  );

                                  setState(() {
                                    _isAdded = true;
                                    _isAdding = false;
                                  });

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text("Item added to cart"),
                                      action: SnackBarAction(
                                        label: "View Cart",
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const CartScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );

                                  // Optional: reset text after delay
                                  await Future.delayed(
                                      const Duration(seconds: 2));
                                  if (mounted) {
                                    setState(() {
                                      _isAdded = false;
                                    });
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;

                                  setState(() {
                                    _isAdding = false;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Failed to add to cart: $e'),
                                    ),
                                  );
                                }
                              },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isAdded
                              ? const Text(
                                  "Added",
                                  key: ValueKey("added"),
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                )
                              : _isAdding
                                  ? const SizedBox(
                                      key: ValueKey("loading"),
                                      height: 18,
                                      width: 18,
                                      child: CustomLoader(),
                                    )
                                  : const Row(
                                      key: ValueKey("idle"),
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.shopping_cart,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          "Add to Cart",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
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

  // ======================= COMPLETE UPDATED _buildReviewFormUI =======================
  Widget _buildReviewFormUI() {
    return Consumer<ReviewProvider>(
      builder: (context, provider, _) {
        final width = MediaQuery.of(context).size.width;
        final isTablet = width > 600;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Card(
            key: ValueKey(provider.isLoading),
            color: AppColors.kCardBg,
            elevation: 4,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 12,
              vertical: 12,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    children: const [
                      Icon(Icons.rate_review, color: AppColors.kPrimary),
                      SizedBox(width: 8),
                      Text(
                        "Add Your Review",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.kPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// RATING
                  const Text(
                    "Rating *",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => provider.setRating(index + 1),
                        child: AnimatedScale(
                          scale: index < provider.rating ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              index < provider.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: AppColors.kAccent,
                              size: isTablet ? 36 : 32,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  /// TITLE FIELD
                  _inputField(
                    controller: _titleController,
                    hint: "Review title (optional)",
                  ),

                  const SizedBox(height: 16),

                  /// CONTENT FIELD
                  _inputField(
                    controller: _contentController,
                    hint: "Write your review...",
                    maxLines: 4,
                  ),

                  const SizedBox(height: 20),

                  /// MEDIA BUTTONS
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _mediaButton(
                        icon: Icons.image,
                        label: "Add Images",
                        onTap: provider.images.length >= 5
                            ? null
                            : () => _showImageSourceSheet(context),
                      ),
                      _mediaButton(
                        icon: Icons.videocam,
                        label: "Add Video",
                        onTap: provider.videos.isNotEmpty ||
                                provider.isVideoProcessing
                            ? null
                            : () => _showVideoSourceSheet(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Max: 5 images • 1 video (20 MB)",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// UPLOAD PROGRESS
                  if (provider.isUploading) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: provider.uploadProgress,
                      color: AppColors.kPrimary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(provider.uploadProgress * 100).toStringAsFixed(0)}% uploading',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],

                  /// MEDIA PREVIEW SECTION
                  if (provider.images.isNotEmpty ||
                      provider.videos.isNotEmpty ||
                      provider.isVideoProcessing) ...[
                    const SizedBox(height: 20),

                    /// COUNT LABEL
                    Text(
                      'Images: ${provider.images.length}/5  |  Video: ${provider.videos.isNotEmpty || provider.isVideoProcessing ? "1" : "0"}/1',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// MEDIA GRID
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        /// IMAGE PREVIEWS (with tap to preview)
                        ...provider.images.asMap().entries.map((entry) {
                          final index = entry.key;
                          final file = entry.value;

                          return Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Open image preview dialog
                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.black87,
                                    builder: (context) => ImagePreviewDialog(
                                      imageFile: file,
                                      allImages: provider.images,
                                      initialIndex: index,
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.file(
                                      file,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -6,
                                right: -6,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => provider.removeImage(file),
                                ),
                              ),
                            ],
                          );
                        }),

                        /// 🎥 VIDEO PREVIEW - USING NEW METHOD
                        _buildVideoPreview(provider),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  /// SUBMIT BUTTON
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: provider.isUploading
                            ? TextButton(
                                onPressed: provider.cancelUpload,
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.red),
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.kPrimary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: provider.isUploading
                                    ? null
                                    : () async {
                                        final success =
                                            await provider.submitReview(
                                          productId: getProduct.id,
                                          title: _titleController.text,
                                          content: _contentController.text,
                                        );
                                        if (!context.mounted) return;

                                        if (success) {
                                          _titleController.clear();
                                          _contentController.clear();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "✅ Review submitted successfully"),
                                              backgroundColor: Colors.green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        } else if (provider.error.isNotEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(provider.error),
                                              backgroundColor: Colors.red,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                child: provider.isUploading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CustomLoader())
                                    : const Text(
                                        "Publish Review",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                              )

                        // : ElevatedButton(
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: AppColors.kPrimary,
                        //       foregroundColor: Colors.white,
                        //       elevation: 0,
                        //       padding: EdgeInsets.symmetric(
                        //         horizontal: isTablet ? 36 : 28,
                        //         vertical: 14,
                        //       ),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(30),
                        //       ),
                        //     ),
                        //     onPressed: () async {
                        //       await provider.submitReview(
                        //         productId: getProduct.id,
                        //         title: _titleController.text,
                        //         content: _contentController.text,
                        //       );

                        //       _titleController.clear();
                        //       _contentController.clear();
                        //     },
                        //     child: const Text(
                        //       "Publish Review",
                        //       style: TextStyle(
                        //         fontSize: 15,
                        //         fontWeight: FontWeight.w700,
                        //       ),
                        //     ),
                        //   ),
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// ======================= VIDEO PREVIEW WIDGET =======================
  Widget _buildVideoPreview(ReviewProvider provider) {
    // Don't show anything if no video and not processing
    if (provider.videos.isEmpty && !provider.isVideoProcessing) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: _buildVideoContent(provider),
          ),
        ),

        // ▶️ Play icon overlay (only when video is ready)
        if (!provider.isVideoThumbLoading &&
            !provider.isVideoProcessing &&
            provider.videoThumbnail != null)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _playVideo(context, provider.videos.first),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 40,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // ❌ Remove button (only when not processing)
        if (!provider.isVideoProcessing && provider.videos.isNotEmpty)
          Positioned(
            top: -16,
            right: -16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 22,
                  minHeight: 22,
                ),
                onPressed: () => provider.removeVideo(provider.videos.first),
              ),
            ),
          ),
      ],
    );
  }

// ======================= VIDEO CONTENT BUILDER =======================
  Widget _buildVideoContent(ReviewProvider provider) {
    // STATE 1: Video is being compressed
    if (provider.isVideoProcessing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 32,
              height: 32,
              child: CustomLoader(),
            ),
            SizedBox(height: 6),
            Text(
              'Compressing...',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // STATE 2: Thumbnail is being generated
    if (provider.isVideoThumbLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              width: 32,
              height: 32,
              child: CustomLoader(),
            ),
            SizedBox(height: 6),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // STATE 3: Thumbnail ready - show it
    if (provider.videoThumbnail != null) {
      return Image.file(
        provider.videoThumbnail!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    }

    // STATE 4: Fallback icon
    return Icon(
      Icons.videocam,
      size: 36,
      color: Colors.grey[400],
    );
  }

// ======================= VIDEO PLAYER METHOD =======================
  void _playVideo(BuildContext context, File videoFile) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => VideoPlayerDialog(videoFile: videoFile),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,

      /// 🔥 CURSOR COLOR
      cursorColor: AppColors.kPrimary,
      cursorWidth: 2,
      cursorRadius: const Radius.circular(2),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.kPrimary, width: 1.4),
        ),
      ),
    );
  }

// ======================= MEDIA BUTTON =======================
  Widget _mediaButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 18,
        color: isDisabled ? Colors.grey : AppColors.kPrimary,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isDisabled ? Colors.grey : AppColors.kPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.kPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

// review get
  void _showProductReviews(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewsBottomSheet(),
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
  const ReviewsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          /// HEADER
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.reviews, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  "Product Reviews",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          /// BODY
          Expanded(
            child: Consumer<ReviewProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CustomLoader());
                }

                final model = provider.reviewModel;
                if (model == null) {
                  return const Center(child: Text("No data"));
                }

                final summary = model.data.ratingSummary;
                final reviews = model.data.reviews;

                if (reviews.isEmpty) {
                  return const Center(child: Text("No Reviews Yet"));
                }

                return Column(
                  children: [
                    /// ⭐ SUMMARY
                    _ReviewSummary(summary),

                    /// LIST
                    Expanded(
                      child: ListView.builder(
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          return ReviewItemWidget(review: reviews[index]);
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

class _ReviewSummary extends StatelessWidget {
  final RatingSummary summary;

  const _ReviewSummary(this.summary);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT AVG
          Column(
            children: [
              Text(
                summary.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              Text(
                "${summary.totalReviews} Reviews",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(width: 20),

          /// RIGHT STAR COUNTS
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                final count = summary.starCounts[star.toString()] ?? 0;

                return Row(
                  children: [
                    Text("$star ★"),
                    const SizedBox(width: 6),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: summary.totalReviews == 0
                            ? 0
                            : count / summary.totalReviews,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.green,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(count.toString()),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewItemWidget extends StatelessWidget {
  final Review review;

  const ReviewItemWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER (User + Rating)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  review.user.name.isNotEmpty
                      ? review.user.name[0].toUpperCase()
                      : "?",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),

              const SizedBox(width: 10),

              /// Name + Stars
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          Icons.star,
                          size: 14,
                          color: i < review.rating
                              ? Colors.orange
                              : Colors.grey.shade300,
                        );
                      }),
                    ),
                  ],
                ),
              ),

              /// Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${review.rating}/5",
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                ),
              ),
            ],
          ),

          /// TITLE
          if (review.title.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          // context
          if (review.content.isNotEmpty) ...[
            const SizedBox(height: 6),
            ReadMoreText(
              review.content,
              trimLines: 2,
              trimMode: TrimMode.Line,
              trimCollapsedText: ' Show more',
              trimExpandedText: ' Show less',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
              moreStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
              lessStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ],
          //media
          if (review.media.images.isNotEmpty ||
              review.media.videos.isNotEmpty) ...[
            const SizedBox(height: 10),
            ReviewMediaHorizontal(
              images: review.media.images,
              videos: review.media.videos,
            ),
          ],
        ],
      ),
    );
  }
}

class ReviewMediaHorizontal extends StatelessWidget {
  final List<String> images;
  final List<String> videos;

  const ReviewMediaHorizontal({
    super.key,
    required this.images,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    final mediaCount = images.length + videos.length;
    if (mediaCount == 0) return const SizedBox();

    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          /// Images
          ...images.map(
            (img) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageViewer(
                        images: images,
                        initialIndex: images.indexOf(img),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    img,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          /// Videos
          ...videos.map(
            (videoUrl) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: VideoThumbnailTile(videoUrl: videoUrl),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoThumbnailTile extends StatefulWidget {
  final String videoUrl;

  const VideoThumbnailTile({super.key, required this.videoUrl});

  @override
  State<VideoThumbnailTile> createState() => _VideoThumbnailTileState();
}

class _VideoThumbnailTileState extends State<VideoThumbnailTile> {
  File? _thumbnail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    try {
      final tempDir = await getTemporaryDirectory();

      final thumbPath = await VideoThumbnail.thumbnailFile(
        video: widget.videoUrl, // ✅ NETWORK URL
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
      );

      if (thumbPath != null) {
        setState(() {
          _thumbnail = File(thumbPath);
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Thumbnail error: $e');
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenVideoPlayer(videoUrl: widget.videoUrl),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.black12,
              child: _loading
                  ? const Center(
                      child: CustomLoader(),
                    )
                  : _thumbnail != null
                      ? Image.file(
                          _thumbnail!,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        )
                      : const Icon(
                          Icons.videocam,
                          size: 40,
                          color: Colors.black45,
                        ),
            ),
          ),

          /// ▶ Play Icon Overlay
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black54,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
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

import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:elfinic_commerce_llc/providers/product_provider.dart';
import 'package:elfinic_commerce_llc/screens/NotificationsScreen.dart';
import 'package:elfinic_commerce_llc/screens/serch_bar.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/CategoriesResponse.dart';
import '../model/ProductsResponse.dart';
import '../providers/BannerProvider.dart';
import '../providers/ConnectivityProvider.dart';
import '../providers/SubCategoryProvider.dart';
import '../providers/category_provider.dart';
import '../services/api_service.dart';

import '../utils/lottie_overlay.dart';
import '../utils/product_list_shimmer.dart';
import 'CartScreen.dart';
import 'CategoriesScreen.dart';
import 'ProductDetailPage.dart';

// home_screen.dart

import 'SubCategoriesScreen.dart';
import 'category_list.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Import your custom classes and providers
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isVideoInitialized = false;
  bool _showPlayButton = false;
  int _currentBannerIndex = 0; // Add this line

  final List<String> banners = [
    "assets/images/banner1.png",
    "assets/images/banner1.png",
  ];

  // Add these for better performance
  final _scrollController = ScrollController();
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _precacheImages();

      // Fetch banners from API
      Provider.of<BannerProvider>(context, listen: false).fetchBanners();

    });
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset("assets/videos/")
        ..setLooping(true)
        ..setVolume(1.0)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
            // Start playing automatically
            _controller.play();
            _isPlaying = true;
          }
        });

      // Add error listener
      _controller.addListener(_videoListener);
    } catch (e) {
      print("Video initialization error: $e");
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _videoListener() {
    if (!mounted) return;

    // Only update state if necessary to avoid unnecessary rebuilds
    final isPlaying = _controller.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
    }
  }

  void _loadInitialData() {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    // Load data in background
    Future.microtask(() {
      categoryProvider.fetchCategories();
      productProvider.fetchProducts();
    });
  }

  void _precacheImages() {
    // Precaching in background
    Future.microtask(() {
      for (final banner in banners) {
        precacheImage(AssetImage(banner), context);
      }
      precacheImage(const AssetImage("assets/images/home_img.png"), context);
      precacheImage(
          const AssetImage("assets/images/splash_screen_1.png"), context);
      precacheImage(
          const AssetImage("assets/images/no_product_img2.png"), context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheNetworkImages();
  }

  void _precacheNetworkImages() {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    Future.microtask(() {
      // Precache category images
      for (final category in categoryProvider.categories.take(6)) {
        final imageUrl =
            "${ApiService.baseUrl}/assets/img/category-images/${category.image}";
        precacheImage(NetworkImage(imageUrl), context);
      }

      // Precache product images
      for (final product in productProvider.products.take(10)) {
        if (product.images.isNotEmpty) {
          final imageUrl =
              "${ApiService.baseUrl}/assets/img/products-images/${product.images.first}";
          precacheImage(NetworkImage(imageUrl), context);
        }
      }
    });
  }

  double _calculateFinalPrice(Product product) {
    final double price = product.price ?? 0.0;
    final double discount = product.discountPrice ?? 0.0;

    if (price > 0 && discount > 0) {
      return price - discount;
    }
    return price;
  }

  bool _shouldShowDiscount(Product product) {
    final double price = product.price ?? 0.0;
    final double discount = product.discountPrice ?? 0.0;

    return price > 0 && discount > 0 && discount < price;
  }


  @override
  void dispose() {
    _scrollController.dispose();
    _controller.removeListener(_videoListener);
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_isVideoInitialized) return;

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _showControlsTemporarily() {
    if (!_isVideoInitialized) return;

    setState(() {
      _showPlayButton = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() {
          _showPlayButton = false;
        });
      }
    });
  }

  void _onCategoryTap(int categoryId, String categoryName) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChangeNotifierProvider(
          create: (_) => SubCategoryProvider(),
          child: SubCategoriesScreen(
            categoryId: categoryId,
            categoryName: categoryName,
          ),
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

  void _onProductTap(Product product) {
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LottieOverlay(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              // Top Bar
              SliverToBoxAdapter(child: _buildTopBar()),

              // Categories Section
              SliverToBoxAdapter(child: _buildCategoriesSection()),

              // Banner Carousel
              SliverToBoxAdapter(child: _buildBannerCarousel()),

              // Recently Viewed
              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  "Recently Viewed",
                  const HomeCategoriesScreen(),
                ),
              ),
              SliverToBoxAdapter(
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    return _buildProductList(productProvider.products);
                  },
                ),
              ),

              // Explore Fresh Styles
              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  "Explore fresh styles",
                  const HomeCategoriesScreen(),
                ),
              ),
              SliverToBoxAdapter(
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    return _buildProductList(productProvider.products);
                  },
                ),
              ),

              // Video Ad Section
              SliverToBoxAdapter(child: _buildVideoSection()),

              // Flash Deals
              SliverToBoxAdapter(child: _buildFlashDealsHeader()),
              SliverToBoxAdapter(
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    return _buildProductList(productProvider.products);
                  },
                ),
              ),

              // Explore More
              SliverToBoxAdapter(child: _buildExploreMore()),

              // Bottom Banner
              SliverToBoxAdapter(child: _buildBottomBanner()),

              // Add some bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            // Logo with shadow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: Image.asset(
                "assets/images/splash_screen_1.png",
                height: 40,
                cacheWidth: 80,
                filterQuality: FilterQuality.low,
              ),
            ),

            const SizedBox(width: 10),

            // Search Bar
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SerchBarScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, size: 22, color: Colors.black54),
                      SizedBox(width: 8),
                      Text(
                        "Search...",
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 15),

            // Share Icon
            IconButton(
              icon: const Icon(Icons.share, size: 28, color: Colors.black87),
              onPressed: () {
                print("Share clicked");
              },
            ),

            // Notifications Icon
            IconButton(
              icon: const Icon(Icons.notification_add_outlined,
                  size: 28, color: Colors.black87),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const NotificationsScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        return SizedBox(
          height: 80,
          child: categoryProvider.isLoading
              ? const CustomShimmer(type: ShimmerType.category)
              : categoryProvider.error != null
                  ? Center(child: Text(categoryProvider.error!))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: categoryProvider.categories.length > 5
                          ? 6
                          : categoryProvider.categories.length,
                      itemBuilder: (context, index) {
                        if (categoryProvider.categories.length > 5 &&
                            index == 5) {
                          return _buildViewAllCategoryButton();
                        }
                        final cat = categoryProvider.categories[index];
                        final imageUrl =
                            "${ApiService.baseUrl}/assets/img/category-images/${cat.image}";
                        return _buildCategory(cat.name, imageUrl, cat.id);
                      },
                    ),
        );
      },
    );
  }

  Widget _buildViewAllCategoryButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeCategoriesScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Color(0xFF050040), width: 1),
              ),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Color(0xFFD39841), // #D39841
                      Color(0xFFD39841), // #050040
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.grid_view_rounded,
                  size: 24,
                  color: Colors.white, // This color will be replaced by the gradient
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "View All",
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF050040),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String title, String imgUrl, int categoryId) {
    return GestureDetector(
      onTap: () => _onCategoryTap(categoryId, title),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD39841), width: 0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: imgUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 300),
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    "assets/images/no_product_img2.png",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    cacheWidth: 100,
                    filterQuality: FilterQuality.low,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Consumer<BannerProvider>(
      builder: (context, bannerProvider, child) {
        if (bannerProvider.isLoading) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (bannerProvider.error != null) {
          return Center(child: Text(bannerProvider.error!));
        }

        if (bannerProvider.banners.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(child: Text("No banners available")),
          );
        }

        final banner = bannerProvider.banners.first;
        final images = banner.images;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: SizedBox(
            height: 180,
            child: Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: MediaQuery.of(context).size.width * 0.45, // dynamic height
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    autoPlayInterval: const Duration(seconds: 4),
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentBannerIndex = index;
                      });
                    },
                  ),
                  items: images.map((img) {
                    final imageUrl =
                        "${ApiService.baseUrl}/assets/img/banners/$img";
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.fill,
                          width: double.infinity,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Indicator
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: images.asMap().entries.map((entry) {
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentBannerIndex == entry.key
                              ? Colors.white
                              : Colors.grey,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, Widget navigateTo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      navigateTo,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Text(
              "View All",
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF160042),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return SizedBox(
        height: 250,
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF050040).withOpacity(0.05),
                  Color(0xFFD39841).withOpacity(0.05)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFD39841).withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 48, color: Color(0xFFD39841)),
                SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Color(0xFFD39841), Color(0xFF050040)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: Text(
                    "No Products Available",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Check back later for new arrivals",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductItem(product);
        },
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Debug logging
    print('Product: ${product.name}');
    print('Images: ${product.images}');
    print('Product Thumb: ${product.productThumb}');

    String? imageUrl;
    if (product.images.isNotEmpty && product.images.first.isNotEmpty) {
      imageUrl = "${ApiService.baseUrl}/assets/img/products-images/${product.images.first}";
      print('Using image URL: $imageUrl');
    } else if (product.productThumb != null && product.productThumb!.isNotEmpty) {
      imageUrl = "${ApiService.baseUrl}/assets/img/products-images/${product.productThumb}";
      print('Using thumb URL: $imageUrl');
    } else {
      print('No image available, using fallback');
    }
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => _onProductTap(product),
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
              Stack(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                        placeholder: (context, url) => _buildImagePlaceholder(),
                        errorWidget: (context, url, error) => _buildErrorImage(),
                      )
                          : _buildErrorImage(),
                    ),
                  ),
                ],
              ),
              // ... rest of your product item code
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
                    // Price Row
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
                          const SizedBox(width: 5),
                        ],
                        Text(
                          "₹${_calculateFinalPrice(product).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Rating Row
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text("${product.averageRating} (${product.ratingCount} )"),
                        // Text("${product.averageRating} (${product.ratingCount} Ratings)"),
                        const Spacer(),

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

// Helper methods for image states
  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
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
  Widget _buildVideoSection() {
    return GestureDetector(
      onTap: _showControlsTemporarily,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        width: double.infinity,
        height: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isVideoInitialized)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            else
              _buildFallbackImage(),
            if (_isVideoInitialized && _showPlayButton)
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        "assets/images/cat1.png",
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
      ),
    );
  }

  Widget _buildFlashDealsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Flash Deals",
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.indigo),
              const SizedBox(width: 5),
              CountdownTimer(
                endTime:
                    DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 60 * 12,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExploreMore() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          "Explore more",
          style: GoogleFonts.roboto(
            fontSize: 28, // adjust as per design
            fontWeight: FontWeight.w400,
            color: const Color(0xFF2A2A72), // bluish shade from your screenshot
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBottomBanner() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                "assets/images/home_img.png",
                width: 160,
                height: 200,
                fit: BoxFit.cover,
                cacheHeight: 400,
                cacheWidth: 320,
                filterQuality: FilterQuality.low,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    "Start Your Online\nBusiness & Grow with\nLimitless Opportunities",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    minFontSize: 12,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Connect Now",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



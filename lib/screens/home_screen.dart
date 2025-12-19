import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:elfinic_commerce_llc/providers/product_provider.dart';
import 'package:elfinic_commerce_llc/screens/NotificationsScreen.dart';
import 'package:elfinic_commerce_llc/screens/serch_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
// import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/CategoriesResponse.dart';
import '../model/ProductsResponse.dart';
import '../providers/ArrivalProductProvider.dart';
import '../providers/BannerProvider.dart';
import '../providers/ConnectivityProvider.dart';
import '../providers/RecentViewProvider.dart';
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

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
  int _currentBannerIndex = 0;

  final List<String> banners = [
    "assets/images/banner1.png",
    "assets/images/banner1.png",
  ];

  final _scrollController = ScrollController();
  bool _isScrolling = false;
  final _recentScrollController = ScrollController();
  final int userId = 15;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _precacheImages();

      Provider.of<BannerProvider>(context, listen: false)
          .fetchBanners(type: 'slider');
      Provider.of<RecentViewProvider>(context, listen: false).getRecentViews();
      Provider.of<ArrivalProductProvider>(context, listen: false)
          .fetchArrivalProducts();
    });

    _recentScrollController.addListener(_onRecentScroll);
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
            _controller.play();
            _isPlaying = true;
          }
        });

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

    Future.microtask(() {
      categoryProvider.fetchCategories();
      productProvider.fetchProducts();
    });
  }

  void _precacheImages() {
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
      for (final category in categoryProvider.categories.take(6)) {
        final imageUrl =
            "${ApiService.baseUrl}/assets/img/category-images/${category.image}";
        precacheImage(NetworkImage(imageUrl), context);
      }

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
    _recentScrollController.removeListener(_onRecentScroll);
    _recentScrollController.dispose();
    _controller.removeListener(_videoListener);
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  void _onRecentScroll() {
    final thresholdPixels = 150.0;

    if (!_recentScrollController.hasClients) return;

    final maxScroll = _recentScrollController.position.maxScrollExtent;
    final current = _recentScrollController.position.pixels;

    if (current + thresholdPixels >= maxScroll) {
      final provider = Provider.of<RecentViewProvider>(context, listen: false);
      if (provider.hasMore) {
        provider.loadMoreRecentViews();
      }
    }
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
    if (kDebugMode) {
      print('📱 Product tapped: ${product.name} (ID: ${product.id})');
    }

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

  Future<void> _addToRecentViews(int productId) async {
    if (kDebugMode) {
      print('🔄 Adding to recent views: $productId');
    }

    try {
      await Provider.of<RecentViewProvider>(context, listen: false)
          .addRecentView(productId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in _addToRecentViews: $e');
      }
    }
  }

  String _calculateDiscountPercentage(Product product) {
    final double price = product.price ?? 0.0;
    final double discount = product.discountPrice ?? 0.0;

    if (price > 0 && discount > 0 && discount < price) {
      final percentage = ((discount / price) * 100).round();
      return "$percentage% OFF";
    }
    return "";
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
              SliverToBoxAdapter(child: _buildTopBar()),
              SliverToBoxAdapter(child: _buildCategoriesSection()),
              SliverToBoxAdapter(child: _buildBannerCarousel()),
              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  "Product",
                  const HomeCategoriesScreen(),
                ),
              ),
              SliverToBoxAdapter(
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    return ProductListWidget(
                      products: productProvider.products,
                      isLoading: productProvider.isLoading,
                      onProductTap: _onProductTap,
                      onLoadMore: () {
                        productProvider.loadNextPage();
                      },
                      scrollDirection: Axis.horizontal,
                      height: 340,
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: _buildRecentlyViewedSection(),
              ),
              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  "Explore fresh styles",
                  const HomeCategoriesScreen(),
                ),
              ),
              SliverToBoxAdapter(
                child: Consumer<ArrivalProductProvider>(
                  builder: (context, arrivalProvider, child) {
                    if (arrivalProvider.isLoading) {
                      return SizedBox(
                        height: 250,
                        child: _buildProductGridShimmer(count: 2),
                      );
                    }

                    if (arrivalProvider.arrivalProducts.isEmpty) {
                      return const SizedBox(
                        height: 340,
                        child: Center(child: Text("No new arrivals found")),
                      );
                    }

                    return ProductListWidget(
                      products: arrivalProvider.arrivalProducts,
                      isLoading: arrivalProvider.isLoadingMore,
                      onProductTap: _onProductTap,
                      onLoadMore: () {
                        arrivalProvider.loadMoreArrivalProducts();
                      },
                      scrollDirection: Axis.horizontal,
                      height: 340,
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(child: _buildFlashDealsHeader()),
              SliverToBoxAdapter(
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    return ProductListWidget(
                      products: productProvider.products,
                      isLoading: productProvider.isLoading,
                      onProductTap: _onProductTap,
                      onLoadMore: () {
                        productProvider.loadNextPage();
                      },
                      scrollDirection: Axis.horizontal,
                      height: 340,
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(child: _buildExploreMore()),
              SliverToBoxAdapter(child: _buildBottomBanner()),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyViewedSection() {
    return Consumer<RecentViewProvider>(
      builder: (context, recentViewProvider, child) {
        if (recentViewProvider.isLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 150,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 60,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 340,
                  child: _buildProductGridShimmer(count: 3),
                ),
              ],
            ),
          );
        }

        if (recentViewProvider.error != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                children: [
                  Text(
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
          children: [
            _buildSectionTitle(
              "Recently Viewed",
              const HomeCategoriesScreen(),
            ),
            _buildRecentViewList(recentViewProvider.recentViews),
          ],
        );
      },
    );
  }

  Widget _buildRecentViewList(List<Product> recentViews) {
    return SizedBox(
      height: 340,
      child: ListView.builder(
        controller: _recentScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: recentViews.length,
        itemBuilder: (context, index) {
          return _buildRecentViewProductItem(recentViews[index]);
        },
      ),
    );
  }

  Widget _buildRecentViewProductItem(Product product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * 0.44;

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
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ProductDetailScreen(product: product),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        width: itemWidth,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration( border: Border.all(color: Colors.black12),
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
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
                      padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
    );
  }

  Widget _buildTopBar() {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
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
            IconButton(
              icon:
              const Icon(Icons.share, size: 28, color: Colors.black87),
              onPressed: () {
                print("Share clicked");
              },
            ),
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
              ? _buildCategoryShimmer()
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

  Widget _buildCategoryShimmer() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          width: 80,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 60,
                  height: 12,
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
                border: Border.all(color: const Color(0xFF050040), width: 1),
              ),
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                      Color(0xFFD39841),
                      Color(0xFFD39841),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.grid_view_rounded,
                  size: 24,
                  color: Colors.white,
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
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
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
          return SizedBox(
            height: 180,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
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
                    height: MediaQuery.of(context).size.width * 0.45,
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
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.fill,
                          width: double.infinity,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    );
                  }).toList(),
                ),
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
                color: const Color(0xFF160042),
              ),
            ),
          ),
        ],
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

  Widget _buildProductGridShimmer({int count = 3}) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: count,
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
            fontSize: 28,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF2A2A72),
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

class ProductListWidget extends StatefulWidget {
  final List<Product> products;
  final bool isLoading;
  final Function(Product) onProductTap;
  final Axis scrollDirection;
  final double height;
  final VoidCallback? onLoadMore;

  const ProductListWidget({
    Key? key,
    required this.products,
    required this.isLoading,
    required this.onProductTap,
    this.scrollDirection = Axis.horizontal,
    this.height = 250,
    this.onLoadMore,
  }) : super(key: key);

  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    if (widget.scrollDirection == Axis.horizontal) {
      _scrollController.addListener(_onScroll);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 120) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || widget.onLoadMore == null) return;

    setState(() => _isLoadingMore = true);
    widget.onLoadMore!();
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _isLoadingMore = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _finalPrice(Product product) {
    final price = product.price ?? 0;
    final discount = product.discountPrice ?? 0;
    return (price > 0 && discount > 0) ? price - discount : price;
  }

  bool _showDiscount(Product product) {
    final price = product.price ?? 0;
    final discount = product.discountPrice ?? 0;
    return price > 0 && discount > 0 && discount < price;
  }

  String _discountText(Product product) {
    if (!_showDiscount(product)) return "";
    final percent = ((product.discountPrice! / product.price!) * 100).round();
    return "$percent% OFF";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.products.isEmpty) {
      return _buildShimmerList(context);
    }

    return SizedBox(
      height: widget.scrollDirection == Axis.horizontal ? widget.height : null,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: widget.products.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.products.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }
          return _buildProductCard(widget.products[index], context);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = widget.scrollDirection == Axis.horizontal
        ? screenWidth * 0.44
        : screenWidth;

    String? imageUrl;
    if (product.images.isNotEmpty) {
      imageUrl =
      "${ApiService.baseUrl}/assets/img/products-images/${product.images.first}";
    } else if (product.productThumb != null &&
        product.productThumb!.isNotEmpty) {
      imageUrl =
      "${ApiService.baseUrl}/assets/img/products-images/${product.productThumb}";
    }

    return GestureDetector(
      onTap: () => widget.onProductTap(product),
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration( border: Border.all(color: Colors.black12),
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),

        ),

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
                      placeholder: (_, __) => _imageShimmer(),
                      errorWidget: (_, __, ___) => _errorImage(),
                    )
                        : _errorImage(),
                  ),
                ),
                if (_discountText(product).isNotEmpty)
                  Positioned(
                    top: 2,
                    left: 8,
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _discountText(product),
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
                      if (_showDiscount(product)) ...[
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
                        "₹${_finalPrice(product).toStringAsFixed(0)}",
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
    );
  }

  Widget _buildShimmerList(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        scrollDirection: widget.scrollDirection,
        itemCount: 4,
        itemBuilder: (_, index) {
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
                    height: 200,
                    width: double.infinity,
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

  Widget _imageShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _errorImage() {
    return Image.asset(
      "assets/images/no_product_img2.png",
      fit: BoxFit.contain,
    );
  }
}
/*
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

  final int userId = 15;


  final _recentScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
      _precacheImages();

      // Fetch banners from API
      Provider.of<BannerProvider>(context, listen: false).fetchBanners(type:  'slider');

      // Fetch recent views - no need to pass userId
      Provider.of<RecentViewProvider>(context, listen: false).getRecentViews();

      Provider.of<ArrivalProductProvider>(context, listen: false)
          .fetchArrivalProducts();



    });


    // Attach recent views scroll listener
    _recentScrollController.addListener(_onRecentScroll);
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
    _recentScrollController.removeListener(_onRecentScroll);
    _recentScrollController.dispose();

    _controller.removeListener(_videoListener);
    _controller.pause();
    _controller.dispose();
    super.dispose();
  */
/*  _scrollController.dispose();
    _controller.removeListener(_videoListener);
    _controller.pause();
    _controller.dispose();
    super.dispose();*//*

  }
  void _onRecentScroll() {
    // small threshold so we trigger slightly before absolute end
    final thresholdPixels = 150.0;

    if (!_recentScrollController.hasClients) return;

    final maxScroll = _recentScrollController.position.maxScrollExtent;
    final current = _recentScrollController.position.pixels;

    if (current + thresholdPixels >= maxScroll) {
      // call provider to load more if available
      final provider = Provider.of<RecentViewProvider>(context, listen: false);
      if (provider.hasMore) {
        provider.loadMoreRecentViews();
      }
    }
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

// When user taps on a product
  void _onProductTap(Product product) {
    if (kDebugMode) {
      print('📱 Product tapped: ${product.name} (ID: ${product.id})');
    }

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

  Future<void> _addToRecentViews(int productId) async {
    if (kDebugMode) {
      print('🔄 Adding to recent views: $productId');
    }

    try {
      await Provider.of<RecentViewProvider>(context, listen: false)
          .addRecentView(productId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in _addToRecentViews: $e');
      }
    }
  }

  String _calculateDiscountPercentage(Product product) {
    final double price = product.price ?? 0.0;
    final double discount = product.discountPrice ?? 0.0;

    if (price > 0 && discount > 0 && discount < price) {
      final percentage = ((discount / price) * 100).round();
      return "$percentage% OFF";
    }
    return "";
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

              // Product Viewed
              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  "Product",
                  const HomeCategoriesScreen(),
                ),
              ),
              // Product Viewed Section with pagination
              SliverToBoxAdapter(
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    return ProductListWidget(
                      products: productProvider.products,
                      isLoading: productProvider.isLoading,
                      onProductTap: _onProductTap,
                      onLoadMore: () {
                        // This will be called when user scrolls horizontally to the end
                        productProvider.loadNextPage();
                      },
                      scrollDirection: Axis.horizontal,
                      height: 340,
                    );
                  },
                ),
              ),

              // Recently Viewed Section
              SliverToBoxAdapter(
                child: _buildRecentlyViewedSection(),
              ),

              // Explore Fresh Styles
              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  "Explore fresh styles",
                  const HomeCategoriesScreen(),
                ),
              ),
              // Explore Fresh Styles with pagination
              SliverToBoxAdapter(
                child: Consumer<ArrivalProductProvider>(
                  builder: (context, arrivalProvider, child) {
                    if (arrivalProvider.isLoading) {
                      return const SizedBox(
                        height: 250,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (arrivalProvider.arrivalProducts.isEmpty) {
                      return const SizedBox(
                        height: 340,
                        child: Center(child: Text("No new arrivals found")),
                      );
                    }

                    return ProductListWidget(
                      products: arrivalProvider.arrivalProducts,
                      isLoading: arrivalProvider.isLoadingMore,
                      onProductTap: _onProductTap,
                      onLoadMore: () {
                        arrivalProvider.loadMoreArrivalProducts();
                      },
                      scrollDirection: Axis.horizontal,
                      height: 340,
                    );
                  },
                ),
              ),



              /// Video Ad Section
              // SliverToBoxAdapter(child: _buildVideoSection()),

              // Flash Deals
              SliverToBoxAdapter(child: _buildFlashDealsHeader()),
              // Flash Deals with pagination
              SliverToBoxAdapter(
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    return ProductListWidget(
                      products: productProvider.products,
                      isLoading: productProvider.isLoading,
                      onProductTap: _onProductTap,
                      onLoadMore: () {
                        // This will be called when user scrolls horizontally to the end
                        productProvider.loadNextPage();
                      },
                      scrollDirection: Axis.horizontal,
                      height: 340,
                    );
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



  // Update the recently viewed section to handle logged out state
  Widget _buildRecentlyViewedSection() {
    return Consumer<RecentViewProvider>(
      builder: (context, recentViewProvider, child) {
        // Check if user is logged in
        // if (!recentViewProvider.isUserLoggedIn()) {
        //   return const SizedBox.shrink(); // Hide section if not logged in
        // }

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
                  Text(
                    'Error loading recent views',
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      recentViewProvider.getRecentViews();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (recentViewProvider.recentViews.isEmpty) {
          return const SizedBox.shrink(); // Hide section if no recent views
        }

        return Column(
          children: [
            _buildSectionTitle(
              "Recently Viewed",
              const HomeCategoriesScreen(),
            ),
            _buildRecentViewList(recentViewProvider.recentViews),
          ],
        );
      },
    );
  }
  Widget _buildRecentViewList(List<Product> recentViews) {
    return SizedBox(
      height: 340, // ✅ Nykaa spacing
      child: ListView.builder(
        controller: _recentScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: recentViews.length,
        itemBuilder: (context, index) {
          return _buildRecentViewProductItem(recentViews[index]);
        },
      ),
    );
  }



  Widget _buildRecentViewProductItem(Product product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * 0.44;

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
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                ProductDetailScreen(product: product),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        width: itemWidth,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE (Nykaa Man style)
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1 / 1.15,
                  child: Container(
                    // color: const Color(0xfff6f6f6),
                    padding: const EdgeInsets.all(1),
                    child: imageUrl != null
                        ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain, // ✅ FULL IMAGE
                      placeholder: (_, __) =>
                          _buildProductImageShimmer(),
                      errorWidget: (_, __, ___) =>
                          _buildErrorImage(),
                    )
                        : _buildErrorImage(),
                  ),
                ),

                /// DISCOUNT BADGE
                if (_shouldShowDiscount(product))
                  Positioned(
                    top: 8,
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

            /// DETAILS
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// NAME
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

                  /// PRICE
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

                  /// RATING
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Colors.orange),
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

// Shimmer effect for product image
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
// Shimmer effect for text
  Widget _buildTextShimmer({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
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



class ProductListWidget extends StatefulWidget {
  final List<Product> products;
  final bool isLoading;
  final Function(Product) onProductTap;
  final Axis scrollDirection;
  final double height;
  final VoidCallback? onLoadMore;

  const ProductListWidget({
    Key? key,
    required this.products,
    required this.isLoading,
    required this.onProductTap,
    this.scrollDirection = Axis.horizontal,
    this.height = 250,
    this.onLoadMore,
  }) : super(key: key);

  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    if (widget.scrollDirection == Axis.horizontal) {
      _scrollController.addListener(_onScroll);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 120) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || widget.onLoadMore == null) return;

    setState(() => _isLoadingMore = true);
    widget.onLoadMore!();
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _isLoadingMore = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ================= PRICE HELPERS =================

  double _finalPrice(Product product) {
    final price = product.price ?? 0;
    final discount = product.discountPrice ?? 0;
    return (price > 0 && discount > 0) ? price - discount : price;
  }

  bool _showDiscount(Product product) {
    final price = product.price ?? 0;
    final discount = product.discountPrice ?? 0;
    return price > 0 && discount > 0 && discount < price;
  }

  String _discountText(Product product) {
    if (!_showDiscount(product)) return "";
    final percent =
    ((product.discountPrice! / product.price!) * 100).round();
    return "$percent% OFF";
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.products.isEmpty) {
      return _buildShimmerList(context);
    }

    return SizedBox(
      height: widget.scrollDirection == Axis.horizontal ? widget.height : null,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: widget.scrollDirection,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: widget.products.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.products.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            );
          }
          return _buildProductCard(widget.products[index], context);
        },
      ),
    );
  }

  // ================= PRODUCT CARD =================

  Widget _buildProductCard(Product product, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth =
    widget.scrollDirection == Axis.horizontal ? screenWidth * 0.44 : screenWidth;

    String? imageUrl;
    if (product.images.isNotEmpty) {
      imageUrl =
      "${ApiService.baseUrl}/assets/img/products-images/${product.images.first}";
    } else if (product.productThumb != null &&
        product.productThumb!.isNotEmpty) {
      imageUrl =
      "${ApiService.baseUrl}/assets/img/products-images/${product.productThumb}";
    }

    return GestureDetector(
      onTap: () => widget.onProductTap(product),
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1 / 1.15,
                  child: Container(
                    // color: const Color(0xfff6f6f6),
                    padding: const EdgeInsets.all(1),
                    child: imageUrl != null
                        ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, __) =>
                          _imageShimmer(),
                      errorWidget: (_, __, ___) =>
                          _errorImage(),
                    )
                        : _errorImage(),
                  ),
                ),

                if (_discountText(product).isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _discountText(product),
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

            // DETAILS
            Padding(
              padding: const EdgeInsets.all(10),
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
                      if (_showDiscount(product)) ...[
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
                        "₹${_finalPrice(product).toStringAsFixed(0)}",
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
                      const Icon(Icons.star,
                          size: 14, color: Colors.orange),
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
    );
  }

  // ================= SHIMMER =================

  Widget _buildShimmerList(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        scrollDirection: widget.scrollDirection,
        itemCount: 4,
        itemBuilder: (_, __) => _imageShimmer(),
      ),
    );
  }

  Widget _imageShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 150,
        color: Colors.white,
      ),
    );
  }

  Widget _errorImage() {
    return Image.asset(
      "assets/images/no_product_img2.png",
      fit: BoxFit.contain,
    );
  }
}
*/

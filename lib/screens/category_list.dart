import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:elfinic_commerce_llc/providers/WishlistProvider.dart';
import 'package:elfinic_commerce_llc/widget/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../model/SubcategoriesResponse.dart';

import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../services/api_service.dart';

import '../providers/SubCategoryProvider.dart';

import 'ProductDetailPage.dart';

class HomeCategoriesScreen extends StatefulWidget {
  const HomeCategoriesScreen({super.key});

  @override
  HomeCategoriesScreenState createState() => HomeCategoriesScreenState();
}

class HomeCategoriesScreenState extends State<HomeCategoriesScreen> {
  int? selectedCategoryId;

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<SubCategoryProvider>(context, listen: false)
          .fetchSubcategories();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final catProvider = Provider.of<CategoryProvider>(context);
    if (!catProvider.isLoading &&
        catProvider.categories.isNotEmpty &&
        selectedCategoryId == null) {
      setState(() {
        selectedCategoryId = catProvider.categories.first.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
          child: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySidebar(),
                _buildSubcategoriesGrid(),
              ],
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          // Back Arrow
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.grey,
                size: 25,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Search Field
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search for products...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySidebar() {
    return Container(
      width: 100,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Consumer<CategoryProvider>(
        builder: (context, catProvider, child) {
          if (catProvider.isLoading) {
            return _buildLoadingIndicator();
          } else if (catProvider.error != null) {
            return _buildErrorWidget(catProvider.error!);
          } else if (catProvider.categories.isEmpty) {
            return _buildEmptyState("No categories found");
          }

          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: catProvider.categories.length,
              itemBuilder: (context, index) {
                final category = catProvider.categories[index];
                bool isSelected = selectedCategoryId == category.id;

                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategoryId = category.id;
                      });
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    Colors.orange.shade50,
                                    Colors.orange.shade100,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(
                                  color: Color(0xFFD39841),
                                  width: 2,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.orange.shade100,
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Category Image with smooth animation
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              width: isSelected ? 52 : 44,
                              height: isSelected ? 52 : 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      "${ApiService.baseUrl}/assets/img/category-images/${category.image}",
                                  fit: BoxFit.cover,

                                  // 🟡 Shimmer while loading
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      color: Colors.white,
                                    ),
                                  ),

                                  // 🔴 Error fallback
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.category,
                                      color: Colors.grey.shade400,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Category Name
                            Flexible(
                              child: AutoSizeText(
                                category.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                minFontSize: 8,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.orange.shade800
                                      : Colors.grey[700],
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubcategoriesGrid() {
    return Expanded(
      child: Consumer<SubCategoryProvider>(
        builder: (context, subProvider, child) {
          if (subProvider.isLoading) {
            return _buildLoadingIndicator();
          } else if (subProvider.error != null) {
            return _buildErrorWidget(subProvider.error!);
          }

          final filtered = subProvider.subcategories.where((sub) {
            bool matchesCategory = sub.categoryId == selectedCategoryId;
            bool matchesSearch = searchQuery.isEmpty ||
                sub.name.toLowerCase().contains(searchQuery);

            return matchesCategory && matchesSearch;
          }).toList();

          if (filtered.isEmpty) {
            return _buildEmptyState("No subcategories found");
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _calculateCrossAxisCount(context),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95, // ✅ slightly taller for text
                  ),
                  itemBuilder: (context, index) {
                    final sub = filtered[index];
                    final imageUrl =
                        "${ApiService.baseUrl}/assets/img/sub-category-images/${sub.image}";

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _onSubcategoryTap(sub),

                        /// SubcategoryDetailScreen
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ✅ Image section (square)
                            Expanded(
                              flex: 7,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  fadeInDuration:
                                      const Duration(milliseconds: 300),

                                  // ✅ Shimmer while loading
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      color: Colors.white,
                                    ),
                                  ),

                                  // ❌ Error fallback
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Colors.orange.shade50,
                                    child: const Icon(
                                      Icons.category,
                                      color: Color(0xFFD39841),
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ✅ Text section
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: AutoSizeText(
                                    sub.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    minFontSize: 10,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1000) return 4;
    if (width > 700) return 3;
    return 2;
  }

  void _onSubcategoryTap(SubCategoryModel subcategory) {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    final selectedCategory = categoryProvider.categories
        .firstWhere((c) => c.id == selectedCategoryId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductListScreen(
          categoryName: selectedCategory.name, // ✅ PASS NAME
          subcategoryName: subcategory.name, // ✅ PASS NAME (slug)
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFFD39841),
            ),
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            "Loading...",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade400,
            size: 48,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Retry logic
              Provider.of<CategoryProvider>(context, listen: false)
                  .fetchCategories();
              Provider.of<SubCategoryProvider>(context, listen: false)
                  .fetchSubcategories();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Try Again"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration or Icon
            Icon(
              Icons.shopping_bag_outlined,
              color: Colors.grey[400],
              size: 80,
            ),

            const SizedBox(height: 20),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            // Optional suggestion text
            Text(
              "Try exploring other categories.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  final String categoryName;
  final String subcategoryName;

  const ProductListScreen({
    super.key,
    required this.categoryName,
    required this.subcategoryName,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchFilteredProducts(
            categoryName: widget.categoryName,
            subcategoryName: widget.subcategoryName,
            reset: true,
          );
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        context.read<ProductProvider>().fetchFilteredProducts(
              categoryName: widget.categoryName,
              subcategoryName: widget.subcategoryName,
            );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ),
        title: Text(
          widget.subcategoryName,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.products.isEmpty) {
            return const Center(child: CustomLoader());
          }

          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/image.png',
                    height: 140,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "No products found",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.70, // 🔥 taller card
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.products.length) {
                return const Center(child: CustomLoader());
              }

              final product = provider.products[index];

              return InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => ProductDetailScreen(
                        product: product,
                        slug: product.slug!,
                      ),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🖼 IMAGE
                      AspectRatio(
                        aspectRatio: 1 / 1,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl:
                                    "${product.imagePath}${product.images.isNotEmpty ? product.images.first : product.productThumb}",
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                memCacheWidth: 300,
                                memCacheHeight: 200,
                                maxWidthDiskCache: 300,
                                maxHeightDiskCache: 200,
                                placeholder: (_, __) => const ImageShimmer(),
                                errorWidget: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),

                              /// ❤️ Wishlist
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Consumer<WishlistProvider>(
                                  builder: (_, wishlistProvider, __) {
                                    final isWishlisted = wishlistProvider
                                        .isInWishlist(product.id);

                                    return GestureDetector(
                                      onTap: () async {
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        final userId = int.tryParse(
                                                prefs.getString('user_id') ??
                                                    '0') ??
                                            0;
                                        if (userId == 0) return;
                                        await wishlistProvider
                                            .toggleWishlist(product.id);
                                      },
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          isWishlisted
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isWishlisted
                                              ? Colors.red
                                              : Colors.grey,
                                          size: 18,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// 📄 DETAILS (FIXED)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
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
                                const Icon(Icons.star,
                                    size: 14, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(
                                  "${product.averageRating} (${product.ratingCount})",
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                            // const Spacer(),
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
                                    color: Colors.green,
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
            },
          );
        },
      ),
    );
  }
}

class ImageShimmer extends StatelessWidget {
  const ImageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        color: Colors.white,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/SubCategoryProvider.dart';
import '../services/api_service.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../utils/ShimmerCategoryCard.dart';
import 'category_list.dart';

class SubCategoriesScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const SubCategoriesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SubCategoryProvider>(context, listen: false);
      provider.fetchSubcategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
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
          widget.categoryName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<SubCategoryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: 8,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) => const ShimmerCategoryCard(),
              );
            } else if (provider.error != null) {
              return Center(child: Text(provider.error!));
            } else {
              final filtered = provider.subcategories
                  .where((e) => e.categoryId == widget.categoryId)
                  .toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    "No subcategories found",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                itemCount: filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final imageUrl = ApiService.getFullImageUrl(
                      item.image, "sub-category-images");

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductListScreen(
                            categoryName:
                                widget.categoryName, // ✅ already available
                            subcategoryName: item.name, // ✅ slug / name
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 🖼️ Subcategory Image
                          Expanded(
                            child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: imageUrl.startsWith("http")
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        placeholder: (context, url) =>
                                            const ShimmerCategoryCard(),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          "assets/images/no_product_img2.png",
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      )
                                    : Image.asset(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      )),
                          ),

                          // 🏷️ Category Name
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 8),
                            child: Text(
                              item.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/SubCategoryProvider.dart';
import '../services/api_service.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../services/api_service.dart';
import '../utils/ShimmerCategoryCard.dart';

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
      provider.fetchSubcategories(); // fetch all subcategories
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<SubCategoryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              // shimmer loading grid
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) => const ShimmerCategoryCard(),
              );
            } else if (provider.error != null) {
              return Center(child: Text(provider.error!));
            } else {
              // filter subcategories by categoryId
              final filtered = provider.subcategories
                  .where((e) => e.categoryId == widget.categoryId)
                  .toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    "No subcategories found",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                );
              }

              // show actual subcategories grid
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final imageUrl = (item.image != null &&
                          item.image!.isNotEmpty)
                      ? "${ApiService.baseUrl}/assets/img/sub-category-images/${item.image}"
                      : "assets/images/no_product_img2.png";

                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
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
                                      height: double.infinity,
                                    ),
                                  )
                                : Image.asset(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              );

              /*GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final imageUrl = (item.image != null && item.image!.isNotEmpty)
                      ? "${ApiService.baseUrl}/assets/img/sub-category-images/${item.image}"
                      : "assets/images/no_product_img2.png";

                  return Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageUrl.startsWith("http")
                              ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) =>
                            const ShimmerCategoryCard(),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/images/no_product_img2.png",
                              fit: BoxFit.cover,
                            ),
                          )
                              : Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              );*/
            }
          },
        ),
      ),
    );
  }
}

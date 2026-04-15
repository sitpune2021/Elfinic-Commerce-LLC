import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/CategoriesResponse.dart';
import '../providers/SubCategoryProvider.dart';
import '../providers/category_provider.dart';
import '../services/api_service.dart';
import 'SubCategoriesScreen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ShopsScreen extends StatefulWidget {
  const ShopsScreen({super.key});

  @override
  State<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<ShopsScreen>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xfff4f6f9),

      /// PREMIUM APPBAR
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Shops",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffD39841),
                Color(0xff9C6B2C),
              ],
            ),
          ),
        ),
      ),

      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categories.isEmpty) {
            return const Center(child: Text("No Shops Available"));
          }

          return MasonryGridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            itemCount: provider.categories.length,

            itemBuilder: (context, index) {

              final shop = provider.categories[index];

              final imageUrl =
                  "${ApiService.baseUrl}/assets/img/category-images/${shop.image}";

              return InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  _navigateToSubcategories(context, shop);
                },

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),

                    child: Stack(
                      children: [

                        /// IMAGE
                        Hero(
                          tag: shop.id,
                          child: Image.network(
                            imageUrl,
                            height: 190,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        /// GRADIENT OVERLAY
                        Container(
                          height: 190,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(.7),
                                Colors.transparent
                              ],
                            ),
                          ),
                        ),

                        /// GLASS BADGE
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.25),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(.4),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.store,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Shop",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                        /// SHOP NAME
                        Positioned(
                          bottom: 14,
                          left: 14,
                          right: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                shop.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 4),

                              const Text(
                                "Explore Shop",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
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

void _navigateToSubcategories(BuildContext context, CategoryModel category) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider(
        create: (_) => SubCategoryProvider(),
        child: SubCategoriesScreen(
          categoryId: category.id,
          categoryName: category.name,
        ),
      ),
    ),
  );
}
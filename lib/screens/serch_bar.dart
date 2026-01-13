import 'package:elfinic_commerce_llc/providers/product/product_search_provider.dart';
import 'package:elfinic_commerce_llc/widget/custom_loading.dart';
import 'package:elfinic_commerce_llc/widget/product_card.dart';
import 'package:elfinic_commerce_llc/widget/skeleton_product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SerchBarScreen extends StatefulWidget {
  const SerchBarScreen({super.key});

  @override
  State<SerchBarScreen> createState() => _SerchBarScreenState();
}

class _SerchBarScreenState extends State<SerchBarScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final provider = context.read<ProductSearchProvider>();

      debugPrint(
        "SCROLL : ${_scrollController.position.pixels} / ${_scrollController.position.maxScrollExtent}",
      );

      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 80 &&
          provider.hasMoreData &&
          !provider.isLoadMore) {
        debugPrint("SCROLL BOTTOM → LOAD MORE");
        provider.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xfffdf8f2),
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 SEARCH BAR (NO APP BAR)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: 12,
              ),
              child: Row(
                children: [
                  // // 👈 BACK BUTTON
                  // IconButton(
                  //   icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  //   onPressed: () {
                  //     Navigator.of(context).pop();
                  //   },
                  // ),
                  // const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        textAlignVertical: TextAlignVertical.center,
                        cursorColor: Colors.grey, // 🎯 cursor color
                        onChanged: (value) {
                          debugPrint("SEARCH INPUT : $value");
                          context
                              .read<ProductSearchProvider>()
                              .loadInitial(value);
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: "     Search products by Product name",
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.black87),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              const Icon(Icons.search, color: Colors.black54),
                            ],
                          ),
                          // prefixIcon:
                          //     const Icon(Icons.search, color: Colors.black54),
                          isDense: true, // 🔑 fixes vertical misalignment
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, // 🔑 centers text vertically
                            horizontal: 0,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    debugPrint("SEARCH CLEARED");
                                    _searchController.clear();
                                    context
                                        .read<ProductSearchProvider>()
                                        .loadInitial('');
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 👇 CONTENT AREA
            Expanded(
              child: Consumer<ProductSearchProvider>(
                builder: (context, provider, _) {
                  // 🟡 EMPTY STATE (NO SEARCH)
                  if (_searchController.text.trim().isEmpty) {
                    return const Center(
                      child: Text(
                        "Start typing to search products",
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  // 🔄 FIRST LOAD
                  // if (provider.isLoading) {
                  //   return const Center(
                  //     child: CustomLoader(),
                  //   );
                  // }
                  if (provider.isLoading) {
                    return GridView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.04,
                        vertical: 8,
                      ),
                      itemCount: 6,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 300,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (_, __) => const SkeletonProductCard(),
                    );
                  }

                  // ❌ NO RESULTS
                  if (provider.products.isEmpty) {
                    return const Center(
                      child: Text("No products found"),
                    );
                  }

                  // 🛍 PRODUCT GRID
                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          color: Colors.orange,
                          onRefresh: () async {
                            debugPrint("PULL TO REFRESH");
                            await context
                                .read<ProductSearchProvider>()
                                .loadInitial(_searchController.text);
                          },
                          child: GridView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.04,
                              vertical: 8,
                            ),
                            itemCount: provider.products.length +
                                (provider.isLoadMore ? 1 : 0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              // mainAxisExtent: 250,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.65,
                            ),
                            itemBuilder: (context, index) {
                              if (index == provider.products.length) {
                                return const Center(
                                  child: CustomLoader(),
                                );
                              }

                              final product = provider.products[index];

                              return ProductCard(product: product);
                            },
                          ),
                        ),
                      ),

                      // 🚫 NO MORE DATA
                      if (!provider.hasMoreData)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            "No more available data",
                            style: TextStyle(color: Colors.black45),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

enum ShimmerType { product, category }

class CustomShimmer extends StatelessWidget {
  final ShimmerType type;
  final int itemCount;

  const CustomShimmer({super.key, required this.type, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: type == ShimmerType.category ? 80 : 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: type == ShimmerType.category
                ? _buildCategoryShimmer()
                : _buildProductShimmer(context),
          );
        },
      ),
    );
  }

  Widget _buildCategoryShimmer() {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 40,
            height: 10,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildProductShimmer(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.44,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: double.infinity, height: 15, color: Colors.white),
                const SizedBox(height: 5),
                Container(width: 80, height: 10, color: Colors.white),
                const SizedBox(height: 5),
                Container(width: 40, height: 10, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

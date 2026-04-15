import 'package:flutter/material.dart';

class SkeletonProductCard extends StatelessWidget {
  const SkeletonProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          _bar(80),
          _bar(60),
          _bar(40),
        ],
      ),
    );
  }

  Widget _bar(double width) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 10,
      width: width,
      color: Colors.grey.shade300,
    );
  }
}

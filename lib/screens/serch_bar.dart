import 'package:flutter/material.dart';

import 'FiltersScreen.dart';

class SerchBarScreen extends StatefulWidget {
  const SerchBarScreen({super.key});

  @override
  State<SerchBarScreen> createState() => _SerchBarScreenState();
}

class _SerchBarScreenState extends State<SerchBarScreen> {
  List<Map<String, dynamic>> products = [
    {
      "title": "Lorem ipsum dolor sit amet consectetur.",
      "image": "assets/images/w1.png",
      "oldPrice": "₹4,148.00",
      "price": "₹2,996.50",
      "rating": "4.8",
      "isFavorite": false,
    },
    {
      "title": "Lorem ipsum dolor sit amet consectetur.",
      "image": "assets/images/w2.png",
      "oldPrice": "₹4,148.00",
      "price": "₹2,996.50",
      "rating": "4.8",
      "isFavorite": false,
    },
    {
      "title": "Lorem ipsum dolor sit amet consectetur.",
      "image": "assets/images/w3.png",
      "oldPrice": "₹4,148.00",
      "price": "₹2,996.50",
      "rating": "4.8",
      "isFavorite": false,
    },
  ];

  int _selectedIndex = 0;

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf8f2), // cream bg
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 5, spreadRadius: 1)
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, color: Colors.black54),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Women T-shirts",
                          hintStyle:
                          TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.mic_none_outlined,
                            color: Colors.black54)),
                    // IconButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const FiltersScreen(),
                    //       ),
                    //     );
                    //   },
                    //   icon: const Icon(
                    //     Icons.filter_alt_outlined,
                    //     color: Colors.black54,
                    //   ),
                    // ),
                    IconButton(
                      onPressed: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: "Filters",
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder: (context, anim1, anim2) {
                            return Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.85, // 85% width
                                child: const FiltersScreen(),
                              ),
                            );
                          },
                          transitionBuilder: (context, anim1, anim2, child) {
                            return SlideTransition(
                              position: Tween(
                                begin: const Offset(1, 0), // start offscreen right
                                end: Offset.zero,          // slide to screen
                              ).animate(anim1),
                              child: child,
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.filter_alt_outlined,
                        color: Colors.black54,
                      ),
                    ),

                  ],
                ),
              ),
            ),

            // Showing categories
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Showing categories of",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 6,
                children: [
                  Chip(
                    label: const Text("Woman"),
                    onDeleted: () {},
                    deleteIcon: const Icon(Icons.close, size: 16),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Product Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 270,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            spreadRadius: 1)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: Image.asset(
                                product["image"],
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    product["isFavorite"] =
                                    !product["isFavorite"];
                                  });
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    product["isFavorite"]
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product["title"],
                                maxLines: 2,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  Text(
                                    product["oldPrice"],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    product["price"],
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
                                  const Icon(Icons.star,
                                      size: 14, color: Colors.orangeAccent),
                                  Text(product["rating"],
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Show all results
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Show all results",
                  style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Nav Bar
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onBottomNavTap,
      //   selectedItemColor: Colors.orange.shade800,
      //   unselectedItemColor: Colors.black,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.favorite_border), label: "Wishlist"),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.menu), label: "Categories"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      //   ],
      // ),
    );
  }
}

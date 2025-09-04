import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';



import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class HomeCategoriesScreen extends StatefulWidget {
  const HomeCategoriesScreen({super.key});

  @override
  State<HomeCategoriesScreen> createState() => _HomeCategoriesScreen();
}

class _HomeCategoriesScreen extends State<HomeCategoriesScreen> {
  String selectedCategory = "Trending Now";

  // ✅ Categories list
  final List<String> categories = [
    "Trending Now",
    "Men's Wear",
    "Women's Wear",
    "Kids Wear",
    "Footwear",
    "Beauty & Grooming",
    "Home & Living",
  ];

  // ✅ Category Images Map
  final Map<String, String> categoryImages = {
    "Trending Now":
    "https://images.pexels.com/photos/2983464/pexels-photo-2983464.jpeg",
    "Men's Wear":
    "https://images.pexels.com/photos/428338/pexels-photo-428338.jpeg",
    "Women's Wear":
    "https://images.pexels.com/photos/1488463/pexels-photo-1488463.jpeg",
    "Kids Wear":
    "https://images.pexels.com/photos/3661350/pexels-photo-3661350.jpeg",
    "Footwear":
    "https://images.pexels.com/photos/267320/pexels-photo-267320.jpeg",
    "Beauty & Grooming":
    "https://images.pexels.com/photos/2534961/pexels-photo-2534961.jpeg",
    "Home & Living":
    "https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg",
  };




// Spotlight + Stores (Network Images)
  final List<Map<String, String>> spotlightItems = [
    {
      "title": "New On Myntra",
      "image": "https://images.pexels.com/photos/2983464/pexels-photo-2983464.jpeg"
    },
    {
      "title": "Monsoon Magic",
      "image": "https://images.pexels.com/photos/325185/pexels-photo-325185.jpeg"
    },
    {
      "title": "The Edit",
      "image": "https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg"
    },
    {
      "title": "Trendnxt",
      "image": "https://images.pexels.com/photos/2983465/pexels-photo-2983465.jpeg"
    },
    {
      "title": "Autumn Winter",
      "image": "https://images.pexels.com/photos/325208/pexels-photo-325208.jpeg"
    },
    {
      "title": "Ganesh Chaturthi Store",
      "image": "https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg"
    },
    {
      "title": "Onam Store",
      "image": "https://images.pexels.com/photos/172292/pexels-photo-172292.jpeg"
    },
    {
      "title": "The Pujo Store",
      "image": "https://images.pexels.com/photos/1166869/pexels-photo-1166869.jpeg"
    },
    {
      "title": "Navratri Store",
      "image": "https://images.pexels.com/photos/1166869/pexels-photo-1166869.jpeg"
    },
    {
      "title": "New On Myntra",
      "image": "https://images.pexels.com/photos/2983464/pexels-photo-2983464.jpeg"
    },
    {
      "title": "Monsoon Magic",
      "image": "https://images.pexels.com/photos/325185/pexels-photo-325185.jpeg"
    },
    {
      "title": "The Edit",
      "image": "https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg"
    },
    {
      "title": "Trendnxt",
      "image": "https://images.pexels.com/photos/2983465/pexels-photo-2983465.jpeg"
    },
    {
      "title": "Autumn Winter",
      "image": "https://images.pexels.com/photos/325208/pexels-photo-325208.jpeg"
    },
    {
      "title": "Ganesh Chaturthi Store",
      "image": "https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg"
    },
    {
      "title": "Onam Store",
      "image": "https://images.pexels.com/photos/172292/pexels-photo-172292.jpeg"
    },
    {
      "title": "The Pujo Store",
      "image": "https://images.pexels.com/photos/1166869/pexels-photo-1166869.jpeg"
    },
    {
      "title": "Navratri Store",
      "image": "https://images.pexels.com/photos/1166869/pexels-photo-1166869.jpeg"
    },
  ];

  final List<Map<String, String>> trendingStores = [
    {
      "title": "Myntra Unique",
      "image": "https://images.pexels.com/photos/2983463/pexels-photo-2983463.jpeg"
    },
    {
      "title": "Rising Stars",
      "image": "https://images.pexels.com/photos/3762928/pexels-photo-3762928.jpeg"
    },
    {
      "title": "Luxe",
      "image": "https://images.pexels.com/photos/291762/pexels-photo-291762.jpeg"
    },
    {
      "title": "Picture",
      "image": "https://images.pexels.com/photos/428340/pexels-photo-428340.jpeg"
    },
    {
      "title": "Rising Stars Beauty",
      "image": "https://images.pexels.com/photos/2534961/pexels-photo-2534961.jpeg"
    },
    {
      "title": "FWD",
      "image": "https://images.pexels.com/photos/994517/pexels-photo-994517.jpeg"
    },
  ];

// Category-wise items
  final Map<String, List<Map<String, String>>> categoryItems = {
    "Men's Wear": [
      {
        "title": "T-Shirts",
        "image": "https://images.pexels.com/photos/428338/pexels-photo-428338.jpeg"
      },
      {
        "title": "Shirts",
        "image": "https://images.pexels.com/photos/2983464/pexels-photo-2983464.jpeg"
      },
      {
        "title": "Jeans",
        "image": "https://images.pexels.com/photos/298863/pexels-photo-298863.jpeg"
      },
      {
        "title": "Jackets",
        "image": "https://images.pexels.com/photos/1488463/pexels-photo-1488463.jpeg"
      },
    ],
    "Women's Wear": [
      {
        "title": "Saree",
        "image": "https://images.pexels.com/photos/1488463/pexels-photo-1488463.jpeg"
      },
      {
        "title": "Dresses",
        "image": "https://images.pexels.com/photos/5704845/pexels-photo-5704845.jpeg"
      },
      {
        "title": "Kurtis",
        "image": "https://images.pexels.com/photos/994517/pexels-photo-994517.jpeg"
      },
      {
        "title": "Tops",
        "image": "https://images.pexels.com/photos/1866149/pexels-photo-1866149.jpeg"
      },
    ],
    "Kids Wear": [
      {
        "title": "T-Shirts",
        "image": "https://images.pexels.com/photos/3661350/pexels-photo-3661350.jpeg"
      },
      {
        "title": "Shorts",
        "image": "https://images.pexels.com/photos/1449791/pexels-photo-1449791.jpeg"
      },
      {
        "title": "Frocks",
        "image": "https://images.pexels.com/photos/1449791/pexels-photo-1449791.jpeg"
      },
    ],
    "Footwear": [
      {
        "title": "Heels",
        "image": "https://images.pexels.com/photos/267202/pexels-photo-267202.jpeg"
      },
      {
        "title": "Shoes",
        "image": "https://images.pexels.com/photos/267320/pexels-photo-267320.jpeg"
      },
      {
        "title": "Sandals",
        "image": "https://images.pexels.com/photos/292999/pexels-photo-292999.jpeg"
      },
    ],
    "Beauty & Grooming": [
      {
        "title": "Lipstick",
        "image": "https://images.pexels.com/photos/2534961/pexels-photo-2534961.jpeg"
      },
      {
        "title": "Perfume",
        "image": "https://images.pexels.com/photos/965989/pexels-photo-965989.jpeg"
      },
      {
        "title": "Shaving Kit",
        "image": "https://images.pexels.com/photos/191841/pexels-photo-191841.jpeg"
      },
    ],
    "Home & Living": [
      {
        "title": "Furniture",
        "image": "https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg"
      },
      {
        "title": "Decor",
        "image": "https://images.pexels.com/photos/271816/pexels-photo-271816.jpeg"
      },
      {
        "title": "Kitchen",
        "image": "https://images.pexels.com/photos/2763894/pexels-photo-2763894.jpeg"
      },
    ],
  };


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      // backgroundColor: const Color(0xfffdf6ef),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Categories",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [
          Icon(Icons.favorite_border, color: Colors.black),
          SizedBox(width: 12),
          Icon(Icons.shopping_bag_outlined, color: Colors.black),
          SizedBox(width: 12),
        ],
      ),

      body: Row(
        children: [

          Container(
            width: 100,
            margin: const EdgeInsets.only(left: 8), // 🔹 Left margin
            decoration: BoxDecoration(
              color:  Colors.white, // 🔹 Light orange background
              // color: const Color(0xFFFFF3E0), // 🔹 Light orange background
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                String category = categories[index];
                bool isSelected = selectedCategory == category;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child:
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange.shade100 : Colors.transparent,

                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ?  Border(
                        left: BorderSide(
                          color: Colors.orange.shade800, // 🔹 Left strip color
                          width: 4, // 🔹 Strip width
                        ),
                      )
                          : null,
                      boxShadow: isSelected
                          ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                          : [],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: isSelected ? 30 : 25, // 🔹 Zoom effect
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            categoryImages[category]!,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          category,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w700,
                            color: isSelected ? Colors.orange.shade800 : Colors.black87, // 🔹 Highlight color
                          ),
                        ),

                      ],
                    ),
                  )
                  ,
                );
              },
            ),
          ),

          // Right Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 1.0,right: 1,bottom: 1),
              child: selectedCategory == "Trending Now"
                  ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Spotlight
                    const Text("In The Spotlight",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: spotlightItems.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final item = spotlightItems[index];
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage:
                              NetworkImage(item["image"]!),
                            ),
                            const SizedBox(height: 6),

                            AutoSizeText(
                              item["title"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w600),
                              maxLines: 1,         // keeps it in one line
                              minFontSize: 8,      // smallest font it can shrink to
                              overflow: TextOverflow.ellipsis, // adds "..." if too long
                            ),



                        ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Trending Stores
                    const Text("Trending Stores",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: trendingStores.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final item = trendingStores[index];
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage:
                              NetworkImage(item["image"]!),
                            ),
                            const SizedBox(height: 6),
                            AutoSizeText(
                              item["title"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w600),
                              maxLines: 1,
                              minFontSize: 8,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              )
                  : GridView.builder(
                itemCount: categoryItems[selectedCategory]?.length ?? 0,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final item = categoryItems[selectedCategory]![index];
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(item["image"]!),
                      ),
                      const SizedBox(height: 6),
                      AutoSizeText(
                        item["title"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w600),
                        maxLines: 1,
                        minFontSize: 8,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// class CategoriesScreen extends StatefulWidget {
//   const CategoriesScreen({super.key});
//
//   @override
//   State<CategoriesScreen> createState() => _CategoriesScreenState();
// }
//
// class _CategoriesScreenState extends State<CategoriesScreen> {
//   String selectedCategory = "Trending Now";
//
//   final List<String> categories = [
//     "Trending Now",
//     "Men's Wear",
//     "Women's Wear",
//     "Kids Wear",
//     "Footwear",
//     "Beauty & Grooming",
//     "Home & Living",
//   ];
//
//   // Spotlight + Stores
//   final List<Map<String, String>> spotlightItems = [
//     {"title": "New On Myntra", "image": "assets/new.png"},
//     {"title": "Monsoon Magic", "image": "assets/monsoon.png"},
//     {"title": "The Edit", "image": "assets/edit.png"},
//     {"title": "Trendnxt", "image": "assets/trend.png"},
//     {"title": "Autumn Winter", "image": "assets/autumn.png"},
//     {"title": "Ganesh Chaturthi Store", "image": "assets/ganesh.png"},
//     {"title": "Onam Store", "image": "assets/onam.png"},
//     {"title": "The Pujo Store", "image": "assets/pujo.png"},
//     {"title": "Navratri Store", "image": "assets/navratri.png"},
//   ];
//
//   final List<Map<String, String>> trendingStores = [
//     {"title": "Myntra Unique", "image": "assets/unique.png"},
//     {"title": "Rising Stars", "image": "assets/rising.png"},
//     {"title": "Luxe", "image": "assets/luxe.png"},
//     {"title": "Picture", "image": "assets/picture.png"},
//     {"title": "Rising Stars Beauty", "image": "assets/beauty.png"},
//     {"title": "FWD", "image": "assets/fwd.png"},
//   ];
//
//   // Category-wise items
//   final Map<String, List<Map<String, String>>> categoryItems = {
//     "Men's Wear": [
//       {"title": "T-Shirts", "image": "assets/mens_tshirt.png"},
//       {"title": "Shirts", "image": "assets/mens_shirt.png"},
//       {"title": "Jeans", "image": "assets/mens_jeans.png"},
//       {"title": "Jackets", "image": "assets/mens_jacket.png"},
//     ],
//     "Women's Wear": [
//       {"title": "Saree", "image": "assets/saree.png"},
//       {"title": "Dresses", "image": "assets/dress.png"},
//       {"title": "Kurtis", "image": "assets/kurti.png"},
//       {"title": "Tops", "image": "assets/top.png"},
//     ],
//     "Kids Wear": [
//       {"title": "T-Shirts", "image": "assets/kids_tshirt.png"},
//       {"title": "Shorts", "image": "assets/kids_shorts.png"},
//       {"title": "Frocks", "image": "assets/kids_frock.png"},
//     ],
//     "Footwear": [
//       {"title": "Heels", "image": "assets/heels.png"},
//       {"title": "Shoes", "image": "assets/shoes.png"},
//       {"title": "Sandals", "image": "assets/sandals.png"},
//     ],
//     "Beauty & Grooming": [
//       {"title": "Lipstick", "image": "assets/lipstick.png"},
//       {"title": "Perfume", "image": "assets/perfume.png"},
//       {"title": "Shaving Kit", "image": "assets/shaving.png"},
//     ],
//     "Home & Living": [
//       {"title": "Furniture", "image": "assets/furniture.png"},
//       {"title": "Decor", "image": "assets/decor.png"},
//       {"title": "Kitchen", "image": "assets/kitchen.png"},
//     ],
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xfffdf6ef),
//       appBar: AppBar(
//         backgroundColor: const Color(0xfffdf6ef),
//         elevation: 0,
//         title: const Text("Categories", style: TextStyle(color: Colors.black)),
//         centerTitle: false,
//         leading: const Icon(Icons.arrow_back, color: Colors.black),
//         actions: const [
//           Icon(Icons.favorite_border, color: Colors.black),
//           SizedBox(width: 12),
//           Icon(Icons.shopping_bag_outlined, color: Colors.black),
//           SizedBox(width: 12),
//         ],
//       ),
//       body: Row(
//         children: [
//           // Sidebar
//           Container(
//             width: 100,
//             color: Colors.grey.shade100,
//             child: ListView.builder(
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 String category = categories[index];
//                 bool isSelected = selectedCategory == category;
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       selectedCategory = category;
//                     });
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: isSelected ? Colors.white : Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: isSelected
//                           ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
//                           : [],
//                     ),
//                     child: Column(
//                       children: [
//                         CircleAvatar(
//                           radius: 25,
//                           backgroundColor: Colors.white,
//                           child: Icon(Icons.image, size: 30, color: Colors.grey),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           category,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight:
//                             isSelected ? FontWeight.bold : FontWeight.normal,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // Right Content
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: selectedCategory == "Trending Now"
//                   ? SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Spotlight
//                     const Text("In The Spotlight",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 12),
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: spotlightItems.length,
//                       gridDelegate:
//                       const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 12,
//                         mainAxisSpacing: 12,
//                         childAspectRatio: 0.8,
//                       ),
//                       itemBuilder: (context, index) {
//                         final item = spotlightItems[index];
//                         return Column(
//                           children: [
//                             CircleAvatar(
//                               radius: 40,
//                               backgroundColor: Colors.grey.shade200,
//                               child: Icon(Icons.image,
//                                   size: 40, color: Colors.black54),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(item["title"]!,
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(fontSize: 12)),
//                           ],
//                         );
//                       },
//                     ),
//
//                     const SizedBox(height: 20),
//
//                     // Trending Stores
//                     const Text("Trending Stores",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 12),
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: trendingStores.length,
//                       gridDelegate:
//                       const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 12,
//                         mainAxisSpacing: 12,
//                         childAspectRatio: 0.8,
//                       ),
//                       itemBuilder: (context, index) {
//                         final item = trendingStores[index];
//                         return Column(
//                           children: [
//                             CircleAvatar(
//                               radius: 40,
//                               backgroundColor: Colors.grey.shade200,
//                               child: Icon(Icons.image,
//                                   size: 40, color: Colors.black54),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(item["title"]!,
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(fontSize: 12)),
//                           ],
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               )
//                   : GridView.builder(
//                 itemCount: categoryItems[selectedCategory]?.length ?? 0,
//                 gridDelegate:
//                 const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   childAspectRatio: 0.8,
//                 ),
//                 itemBuilder: (context, index) {
//                   final item =
//                   categoryItems[selectedCategory]![index];
//                   return Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 40,
//                         backgroundColor: Colors.grey.shade200,
//                         child: Icon(Icons.image,
//                             size: 40, color: Colors.black54),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(item["title"]!,
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(fontSize: 12)),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


/// Side Menu Item
class _SideMenuItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool selected;

  const _SideMenuItem(this.title, this.imagePath, {this.selected = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: selected ? Colors.white : Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(imagePath),
            radius: 24,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section Title
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}

/// Grid for circular icons + text
class _CircleGrid extends StatelessWidget {
  final List<Map<String, String>> items;

  const _CircleGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(items[index]["image"]!),
              radius: 40,
            ),
            const SizedBox(height: 5),
            Text(
              items[index]["title"]!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12,fontWeight: FontWeight.w900),
            ),
          ],
        );
      },
    );
  }
}

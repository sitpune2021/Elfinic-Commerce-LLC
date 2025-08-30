// import 'package:demo_1/beauty_care_screen.dart';
// import 'package:demo_1/home_decor_screen.dart';
// import 'package:demo_1/jewellery_screen.dart';
// import 'package:demo_1/mens_clothing_screen.dart';
// import 'package:demo_1/womens_clothing_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';


class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final List<CategoryItem> categories = [
    CategoryItem(
      title: "Women’s Clothing",
      imagePath: "assets/images/cat1.png",
      screen: const WomensClothingScreen(),
    ),
    CategoryItem(
      title: "Men’s Clothing",
      imagePath: "assets/images/cat2.png",
      screen: const MensClothingScreen(),
    ),
    CategoryItem(
      title: "Beauty and Care",
      imagePath: "assets/images/cate.png",
      screen: const BeautyCareScreen(),
    ),
    CategoryItem(
      title: "Jewellery",
      imagePath: "assets/images/cat4.png",
      screen: const JewelleryScreen(),
    ),
    CategoryItem(
      title: "Home Decor",
      imagePath: "assets/images/cat5.png",
      screen: const HomeDecorScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => category.screen),
                );
              },
              child: CategoryCard(category: category),
            );
          },
        ),
      ),
    );
  }
}

class CategoryItem {
  final String title;
  final String imagePath;
  final Widget screen;

  CategoryItem({
    required this.title,
    required this.imagePath,
    required this.screen,
  });
}

// class CategoryCard extends StatelessWidget {
//   final CategoryItem category;
//
//   const CategoryCard({super.key, required this.category});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 150,
//       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         image: DecorationImage(
//           image: AssetImage(category.imagePath),
//           fit: BoxFit.cover,
//           colorFilter: ColorFilter.mode(
//             Colors.black.withOpacity(0.25),
//             BlendMode.darken,
//           ),
//         ),
//       ),
//       alignment: Alignment.bottomLeft,
//       padding: const EdgeInsets.all(16),
//       child: Text(
//         category.title,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }
class CategoryCard extends StatelessWidget {
  final CategoryItem category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage(category.imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withOpacity(0.6), // left side darker
              Colors.transparent, // right side fade out
            ],
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(16),
        child: Text(
          category.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}



class BeautyCareScreen extends StatefulWidget {
  const BeautyCareScreen({super.key});

  @override
  State<BeautyCareScreen> createState() => _BeautyCareScreenState();
}

class _BeautyCareScreenState extends State<BeautyCareScreen> {
  final List<Map<String, String>> beautyCategories = const [
    {"title": "Makeup", "image": "assets/images/w2.png"},
    {"title": "Skincare", "image": "assets/images/w2.png"},
    {"title": "Haircare", "image": "assets/images/w2.png"},
    {"title": "Fragrances", "image": "assets/images/w2.png"},
    {"title": "Personal Care", "image": "assets/images/w2.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7F0),
        surfaceTintColor:Color(0xFFFDF7F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Beauty and Care",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: beautyCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            final item = beautyCategories[index];
            return Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item["image"]!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["title"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}



class HomeDecorScreen extends StatefulWidget {
  const HomeDecorScreen({super.key});

  @override
  State<HomeDecorScreen> createState() => _HomeDecorScreenState();
}

class _HomeDecorScreenState extends State<HomeDecorScreen> {
  final List<Map<String, String>> homeDecorCategories = const [
    {"title": "Wall Decor", "image": "assets/images/w1.png"},
    {"title": "Showpieces", "image": "assets/images/w1.png"},
    {"title": "Clocks", "image": "assets/images/w1.png"},
    {"title": "Lamps & Lighting", "image": "assets/images/w1.png"},
    {"title": "Cushions", "image": "assets/images/w1.png"},
    {"title": "Curtains", "image": "assets/images/w1.png"},
    {"title": "Rugs & Carpets", "image": "assets/images/w1.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7F0),
        surfaceTintColor:Color(0xFFFDF7F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Home Decor",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: homeDecorCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            final item = homeDecorCategories[index];
            return Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item["image"]!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["title"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


class JewelleryScreen extends StatefulWidget {
  const JewelleryScreen({super.key});

  @override
  State<JewelleryScreen> createState() => _JewelleryScreenState();
}

class _JewelleryScreenState extends State<JewelleryScreen> {
  final List<Map<String, String>> jewelleryCategories = const [
    {"title": "Earrings", "image": "assets/images/w3.png"},
    {"title": "Necklaces", "image": "assets/images/w3.png"},
    {"title": "Bangles & Bracelets", "image": "assets/images/w3.png"},
    {"title": "Rings", "image": "assets/images/w3.png"},
    {"title": "Anklets", "image": "assets/images/w3.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7F0),
        surfaceTintColor:Color(0xFFFDF7F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Jewellery",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: jewelleryCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            final item = jewelleryCategories[index];
            return Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item["image"]!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["title"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}




class MensClothingScreen extends StatefulWidget {
  const MensClothingScreen({super.key});

  @override
  State<MensClothingScreen> createState() => _MensClothingScreenState();
}

class _MensClothingScreenState extends State<MensClothingScreen> {
  final List<Map<String, String>> mensCategories = const [
    {"title": "T-Shirts", "image": "assets/images/w1.png"},
    {"title": "Shirts", "image": "assets/images/w1.png"},
    {"title": "Jeans", "image": "assets/images/w1.png"},
    {"title": "Trousers", "image": "assets/images/w1.png"},
    {"title": "Ethnic Wear", "image": "assets/images/w1.png"},
    {"title": "Suits & Blazers", "image": "assets/images/w1.png"},
    {"title": "Sweatshirts", "image": "assets/images/w1.png"},
    {"title": "Jackets", "image": "assets/images/w1.png"},
    {"title": "Shorts", "image": "assets/images/w1.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7F0),
        surfaceTintColor:Color(0xFFFDF7F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Men’s Clothing",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: mensCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            final item = mensCategories[index];
            return Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item["image"]!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["title"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class WomensClothingScreen extends StatefulWidget {
  const WomensClothingScreen({super.key});

  @override
  State<WomensClothingScreen> createState() => _WomensClothingScreenState();
}

class _WomensClothingScreenState extends State<WomensClothingScreen> {
  final List<Map<String, String>> womensCategories = const [
    {"title": "Saree", "image": "assets/images/cw1.png"},
    {"title": "Kurtis & Kurta Sets", "image": "assets/images/cw2.png"},
    {"title": "Dress Material", "image": "assets/images/cw3.png"},
    {"title": "Lehenga Cholis", "image": "assets/images/cw4.png"},
    {"title": "Tops, Tshirt and Shirts", "image": "assets/images/cw5.png"},
    {"title": "Dresses", "image": "assets/images/cw6.png"},
    {"title": "Skirts and Plazzo", "image": "assets/images/cw1.png"},
    {"title": "Bottomwear", "image": "assets/images/cw2.png"},
    {"title": "Jumpsuits", "image": "assets/images/cw3.png"},
    {"title": "Shrugs & Jackets", "image": "assets/images/cw4.png"},
    {"title": "Sweatshirts & Hoodies", "image": "assets/images/cw6.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF7F0),
        surfaceTintColor:Color(0xFFFDF7F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Women’s Clothing",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: womensCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (context, index) {
            final item = womensCategories[index];
            return Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      item["image"]!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  item["title"]!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 8,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}



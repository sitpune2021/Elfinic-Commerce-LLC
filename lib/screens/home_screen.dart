import 'package:auto_size_text/auto_size_text.dart';
import 'package:elfinic_commerce_llc/screens/NotificationsScreen.dart';
import 'package:elfinic_commerce_llc/screens/serch_bar.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/amiri_text_widget.dart';
import 'CartScreen.dart';
import 'CategoriesScreen.dart';
import 'ProductDetailPage.dart';
// home_screen.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:video_player/video_player.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    // _controller = VideoPlayerController.asset("assets/videos/ad_video.mp4")
    _controller = VideoPlayerController.asset("assets/images/cat1.png")
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  final List<String> banners = [
    "assets/images/banner1.png",
    "assets/images/banner1.png",
  ];

  final List<Map<String, dynamic>> products = [
    {
      "image": "assets/images/product1.png",
      "title": "Lorem ipsum dolor sit amet consectetur.",
      "price": "₹2,996.50",
      "oldPrice": "₹4,148.00",
      "rating": "4.8"
    },
    {
      "image": "assets/images/product2.png",
      "title": "Lorem ipsum dolor sit amet consectetur.",
      "price": "₹2,996.50",
      "oldPrice": "₹4,148.00",
      "rating": "4.8"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey.shade50,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: [
                    // Logo
                    Image.asset("assets/images/splash_screen.png", height: 40),
                    const SizedBox(width: 10),


                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SerchBarScreen()),
                          );
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.search, size: 22, color: Colors.black54),
                              SizedBox(width: 8),
                              Text(
                                "Search...",
                                style: TextStyle(color: Colors.black54, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, size: 28, color: Colors.black87),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartScreen(), // replace with your Cart screen
                          ),
                        );
                        print("Cart clicked");
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.notification_add_outlined, size: 28, color: Colors.black87),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(), // replace with your Cart screen
                          ),
                        );
                        print("Cart clicked");
                      },
                    ),
                  ],
                ),
              ),

              // Categories
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    _buildCategory("Woman", "assets/images/w1.png"),
                    _buildCategory("Man", "assets/images/w2.png"),
                    _buildCategory("Electronics", "assets/images/w3.png"),
                    _buildCategory("Jewellery", "assets/images/w1.png"),
                    _buildCategory("Jewellery", "assets/images/w2.png"),
                    _buildCategory("Jewellery", "assets/images/w3.png"),
                    _buildCategory("Jewellery", "assets/images/w1.png"),
                    _buildCategory("Jewellery", "assets/images/w2.png"),
                  ],
                ),
              ),

              // Banner Carousel
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: SizedBox(
                    height: 180,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 180,
                        autoPlay: true,
                        viewportFraction: 0.9,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: true,
                      ),
                      items: banners.map((img) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              img,
                              fit: BoxFit.fill,
                              width: double.infinity,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
              ),

              const SizedBox(height: 15),

              // Recently Viewed
              _buildSectionTitle("Recently Viewed"),
              _buildProductList(),

              const SizedBox(height: 10),

              // Explore Fresh Styles
              _buildSectionTitle("Explore fresh styles"),
              _buildProductList(),

              const SizedBox(height: 15),

              // Video Ad Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                width: double.infinity,
                height: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _controller.value.isInitialized
                        ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                        : const Center(child: CircularProgressIndicator()),
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Icon(
                        _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Flash Deals
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //  Text(
                    //   "Flash Deals",
                    //     style:
                    //     TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    // ),
                    AmiriText(
                     "Flash Deals",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                     ),

                  Row(
                      children: [
                        const Icon(Icons.flash_on, color: Colors.indigo),
                        const SizedBox(width: 5),
                        CountdownTimer(
                          endTime: DateTime.now().millisecondsSinceEpoch +
                              1000 * 60 * 60 * 12,
                          textStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildProductList(),

              const SizedBox(height: 20),

              // Explore More
          Center(
            child: Text(
              "Explore more",
              style: GoogleFonts.allura(
                fontSize: 28,               // adjust as per design
                fontWeight: FontWeight.w400,
                color: const Color(0xFF2A2A72), // bluish shade from your screenshot
              ),
              textAlign: TextAlign.center,
            ),
          ),


              // Bottom Banner
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.shade50,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left Side: Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          "assets/images/home_img.png", // replace with your image path
                          width: 160,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 20),

                      // Right Side: Text + Button
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          AutoSizeText(
                          "Start Your Online\nBusiness & Grow with\nLimitless Opportunities",
                          style: GoogleFonts.amiri(     // 👈 Amiri font here
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.4,
                          ),
                          maxLines: 3,             // limit lines
                          minFontSize: 12,         // shrink until at least 12px
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo.shade900, // dark blue
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                "Connect Now",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Row(
                //   children: [
                //     Image.asset("assets/images/home_img.png", height: 100),
                //     const SizedBox(width: 15),
                //     Expanded(
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           const Text(
                //             "Start Your Online Business & Grow with Limitless Opportunities",
                //             style: TextStyle(fontWeight: FontWeight.bold),
                //           ),
                //           const SizedBox(height: 10),
                //           ElevatedButton(
                //             onPressed: () {},
                //             style: ElevatedButton.styleFrom(
                //               backgroundColor: Colors.indigo,
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(30),
                //               ),
                //             ),
                //             child: const Text("Connect Now", style: TextStyle(
                //                 fontWeight: FontWeight.bold, color: Colors.white),),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets

  Widget _buildCategory(String title, String img) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(img),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCategory(String title, String img) {
  //   return Container(
  //     width: 80,
  //     margin: const EdgeInsets.symmetric(horizontal: 6),
  //     child: Column(
  //       children: [
  //         CircleAvatar(
  //           radius: 25,
  //           backgroundImage: AssetImage(img),
  //         ),
  //         const SizedBox(height: 5),
  //         Text(title, style: const TextStyle(fontSize: 12)),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.amiri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            "View All",
            style: GoogleFonts.amiri(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSectionTitle(String title) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(title,
  //             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //         const Text("View All", style: TextStyle(color: Colors.indigo)),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildProductList() {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(),
                ),
              );
            },
            child: Container(
              width: screenWidth * 0.44,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.asset(
                          product["image"],
                          height: 130,
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
                              isFavorite = !isFavorite;
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
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
            ),
          );
        },
      ),
    );
  }
}
/*
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;



  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool isFavorite = false; // 🔹 Initial state

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/videos/ad_video.mp4")
      ..initialize().then((_) {
        setState(() {}); // refresh when video is ready
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  final List<String> banners = [
    "assets/images/banner1.png",
    "assets/images/banner1.png",
  ];

  final List<Map<String, dynamic>> products = [
    {
      "image": "assets/images/product1.png",
      "title": "Lorem ipsum dolor sit amet consectetur.",
      "price": "₹2,996.50",
      "oldPrice": "₹4,148.00",
      "rating": "4.8"
    },
    {
      "image": "assets/images/product2.png",
      "title": "Lorem ipsum dolor sit amet consectetur.",
      "price": "₹2,996.50",
      "oldPrice": "₹4,148.00",
      "rating": "4.8"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  children: [
                    // 🔹 Logo
                    Image.asset("assets/images/splash_screen.png", height: 40),

                    const SizedBox(width: 10),

                    // 🔹 Search Bar (Expanded to take available space)
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.search, size: 22, color: Colors.black54),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search...",
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, size: 28, color: Colors.black87),
                      onPressed: () {
                        // 🛒 Navigate to cart screen
                        print("Cart clicked");
                      },
                    ),
                  ],
                ),
              ),

              // 🔹 Categories
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    _buildCategory("Woman", "assets/images/w1.png"),
                    _buildCategory("Man", "assets/images/w2.png"),
                    _buildCategory("Electronics", "assets/images/w3.png"),
                    _buildCategory("Jewellery", "assets/images/w1.png"),
                    _buildCategory("Jewellery", "assets/images/w2.png"),
                    _buildCategory("Jewellery", "assets/images/w3.png"),
                    _buildCategory("Jewellery", "assets/images/w1.png"),
                    _buildCategory("Jewellery", "assets/images/w2.png"),
                  ],
                ),
              ),

              // 🔹 Banner Carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: SizedBox(
                  height: 180,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 180,
                      autoPlay: true,
                      viewportFraction: 0.9, // 👈 makes gap visible
                      enlargeCenterPage: true, // highlights center card
                      enableInfiniteScroll: true,
                    ),
                    items: banners.map((img) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1), // 👈 gap control
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            img,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )

              ),



              const SizedBox(height: 15),

              // 🔹 Recently Viewed
              _buildSectionTitle("Recently Viewed"),
              _buildProductList(),

              const SizedBox(height: 10),

              // 🔹 Explore Fresh Styles
              _buildSectionTitle("Explore fresh styles"),
              _buildProductList(),

              const SizedBox(height: 15),

              // 🔹 Video Ad Section

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            // height: 180,
            width: double.infinity, // Takes full width of screen
            height: MediaQuery.of(context).size.width * 0.5, // 50% of screen width
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 🎥 Video
                _controller.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
                    : const Center(child: CircularProgressIndicator()),

                // ▶️ Play/Pause button overlay
                GestureDetector(
                  onTap: _togglePlay,
                  child: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),


              const SizedBox(height: 15),

              // 🔹 Flash Deals
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Flash Deals",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.flash_on, color: Colors.indigo),
                        const SizedBox(width: 5),
                        CountdownTimer(
                          endTime: DateTime.now().millisecondsSinceEpoch +
                              1000 * 60 * 60 * 12,
                          textStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildProductList(),

              const SizedBox(height: 20),

              // 🔹 Explore More
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Explore more",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                ),
              ),

              // 🔹 Bottom Banner
              Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.shade50,
                ),
                child: Row(
                  children: [
                    Image.asset("assets/images/new_app_icon.png", height: 100),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Start Your Online Business & Grow with Limitless Opportunities",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text("Connect Now", style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.white),),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // 🔹 Bottom Navigation Bar
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.indigo,
      //   unselectedItemColor: Colors.grey,
      //   onTap: (index) {
      //     setState(() {
      //       _selectedIndex = index;
      //     });
      //   },
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wishlist"),
      //     BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Categories"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      //   ],
      // ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CategoriesScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wishlist"),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Categories"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),

    );
  }

  // 🔹 Helper Widgets
  Widget _buildCategory(String title, String img) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(img),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("View All", style: TextStyle(color: Colors.indigo)),
        ],
      ),
    );
  }
  Widget _buildProductList() {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(),
                ),
              );
            },
            child: Container(
              width: screenWidth * 0.44,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.asset(
                          product["image"],
                          height: 130,
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
                              isFavorite = !isFavorite;
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
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
            ),
          );
        },
      ),
    );
  }

  // Widget _buildProductList() {
  //   final screenWidth = MediaQuery.of(context).size.width;
  //
  //   return SizedBox(
  //     height: 250,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       padding: const EdgeInsets.symmetric(horizontal: 10),
  //       itemCount: products.length,
  //       itemBuilder: (context, index) {
  //         final product = products[index];
  //         return Container(
  //           width: screenWidth * 0.44, // 👈 card takes ~42% of screen width
  //           margin: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(12),
  //             boxShadow: [
  //               BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
  //             ],
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Stack(
  //                 children: [
  //                   ClipRRect(
  //                     borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
  //                     child: Image.asset(
  //                       product["image"],
  //                       height: 130,
  //                       width: double.infinity,
  //                       fit: BoxFit.cover,
  //                     ),
  //                   ),
  //                   Positioned(
  //                     right: 8,
  //                     top: 8,
  //                     child: GestureDetector(
  //                       onTap: () {
  //                         setState(() {
  //                           isFavorite = !isFavorite; // Toggle ❤️
  //                         });
  //                       },
  //                       child: CircleAvatar(
  //                         backgroundColor: Colors.white,
  //                         child: Icon(
  //                           isFavorite ? Icons.favorite : Icons.favorite_border,
  //                           color: Colors.red,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //
  //                 ],
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       product["title"],
  //                       maxLines: 2,
  //                       style: const TextStyle(fontSize: 12),
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                     const SizedBox(height: 5),
  //                     Row(
  //                       children: [
  //                         Text(
  //                           product["oldPrice"],
  //                           style: const TextStyle(
  //                             fontSize: 12,
  //                             color: Colors.grey,
  //                             decoration: TextDecoration.lineThrough,
  //                           ),
  //                         ),
  //                         const SizedBox(width: 5),
  //                         Text(
  //                           product["price"],
  //                           style: const TextStyle(
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 14,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 5),
  //                     Row(
  //                       children: [
  //                         const Icon(Icons.star, size: 14, color: Colors.orangeAccent),
  //                         Text(product["rating"], style: const TextStyle(fontSize: 12)),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

}
*/

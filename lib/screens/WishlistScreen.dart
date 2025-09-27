import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'DashboardScreen.dart';
import 'home_screen.dart';
import 'package:flutter/material.dart';
import 'DashboardScreen.dart';
import 'package:flutter/material.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;

        // Determine crossAxisCount dynamically
        int crossAxisCount = 2;
        if (screenWidth > 1200) {
          crossAxisCount = 5;
        } else if (screenWidth > 800) {
          crossAxisCount = 4;
        } else if (screenWidth > 600) {
          crossAxisCount = 3;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _buildAppBar(context, screenWidth),
          body: Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(), // ✅ iOS-like smooth bounce
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: screenWidth > 600 ? 0.65 : 0.72,
                crossAxisSpacing: screenWidth * 0.03,
                mainAxisSpacing: screenWidth * 0.03,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                return _buildWishlistCard(context, screenWidth);
              },
            ),
          ),
        );
      },
    );
  }

  /// ✅ AppBar with responsive size
  PreferredSizeWidget _buildAppBar(BuildContext context, double screenWidth) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: const Color(0xfffdf6ef),
      title: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black, size: screenWidth * 0.06),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              }
            },
          ),
          SizedBox(width: screenWidth * 0.01),
          Text(
            "Wishlist",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: screenWidth * 0.045,
                child: IconButton(
                  icon: Icon(Icons.shopping_cart_outlined,
                      color: Colors.black, size: screenWidth * 0.05),
                  onPressed: () {},
                ),
              ),
              Positioned(
                right: screenWidth * 0.012,
                top: screenWidth * 0.012,
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.01),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "4",
                    style: TextStyle(
                      fontSize: screenWidth * 0.025,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ Wishlist Card
  Widget _buildWishlistCard(BuildContext context, double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📌 Product Image
          Container(
            height: screenWidth * 0.3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenWidth * 0.03),
                    topRight: Radius.circular(screenWidth * 0.03),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.asset(
                      "assets/images/w1.png",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image_not_supported,
                            size: screenWidth * 0.25, color: Colors.grey);
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: screenWidth * 0.02,
                  top: screenWidth * 0.02,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: screenWidth * 0.04,
                    child: Icon(Icons.favorite,
                        color: Colors.orange, size: screenWidth * 0.045),
                  ),
                ),
              ],
            ),
          ),

          // 📌 Product Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Lorem ipsum dolor sit amet consectetur.",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Row(
                    children: [
                      Text(
                        "₹4,148.00",
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        "₹2,996.50",
                        style: TextStyle(
                          fontSize: screenWidth * 0.033,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  // 📌 Buttons
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo,
                        radius: screenWidth * 0.04,
                        child: Icon(Icons.shopping_cart_outlined,
                            color: Colors.white, size: screenWidth * 0.04),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffc98a35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.08),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.025,
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "BUY NOW",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // backgroundColor: const Color(0xfffdf6ef),
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xfffdf6ef),
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.close, color: Colors.black, size: screenWidth * 0.07),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  );
                }
              },
            ),
            SizedBox(width: screenWidth * 0.01),
            Text(
              "Wishlist",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: screenWidth * 0.05,
                  child: IconButton(
                    icon: Icon(Icons.shopping_cart_outlined,
                        color: Colors.black, size: screenWidth * 0.055),
                    onPressed: () {},
                  ),
                ),
                Positioned(
                  right: screenWidth * 0.015,
                  top: screenWidth * 0.015,
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.01),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "4",
                      style: TextStyle(
                        fontSize: screenWidth * 0.025,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenWidth > 600 ? 3 : 2,
            childAspectRatio: screenWidth > 600 ? 0.65 : 0.72, // Increased aspect ratio
            crossAxisSpacing: screenWidth * 0.03,
            mainAxisSpacing: screenWidth * 0.03,
          ),
          itemCount: 3,
          itemBuilder: (context, index) {
            return _buildWishlistCard(context, screenWidth);
          },
        ),
      ),
    );
  }

  Widget _buildWishlistCard(BuildContext context, double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + Favorite - Fixed height
          Container(
            height: screenWidth * 0.32, // Reduced image height
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenWidth * 0.03),
                    topRight: Radius.circular(screenWidth * 0.03),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.asset(
                      "assets/images/w1.png",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.image_not_supported,
                            size: screenWidth * 0.3,
                            color: Colors.grey);
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: screenWidth * 0.02,
                  top: screenWidth * 0.02,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: screenWidth * 0.04,
                    child: Icon(Icons.favorite,
                        color: Colors.orange, size: screenWidth * 0.045),
                  ),
                ),
              ],
            ),
          ),

          // Title + Prices with flexible space
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.015),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lorem ipsum dolor sit amet consectetur.",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.01),
                      Row(
                        children: [
                          Text(
                            "₹4,148.00",
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            "₹2,996.50",
                            style: TextStyle(
                              fontSize: screenWidth * 0.033,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Buttons
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.indigo,
                        radius: screenWidth * 0.04,
                        child: Icon(Icons.shopping_cart_outlined,
                            color: Colors.white, size: screenWidth * 0.04),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffc98a35),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(screenWidth * 0.08),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.025,
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "BUY NOW",
                            style: TextStyle( color: Colors.white,
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/


// class WishlistScreen extends StatelessWidget {
//   const WishlistScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       backgroundColor: const Color(0xfffdf6ef),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         elevation: 0,
//         backgroundColor: const Color(0xfffdf6ef),
//         title: Row(
//           children: [
//
//             IconButton(
//               icon: Icon(Icons.close, color: Colors.black, size: screenWidth * 0.07),
//               onPressed: () {
//                 if (Navigator.canPop(context)) {
//                   Navigator.pop(context);
//                 } else {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const DashboardScreen()),
//                   );
//                 }
//               },
//             ),
//
//
//
//             SizedBox(width: screenWidth * 0.01),
//             Text(
//               "Wishlist",
//               style: TextStyle(
//                 fontSize: screenWidth * 0.05,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             const Spacer(),
//             Stack(
//               children: [
//                 CircleAvatar(
//                   backgroundColor: Colors.white,
//                   radius: screenWidth * 0.05,
//                   child: IconButton(
//                     icon: Icon(Icons.shopping_cart_outlined,
//                         color: Colors.black, size: screenWidth * 0.055),
//                     onPressed: () {},
//                   ),
//                 ),
//                 Positioned(
//                   right: screenWidth * 0.015,
//                   top: screenWidth * 0.015,
//                   child: Container(
//                     padding: EdgeInsets.all(screenWidth * 0.01),
//                     decoration: const BoxDecoration(
//                       color: Colors.orange,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Text(
//                       "4",
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.025,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//
//       body: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.03),
//         child: GridView.builder(
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: screenWidth > 600 ? 3 : 2,
//             childAspectRatio: screenWidth > 600 ? 0.65 : 0.68,
//             crossAxisSpacing: screenWidth * 0.03,
//             mainAxisSpacing: screenWidth * 0.03,
//           ),
//           itemCount: 3,
//           itemBuilder: (context, index) {
//             return _buildWishlistCard(context, screenWidth);
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildWishlistCard(BuildContext context, double screenWidth) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(screenWidth * 0.03),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Image + Favorite
//               Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(screenWidth * 0.03),
//                       topRight: Radius.circular(screenWidth * 0.03),
//                     ),
//                     child: Container(
//                       height: constraints.maxWidth * 0.75,
//                       color: Colors.grey[200],
//                       child: Image.asset(
//                         "assets/images/w1.png",
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Icon(Icons.image_not_supported,
//                               size: constraints.maxWidth * 0.3,
//                               color: Colors.grey);
//                         },
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     right: screenWidth * 0.02,
//                     top: screenWidth * 0.02,
//                     child: CircleAvatar(
//                       backgroundColor: Colors.white,
//                       radius: screenWidth * 0.04,
//                       child: Icon(Icons.favorite,
//                           color: Colors.orange, size: screenWidth * 0.045),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // Title + Prices
//               Padding(
//                 padding: EdgeInsets.all(screenWidth * 0.015),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Lorem ipsum dolor sit amet consectetur.",
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.032,
//                         fontWeight: FontWeight.w600,
//                         height: 1.2,
//                       ),
//                     ),
//                     SizedBox(height: screenWidth * 0.01),
//                     Row(
//                       children: [
//                         Text(
//                           "₹4,148.00",
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.03,
//                             decoration: TextDecoration.lineThrough,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         SizedBox(width: screenWidth * 0.01),
//                         Text(
//                           "₹2,996.50",
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.033,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Flexible spacer to prevent overflow
//               Flexible(child: Container()),
//
//               // Buttons
//               Padding(
//                 padding: EdgeInsets.all(screenWidth * 0.015),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       backgroundColor: Colors.indigo,
//                       radius: screenWidth * 0.04,
//                       child: Icon(Icons.shopping_cart_outlined,
//                           color: Colors.white, size: screenWidth * 0.04),
//                     ),
//                     SizedBox(width: screenWidth * 0.02),
//                     Flexible(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xffc98a35),
//                           shape: RoundedRectangleBorder(
//                             borderRadius:
//                             BorderRadius.circular(screenWidth * 0.08),
//                           ),
//                           padding: EdgeInsets.symmetric(
//                             vertical: screenWidth * 0.025,
//                           ),
//                         ),
//                         onPressed: () {},
//                         child: Text(
//                           "BUY NOW",
//                           style: TextStyle( color: Colors.white,
//                             fontSize: screenWidth * 0.03,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

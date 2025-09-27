// dashboard_screen.dart
import 'package:flutter/material.dart';
import 'CategoriesScreen.dart';
import 'ProfileScreen.dart';
import 'WishlistScreen.dart';
import 'home_screen.dart';
// dashboard_screen.dart
import 'package:elfinic_commerce_llc/utils/BaseScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // 👈 needed for ScrollDirection
import 'CategoriesScreen.dart';
import 'ProfileScreen.dart';
import 'WishlistScreen.dart';
import 'home_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Replace with your actual screens

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _showBottomNav = true; // 👈 controls nav visibility

  // Screens for each tab
  final List<Widget> _screens = const [
    HomeScreen(),
    WishlistScreen(),
    CategoriesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Scaffold(
        body: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.reverse) {
              if (_showBottomNav) setState(() => _showBottomNav = false);
            } else if (notification.direction == ScrollDirection.forward) {
              if (!_showBottomNav) setState(() => _showBottomNav = true);
            }
            return false;
          },
          child: _screens[_selectedIndex],
        ),
      
        // 👇 Animated BottomNavigationBar
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showBottomNav ? kBottomNavigationBarHeight : 0,
          child: Wrap(
            children: [
              BottomNavigationBar(
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.indigo,
                unselectedItemColor: Colors.grey,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                  BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wishlist"),
                  BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Categories"),
                  BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({Key? key}) : super(key: key);
//
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<DashboardScreen> {
//   int _selectedIndex = 0;
//   bool _showBottomNav = true;
//
//   final List<Widget> _screens = const [
//     HomeScreen(),
//     WishlistScreen(),
//     CategoriesScreen(),
//     ProfileScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return BaseScreen(
//       child: Scaffold(
//         body: NotificationListener<UserScrollNotification>(
//           onNotification: (notification) {
//             if (notification.direction == ScrollDirection.reverse) {
//               if (_showBottomNav) setState(() => _showBottomNav = false);
//             } else if (notification.direction == ScrollDirection.forward) {
//               if (!_showBottomNav) setState(() => _showBottomNav = true);
//             }
//             return false;
//           },
//           child: _screens[_selectedIndex],
//         ),
//
//         // 👉 Animated GNav bottom bar
//         bottomNavigationBar: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           height: _showBottomNav ? kBottomNavigationBarHeight + 10 : 0,
//           child: Container(
//             color: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
//             child: GNav(
//               gap: 8,
//               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
//               backgroundColor: Colors.white,
//               color: Colors.black, // unselected
//               activeColor: const Color(0xFFD39841), // gold selected
//               tabBackgroundColor: Colors.transparent, // no background highlight
//               rippleColor: Colors.transparent,
//               hoverColor: Colors.transparent,
//               duration: const Duration(milliseconds: 300),
//               selectedIndex: _selectedIndex,
//               onTabChange: (index) => setState(() => _selectedIndex = index),
//               tabs: const [
//                 GButton(
//                   icon: Icons.home,
//                   text: 'Home',
//                 ),
//                 GButton(
//                   icon: Icons.favorite_border,
//                   text: 'Wishlist',
//                 ),
//                 GButton(
//                   icon: Icons.menu,
//                   text: 'Categories',
//                 ),
//                 GButton(
//                   icon: Icons.person_outline,
//                   text: 'Profile',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({Key? key}) : super(key: key);
//
//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<DashboardScreen> {
//   int _selectedIndex = 0;
//
//   // Screens for each tab
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const WishlistScreen(), // Placeholder - create this screen
//     const CategoriesScreen(), // Placeholder - create this screen
//     const ProfileScreen(), // Placeholder - create this screen
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.indigo,
//         unselectedItemColor: Colors.grey,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wishlist"),
//           BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Categories"),
//           BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
//         ],
//       ),
//     );
//   }
// }
//



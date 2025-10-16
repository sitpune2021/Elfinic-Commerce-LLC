// dashboard_screen.dart
import 'package:flutter/material.dart';
import 'CartScreen.dart';
import 'CategoriesScreen.dart';
import 'ProfileScreen.dart';
import 'WishlistScreen.dart';
import 'home_screen.dart';
// dashboard_screen.dart
import 'package:elfinic_commerce_llc/utils/BaseScreen.dart';
import 'package:flutter/rendering.dart'; // 👈 needed for ScrollDirection



import 'package:curved_navigation_bar/curved_navigation_bar.dart';




class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ProfileScreen(),
    CategoriesScreen(),
    CartScreen(),

  ];

  final List<IconData> _navIcons = const [
    Icons.home,
    Icons.person_outline,
    Icons.grid_view,

    Icons.shopping_cart,
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _screens[_selectedIndex],
        bottomNavigationBar: CurvedNavigationBar(
          index: _selectedIndex,
          backgroundColor: Colors.transparent,
          color: const Color(0xFF050040),
          buttonBackgroundColor: const Color(0xFF050040),
          height: 60,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          items: _navIcons
              .map(
                (icon) => Icon(
              icon,
              size: 28,
              color: Colors.white,
            ),
          )
              .toList(),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}



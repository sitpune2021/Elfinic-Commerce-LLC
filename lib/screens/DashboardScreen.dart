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

        // 👇 Animated Bottom Navigation
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

/*
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Screens for each tab
  final List<Widget> _screens = [
    const HomeScreen(),
    const WishlistScreen(), // Placeholder - create this screen
    const CategoriesScreen(), // Placeholder - create this screen
    const ProfileScreen(), // Placeholder - create this screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}
*/




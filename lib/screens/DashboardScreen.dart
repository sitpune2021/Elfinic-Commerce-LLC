// dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'CartScreen.dart';
import 'CategoriesScreen.dart';
import 'ProfileScreen.dart';
import 'WishlistScreen.dart';
import 'home_screen.dart';
// dashboard_screen.dart
import 'package:elfinic_commerce_llc/utils/BaseScreen.dart';
import 'package:flutter/rendering.dart'; // 👈 needed for ScrollDirection



import 'package:curved_navigation_bar/curved_navigation_bar.dart';


import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';





  class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

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
  void initState() {
    super.initState();

    // FORCE white status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark, // BLACK icons
        statusBarBrightness: Brightness.light,
      ),
    );

    _checkInitialConnection();
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkInitialConnection() async {
    final List<ConnectivityResult> results =
    await Connectivity().checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    setState(() {
      _isConnected = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _isConnected
            ? _screens[_selectedIndex]
            : NoInternetWidget(onRetry: _checkInitialConnection),
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

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetWidget({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Lottie.asset(
        'assets/animations/no_internet.json',
        width: 180,
        fit: BoxFit.contain,
      ),
          const SizedBox(height: 16),
          const Text(
            'No Internet Connection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your network settings and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF050040),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry',style: TextStyle(color: Colors.white),),
          ),
        ],
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
*/



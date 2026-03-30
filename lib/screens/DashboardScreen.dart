// dashboard_screen.dart
import 'package:elfinic_commerce_llc/screens/shops_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'CartScreen.dart';
import 'CategoriesScreen.dart';
import 'ProfileScreen.dart';
import 'home_screen.dart';
// dashboard_screen.dart
import 'package:elfinic_commerce_llc/utils/BaseScreen.dart';
// 👈 needed for ScrollDirection

import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    CartScreen(fromNavBar: true),
    ProfileScreen(),
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
        bottomNavigationBar: SizedBox(
          height: 80,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [

              /// 🔵 Bottom Bar (same as yours)
              Container(
                height: 70,
                color: const Color(0xFF050040),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      /// Home
                      IconButton(
                        icon: Icon(
                          Icons.home,
                          size: 28,
                          color: _selectedIndex == 0
                              ? Colors.white
                              : Colors.white54,
                        ),
                        onPressed: () => setState(() => _selectedIndex = 0),
                      ),

                      /// Categories
                      IconButton(
                        icon: Icon(
                          Icons.grid_view,
                          size: 28,
                          color: _selectedIndex == 1
                              ? Colors.white
                              : Colors.white54,
                        ),
                        onPressed: () => setState(() => _selectedIndex = 1),
                      ),

                      const SizedBox(width: 60), // space for center button

                      /// Cart
                      IconButton(
                        icon: Icon(
                          Icons.shopping_cart,
                          size: 28,
                          color: _selectedIndex == 2
                              ? Colors.white
                              : Colors.white54,
                        ),
                        onPressed: () => setState(() => _selectedIndex = 2),
                      ),

                      /// Profile
                      IconButton(
                        icon: Icon(
                          Icons.person_outline,
                          size: 28,
                          color: _selectedIndex == 3
                              ? Colors.white
                              : Colors.white54,
                        ),
                        onPressed: () => setState(() => _selectedIndex = 3),
                      ),
                    ],
                  ),
                ),
              ),

              /// 🟡 Center Button (Custom FAB)
              Positioned(
                top: 5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ShopsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD39841),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),


      ),
    );
  }
}

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetWidget({super.key, required this.onRetry});

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
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}


/*class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
    CartScreen(fromNavBar: true),
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

  const NoInternetWidget({super.key, required this.onRetry});

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
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}*/
 
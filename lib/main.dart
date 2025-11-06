import 'package:elfinic_commerce_llc/providers/BannerProvider.dart';
import 'package:elfinic_commerce_llc/providers/ConnectivityProvider.dart';
import 'package:elfinic_commerce_llc/providers/OrderProvider.dart';
import 'package:elfinic_commerce_llc/providers/ShippingProvider.dart';
import 'package:elfinic_commerce_llc/providers/AuthProvider.dart';
import 'package:elfinic_commerce_llc/providers/CartProvider.dart';
import 'package:elfinic_commerce_llc/providers/RegisterProvider.dart';
import 'package:elfinic_commerce_llc/providers/SubCategoryProvider.dart';
import 'package:elfinic_commerce_llc/providers/WishlistProvider.dart';
import 'package:elfinic_commerce_llc/providers/category_provider.dart';
import 'package:elfinic_commerce_llc/providers/delivery_provider.dart';
import 'package:elfinic_commerce_llc/providers/product_provider.dart';
import 'package:elfinic_commerce_llc/screens/DashboardScreen.dart';
import 'package:elfinic_commerce_llc/screens/review_screen.dart';
import 'package:elfinic_commerce_llc/screens/splash_screen.dart';
import 'package:elfinic_commerce_llc/utils/NoInternetOverlay.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


import 'package:elfinic_commerce_llc/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers

// Screens
import 'screens/register_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Check login token from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString("auth_token");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SubCategoryProvider()), // <- add this
        ChangeNotifierProvider(create: (_) => CartProvider()), // <- add this
        ChangeNotifierProvider(create: (_) => AddressProvider()), // <- add this
        ChangeNotifierProvider(create: (_) => DeliveryProvider()), // <- add this
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()), // Add this line
        ChangeNotifierProvider(create: (_) => OrderProvider()), // Add this line
      ],
      child: MyApp(isLoggedIn: token != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Elfinic Commerce LLC',
          theme: ThemeData(
            primaryTextTheme: GoogleFonts.robotoTextTheme(),
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            // '/order-details': (context) => const OrderDetailsScreen(),
          },
          home: Builder(
            builder: (context) {
              if (!connectivity.isConnected) {
                // Show No Internet Screen
                return const NoInternetOverlay();
              } else {
                // If connected
                return isLoggedIn
                    ? const DashboardScreen()
                    : const SplashScreen();
              }
            },
          ),
        );
      },
    );
  }
}


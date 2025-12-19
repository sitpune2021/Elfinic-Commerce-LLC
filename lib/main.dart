import 'package:elfinic_commerce_llc/providers/ArrivalProductProvider.dart';
import 'package:elfinic_commerce_llc/providers/BannerProvider.dart';
import 'package:elfinic_commerce_llc/providers/ConnectivityProvider.dart';
import 'package:elfinic_commerce_llc/providers/LogoutProvider.dart';
import 'package:elfinic_commerce_llc/providers/OrderProvider.dart';
import 'package:elfinic_commerce_llc/providers/RecentViewProvider.dart';
import 'package:elfinic_commerce_llc/providers/ReviewProvider.dart';
import 'package:elfinic_commerce_llc/providers/ShippingProvider.dart';
import 'package:elfinic_commerce_llc/providers/AuthProvider.dart';
import 'package:elfinic_commerce_llc/providers/CartProvider.dart';
import 'package:elfinic_commerce_llc/providers/RegisterProvider.dart';
import 'package:elfinic_commerce_llc/providers/SubCategoryProvider.dart';
import 'package:elfinic_commerce_llc/providers/WishlistProvider.dart';
import 'package:elfinic_commerce_llc/providers/category_provider.dart';
import 'package:elfinic_commerce_llc/providers/delivery_provider.dart';
import 'package:elfinic_commerce_llc/providers/product_provider.dart';
import 'package:elfinic_commerce_llc/screens/CartScreen.dart';
import 'package:elfinic_commerce_llc/screens/DashboardScreen.dart';
import 'package:elfinic_commerce_llc/screens/review_screen.dart';
import 'package:elfinic_commerce_llc/screens/splash_screen.dart';
import 'package:elfinic_commerce_llc/utils/NoInternetOverlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';


import 'package:elfinic_commerce_llc/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers

// Screens
import 'screens/register_screen.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // WHITE
      statusBarIconBrightness: Brightness.dark, // BLACK icons (Android)
      statusBarBrightness: Brightness.light, // iOS
    ),
  );

  // Initialize SharedPreferences but don't decide login here
  await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SubCategoryProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => LogoutProvider()),
        ChangeNotifierProvider(create: (_) => RecentViewProvider()),
        ChangeNotifierProvider(create: (_) => ArrivalProductProvider()),



        ChangeNotifierProvider(create: (_) => CouponProvider()),
        // ChangeNotifierProvider(create: (_) => ShippingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Elfinic Commerce LLC',
          theme: ThemeData(
            primaryTextTheme: GoogleFonts.robotoTextTheme(),
            primaryColor: Color(0xFFD39841), // ✅ App primary color
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFD39841), // ✅ AppBar color
              foregroundColor: Colors.white,  // ✅ Text/Icon color
            ),
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/dashboard': (context) => const DashboardScreen(),
          },
          // ✅ Always start with SplashScreen first
          home: Builder(
            builder: (context) {
              if (!connectivity.isConnected) {
                return const NoInternetOverlay();
              } else {
                return const SplashScreen();
              }
            },
          ),
        );
      },
    );
  }
  
}




import 'package:elfinic_commerce_llc/screens/ProductDetailPage.dart';
import 'package:elfinic_commerce_llc/screens/category_list.dart';
import 'package:elfinic_commerce_llc/screens/home_screen.dart';
import 'package:elfinic_commerce_llc/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      // theme: ThemeData(
      //   fontFamily: 'Roboto',
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      //   useMaterial3: true,
      // ),
      theme: ThemeData(
        textTheme: GoogleFonts.amiriTextTheme(),
      ),
      home:  SplashScreen(),
      // home:  CategoriesScreen(),
    );
  }
}

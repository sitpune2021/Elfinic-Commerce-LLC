/*
import 'package:flutter/material.dart';
class BaseScreen extends StatelessWidget {
  final Widget child;
  const BaseScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: child,
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseScreen extends StatelessWidget {
  final Widget child;

  const BaseScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // ✅ WHITE status bar
        statusBarIconBrightness: Brightness.dark, // ✅ BLACK icons (Android)
        statusBarBrightness: Brightness.light, // ✅ iOS
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: child,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
class LottieOverlay extends StatefulWidget {
  final Widget child;

  const LottieOverlay({Key? key, required this.child}) : super(key: key);

  @override
  State<LottieOverlay> createState() => _LottieOverlayState();
}

class _LottieOverlayState extends State<LottieOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showAnimation = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Exactly 2 seconds
    );

    // Start animation and hide after 2 seconds
    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _showAnimation = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showAnimation)
          Container(
            color: Colors.white,
            child: Center(
              child: Lottie.asset(
                'assets/animations/shopping_bag.json',
                controller: _controller,
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }
}
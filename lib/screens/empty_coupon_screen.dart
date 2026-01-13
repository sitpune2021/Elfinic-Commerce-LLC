import 'package:flutter/material.dart';

class EmptyCouponCard extends StatelessWidget {
  const EmptyCouponCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 54),
          child: PhysicalShape(
            elevation: 2,
            color: Colors.white,
            shadowColor: Colors.black.withValues(alpha: .25),
            clipper: CouponClipper(),
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _topSection(),
                  _dashedDivider(),
                  _imageSection(),
                  _footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 TOP CONTENT
  Widget _topSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/new_app_icon.png',
                height: 60,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              const Text(
                'Elfinic',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 10),
          Image.asset(
            'assets/images/danger.png',
            height: 160,
          ),
          const SizedBox(height: 12),
          const Text(
            'No Coupons Available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check back later for exciting offers',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🔹 DOTTED PERFORATION
  Widget _dashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: List.generate(
              (constraints.maxWidth / 8).floor(),
              (index) => Expanded(
                child: Container(
                  height: 1,
                  color:
                      index.isEven ? Colors.grey.shade400 : Colors.transparent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔹 IMAGE BODY
  Widget _imageSection() {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/no_coupon.png',
              fit: BoxFit.cover,
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'NO COUPONS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 FOOTER
  Widget _footer() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Text(
        'No active offers right now',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}

/// 🎟 COUPON CLIPPER (SIDE CUTS)
class CouponClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double cornerRadius = 16;
    const double cutRadius = 14;

    final Path path = Path();

    // Start top-left (after corner)
    path.moveTo(cornerRadius, 0);

    // Top edge
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(
      size.width,
      0,
      size.width,
      cornerRadius,
    );

    // Right edge (top part)
    path.lineTo(size.width, size.height / 2 - cutRadius);

    // Right coupon cut
    path.arcToPoint(
      Offset(size.width, size.height / 2 + cutRadius),
      radius: const Radius.circular(cutRadius),
      clockwise: false,
    );

    // Right edge (bottom part)
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );

    // Bottom edge
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(
      0,
      size.height,
      0,
      size.height - cornerRadius,
    );

    // Left edge (bottom part)
    path.lineTo(0, size.height / 2 + cutRadius);

    // Left coupon cut
    path.arcToPoint(
      Offset(0, size.height / 2 - cutRadius),
      radius: const Radius.circular(cutRadius),
      clockwise: false,
    );

    // Left edge (top part)
    path.lineTo(0, cornerRadius);
    path.quadraticBezierTo(
      0,
      0,
      cornerRadius,
      0,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

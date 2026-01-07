import 'package:elfinic_commerce_llc/screens/privacy_policy_screen.dart';
import 'package:elfinic_commerce_llc/screens/refund_cancellation_policy_screen.dart';
import 'package:elfinic_commerce_llc/screens/shipping_delivery_policy_screen.dart';
import 'package:elfinic_commerce_llc/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  bool showFab = true;

  late ScrollController _scrollController;
  late AnimationController _lottieController;

  bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (showFab) setState(() => showFab = false);
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (!showFab) setState(() => showFab = true);
        }
      });

    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  void toggleMenu() {
    setState(() {
      isExpanded = !isExpanded;
      isExpanded ? _lottieController.forward() : _lottieController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text("About Us"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop(context) ? 1000 : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: isTablet(context) ? _tabletLayout() : _mobileLayout(),
                ),
              ),
            ),
          ),

          /// FLOATING CONTACT MENU
          if (showFab)
            Positioned(
              right: 16,
              bottom: 24,
              child: Column(
                children: [
                  if (isExpanded) ...[
                    FloatingActionButton(
                      heroTag: "whatsapp",
                      mini: true,
                      backgroundColor: Colors.green,
                      onPressed: () {
                        launchUrl(
                          Uri.parse("https://wa.me/1234567890"),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Lottie.asset(
                        "assets/lottie/whatsapp.json",
                        width: 30,
                        height: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton(
                      heroTag: "email",
                      mini: true,
                      backgroundColor: Colors.blue,
                      onPressed: () {
                        launchUrl(Uri.parse("mailto:support@yourapp.com"));
                      },
                      child: Lottie.asset(
                        "assets/lottie/email.json",
                        width: 30,
                        height: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FloatingActionButton(
                    backgroundColor: Colors.black,
                    onPressed: toggleMenu,
                    child: Lottie.asset(
                      "assets/lottie/Support.json",
                      controller: _lottieController,
                      repeat: false,
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ===================== LAYOUTS =====================

  Widget _mobileLayout() {
    return Column(
      children: [
        AnimatedSection(index: 0, child: _whoWeAreCard()),
        const SizedBox(height: 20),
        AnimatedSection(index: 1, child: _missionCard()),
        const SizedBox(height: 20),
        AnimatedSection(index: 2, child: _visionCard()),
        const SizedBox(height: 20),
        AnimatedSection(index: 3, child: _journeyCard()),
        const SizedBox(height: 20),
        AnimatedSection(index: 4, child: _communityCard()),
        const SizedBox(height: 32),
        AnimatedSection(index: 5, child: _policyFooter()),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _tabletLayout() {
    return Column(
      children: [
        AnimatedSection(index: 0, child: _whoWeAreCard()),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AnimatedSection(index: 1, child: _missionCard()),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: AnimatedSection(index: 2, child: _visionCard()),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AnimatedSection(index: 3, child: _journeyCard()),
        const SizedBox(height: 24),
        AnimatedSection(index: 4, child: _communityCard()),
        const SizedBox(height: 40),
        AnimatedSection(index: 5, child: _policyFooter()),
        const SizedBox(height: 20),
      ],
    );
  }

  // ===================== CARDS =====================

  Widget _whoWeAreCard() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(icon: Icons.public, title: "Who We Are"),
            responsiveDivider(context),
            Text(
              "Elfinic is a global creative commerce company officially registered as:\n\n"
              "• Elfinic Commerce Pvt. Ltd. (India) – Established 2025\n"
              "• Elfinic Commerce LLC (USA) – Established 2025\n\n"
              "Headquartered in Mumbai, India, with a strong international presence "
              "in the United States, Elfinic blends creativity, culture, and commerce "
              "to deliver world-class experiences in music, design, and lifestyle innovation.",
              style: TextStyle(height: 1.6),
            ),
          ],
        ),
      );

  Widget _missionCard() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(icon: Icons.flag, title: "Our Mission"),
            responsiveDivider(context),
            Text(
              "To inspire and empower through creativity — merging art, innovation, "
              "and commerce to create meaningful music, iconic brands, and lifestyle "
              "products that connect with people everywhere.",
              style: TextStyle(height: 1.6),
            ),
          ],
        ),
      );

  Widget _visionCard() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(icon: Icons.visibility, title: "Our Vision"),
            responsiveDivider(context),
            Text(
              "To be a global leader in music, media, and modern commerce — where "
              "ideas are transformed into experiences that redefine entertainment "
              "and lifestyle.",
              style: TextStyle(height: 1.6),
            ),
          ],
        ),
      );

  Widget _journeyCard() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(icon: Icons.timeline, title: "Our Journey"),
            responsiveDivider(context),
            Text(
              "Founded in India in 2022, Elfinic began with a vision to unite artistic "
              "creativity and commercial excellence. In 2025, Elfinic expanded "
              "globally with the registration of Elfinic Commerce LLC in the USA.\n\n"
              "Today, Elfinic stands as a cross-border creative powerhouse connecting "
              "cultures and delivering impactful work across continents.",
              style: TextStyle(height: 1.6),
            ),
          ],
        ),
      );

  Widget _communityCard() => _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardHeader(
              icon: Icons.groups,
              title: "Join the Elfinic Community",
            ),
            responsiveDivider(context),
            const Text(
              "Elfinic is more than an online store — it's a community of individuals "
              "who share a passion for creativity, style, and technology.\n\n"
              "We invite you to explore our collections and embark on a shopping journey "
              "that combines practicality with enchantment. Thank you for visiting "
              "ElfInic, and we look forward to being a part of your fashion and tech adventures.",
              style: TextStyle(
                height: 1.6,
              ),
            ),
          ],
        ),
      );

  Widget _policyFooter() {
    return Column(
      children: [
        // Divider(color: Colors.black12),
        responsiveDivider(context),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          children: [
            _footerLink(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            _footerLink(
              icon: Icons.local_shipping_outlined,
              title: "Ship and Delivery Policy",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ShippingDeliveryPolicyScreen(),
                  ),
                );
              },
            ),
            _footerLink(
              icon: Icons.assignment_return_outlined,
              title: "Refund and Cancellation Policy",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RefundCancellationPolicyScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          "© Elfinic.com | All rights reserved 2022 - 2026",
          style: TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget responsiveDivider(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Divider(
      height: width < 600
          ? 24 // Mobile
          : width < 1024
              ? 32 // Tablet
              : 40, // Desktop
      thickness: width < 600
          ? 1
          : width < 1024
              ? 1.4
              : 2,
      indent: width < 600
          ? 0
          : width < 1024
              ? 8
              : 16,
      endIndent: width < 600
          ? 0
          : width < 1024
              ? 8
              : 16,
      color: AppColors.primaryAccent.withValues(alpha: 0.55),
    );
  }

  Widget _footerLink({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: AppColors.primaryAccent,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ===================== ANIMATED SECTION =====================
class AnimatedSection extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedSection({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + (index * 150)),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}

// ===================== CARD HEADER =====================
class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CardHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

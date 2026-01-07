import 'package:elfinic_commerce_llc/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class ShippingDeliveryPolicyScreen extends StatefulWidget {
  const ShippingDeliveryPolicyScreen({super.key});

  @override
  State<ShippingDeliveryPolicyScreen> createState() =>
      _ShippingDeliveryPolicyScreenState();
}

class _ShippingDeliveryPolicyScreenState
    extends State<ShippingDeliveryPolicyScreen> with TickerProviderStateMixin {
  bool isFabExpanded = false;
  late AnimationController _fabController;

  final Map<int, bool> expandedSections = {};

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void toggleFab() {
    setState(() {
      isFabExpanded = !isFabExpanded;
      isFabExpanded ? _fabController.forward() : _fabController.reverse();
    });
  }

  /// CARD DECORATION (SAME DESIGN)
  BoxDecoration responsiveCardDecoration(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(
        width < 600
            ? 14
            : width < 1024
                ? 18
                : 22,
      ),
      gradient: LinearGradient(
        colors: [Colors.white, Colors.grey.shade50],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: width < 600 ? 8 : 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Color sectionIndexColor() => AppColors.primaryAccent;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      /// WHITE APP BAR WITH SEPARATOR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ),
        title: const Text(
          "Shipping & Delivery Policy",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32 : 16,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// INTRO CARD
            Container(
              decoration: responsiveCardDecoration(context),
              padding: const EdgeInsets.all(16),
              child: const Text(
                "Shipping and Delivery Policy\n\n"
                "Effective Date: October 2025\n"
                "Last Updated: October 2025\n\n"
                "Welcome to Elfinic.com, operated by Elfinic Commerce Pvt Ltd (India) "
                "and Elfinic Commerce LLC (USA). This Shipping Policy explains how we "
                "process, dispatch, and deliver orders placed through our website and "
                "mobile application for both domestic and international customers.",
                style: TextStyle(fontSize: 15, height: 1.6),
              ),
            ),

            const SizedBox(height: 16),

            ...List.generate(shippingSections.length, (index) {
              final isLast = index == shippingSections.length - 1;

              return Column(
                children: [
                  _collapsibleSection(index + 1, shippingSections[index]),
                  if (!isLast) responsiveDivider(context),
                ],
              );
            }),

            const SizedBox(height: 30),
            Center(
              child: const Text(
                "© Elfinic.com | All rights reserved 2022 - 2026",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),

      /// SUPPORT FAB
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isFabExpanded) ...[
            FloatingActionButton(
              heroTag: "whatsapp",
              mini: true,
              backgroundColor: Colors.green,
              onPressed: () async {
                final Uri whatsappUri = Uri.parse("https://wa.me/917969094545");

                if (await canLaunchUrl(whatsappUri)) {
                  await launchUrl(
                    whatsappUri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  debugPrint("Could not open WhatsApp");
                }
              },
              child: Lottie.asset("assets/lottie/whatsapp.json", width: 26),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: "email",
              mini: true,
              backgroundColor: Colors.blue,
              onPressed: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'care@elfinic.com',
                  queryParameters: {
                    'subject': 'Support Request',
                    'body': 'Hello Elfinic Team,',
                  },
                );

                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  debugPrint('Could not launch email');
                }
              },
              child: Lottie.asset("assets/lottie/email.json", width: 26),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            backgroundColor: AppColors.primaryAccent,
            onPressed: toggleFab,
            child: Lottie.asset(
              "assets/lottie/Support.json",
              controller: _fabController,
              repeat: false,
              width: 36,
            ),
          ),
        ],
      ),
    );
  }

  /// COLLAPSIBLE SECTION (SAME BEHAVIOR)
  Widget _collapsibleSection(int index, PolicySection section) {
    final isExpanded = expandedSections[index] ?? false;
    final width = MediaQuery.of(context).size.width;

    final previewBullets =
        isExpanded ? section.bullets : section.bullets.take(2).toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: responsiveCardDecoration(context),
      padding: EdgeInsets.symmetric(
        horizontal: width < 600 ? 14 : 20,
        vertical: width < 600 ? 14 : 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sectionIndexColor(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  index.toString(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: TextStyle(
                    fontSize: width < 600 ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: isExpanded ? 0.5 : 0,
                  child: const Icon(Icons.expand_more),
                ),
                onPressed: () {
                  setState(() {
                    expandedSections[index] = !isExpanded;
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.intro,
                  style:
                      TextStyle(fontSize: width < 600 ? 14 : 15, height: 1.6),
                ),
                const SizedBox(height: 10),
                ...previewBullets.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("•  ", style: TextStyle(fontSize: 18)),
                        Expanded(
                          child: Text(
                            e,
                            style: TextStyle(
                                fontSize: width < 600 ? 14 : 15, height: 1.6),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                if (isExpanded && section.footer.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      section.footer,
                      style: TextStyle(
                          fontSize: width < 600 ? 14 : 15, height: 1.6),
                    ),
                  ),
                if (section.bullets.length > 2 || section.footer.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        expandedSections[index] = !isExpanded;
                      });
                    },
                    child: Text(isExpanded ? "Show Less" : "Show More"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// RESPONSIVE DIVIDER
  Widget responsiveDivider(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Divider(
      height: width < 600
          ? 24
          : width < 1024
              ? 32
              : 40,
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
}

/// DATA MODEL
class PolicySection {
  final String title;
  final String intro;
  final List<String> bullets;
  final String footer;

  PolicySection({
    required this.title,
    required this.intro,
    required this.bullets,
    required this.footer,
  });
}

/// SHIPPING POLICY DATA
final List<PolicySection> shippingSections = [
  PolicySection(
    title: "General Overview",
    intro:
        "At Elfinic, our goal is to ensure your orders reach you quickly, safely, and in excellent condition.",
    bullets: [
      "Shipments are dispatched from fulfillment centers in Mumbai and Bangalore.",
      "Partner warehouses may be used based on delivery location.",
    ],
    footer: "",
  ),
  PolicySection(
    title: "Shipping Coverage",
    intro: "We currently ship to:",
    bullets: [
      "All major cities, towns, and rural locations across India.",
      "International destinations including USA, UK, Canada, Australia, Europe, and select regions.",
    ],
    footer: "",
  ),
  PolicySection(
    title: "Domestic Shipping (India)",
    intro: "Processing & delivery details:",
    bullets: [
      "Orders processed within 24–48 hours (excluding holidays).",
      "Standard delivery: 3–6 business days.",
      "Remote areas may take longer.",
      "Free shipping on orders above ₹999.",
      "Orders below ₹999 may incur a delivery fee.",
    ],
    footer: "",
  ),
  PolicySection(
    title: "International Shipping",
    intro: "International order handling:",
    bullets: [
      "Processed within 48–72 hours of payment confirmation.",
      "Delivery in 10–15 business days.",
      "Delays possible due to customs or weather.",
    ],
    footer: "",
  ),
  PolicySection(
    title: "Customs, Duties & Taxes",
    intro: "International shipments:",
    bullets: [
      "May be subject to customs duties and import taxes.",
      "Charges are payable by the customer.",
      "Not included in product or shipping price.",
    ],
    footer: "Please contact your local customs office for more information.",
  ),
  PolicySection(
    title: "Order Tracking",
    intro: "Once your order is shipped, you will receive:",
    bullets: [
      "Courier name and tracking number.",
      "Estimated delivery window.",
      "Real-time tracking link.",
    ],
    footer:
        "You can also track orders via 'My Orders' in your Elfinic account.",
  ),
  PolicySection(
    title: "Delivery Issues",
    intro: "Elfinic is not responsible for:",
    bullets: [
      "Incorrect or incomplete addresses.",
      "Failed delivery due to unavailability.",
      "Return-to-origin parcels due to non-collection.",
    ],
    footer: "Re-delivery may incur additional charges.",
  ),
  PolicySection(
    title: "Damaged or Missing Items",
    intro: "If you receive a damaged or incomplete order:",
    bullets: [
      "Report within 48 hours of delivery.",
      "Email support@elfinic.com with photos/videos.",
    ],
    footer: "We will assist with replacement, refund, or store credit.",
  ),
  PolicySection(
    title: "Delivery Delays",
    intro: "Delays may occur due to:",
    bullets: [
      "Logistics network issues.",
      "Natural calamities or weather conditions.",
      "Customs or government restrictions.",
    ],
    footer: "Elfinic is not liable for delays beyond its control.",
  ),
];

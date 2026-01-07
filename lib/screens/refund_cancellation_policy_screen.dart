import 'package:elfinic_commerce_llc/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class RefundCancellationPolicyScreen extends StatefulWidget {
  const RefundCancellationPolicyScreen({super.key});

  @override
  State<RefundCancellationPolicyScreen> createState() =>
      _RefundCancellationPolicyScreenState();
}

class _RefundCancellationPolicyScreenState
    extends State<RefundCancellationPolicyScreen>
    with TickerProviderStateMixin {
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

  /// CARD DECORATION (SAME AS PRIVACY POLICY)
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
          "Refund & Cancellation Policy",
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
                "Refund and Cancellation Policy\n\n"
                "Effective Date: October 2025\n"
                "Last Updated: October 2025\n\n"
                "Thank you for shopping with Elfinic.com, operated by "
                "Elfinic Commerce Pvt Ltd (India) and Elfinic Commerce LLC (USA). "
                "This policy explains the terms for returning, exchanging, "
                "or cancelling items purchased from our website or mobile app.",
                style: TextStyle(fontSize: 15, height: 1.6),
              ),
            ),

            const SizedBox(height: 16),

            ...List.generate(refundSections.length, (index) {
              final isLast = index == refundSections.length - 1;
              return Column(
                children: [
                  _collapsibleSection(index + 1, refundSections[index]),
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
              onPressed: () {
                launchUrl(
                  Uri.parse("https://wa.me/1234567890"),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Lottie.asset("assets/lottie/whatsapp.json", width: 26),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: "email",
              mini: true,
              backgroundColor: Colors.blue,
              onPressed: () {
                launchUrl(Uri.parse("mailto:returns@elfinic.com"));
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

  /// COLLAPSIBLE SECTION (SAME LOGIC)
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
                      fontWeight: FontWeight.w600),
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
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.intro,
                    style: TextStyle(
                        fontSize: width < 600 ? 14 : 15, height: 1.6)),
                const SizedBox(height: 10),
                ...previewBullets.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("•  ", style: TextStyle(fontSize: 18)),
                        Expanded(
                          child: Text(e,
                              style: TextStyle(
                                  fontSize: width < 600 ? 14 : 15,
                                  height: 1.6)),
                        )
                      ],
                    ),
                  ),
                ),
                if (isExpanded && section.footer.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(section.footer,
                        style: TextStyle(
                            fontSize: width < 600 ? 14 : 15, height: 1.6)),
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

  PolicySection(
      {required this.title,
      required this.intro,
      required this.bullets,
      required this.footer});
}

/// REFUND POLICY DATA
final List<PolicySection> refundSections = [
  PolicySection(
    title: "General Policy",
    intro:
        "Elfinic allows returns, replacements, and exchanges for eligible products:",
    bullets: [
      "Subject to timelines and conditions in this policy.",
    ],
    footer: "",
  ),
  PolicySection(
    title: "Eligibility for Returns & Exchanges",
    intro: "A product is eligible if:",
    bullets: [
      "It is damaged, defective, incorrect, or incomplete on delivery.",
      "It is unused, unwashed, and in original condition with tags.",
      "Request raised within 7 days (India) or 10 days (International).",
    ],
    footer: "Non-returnable categories are listed in Section 8.",
  ),
  PolicySection(
    title: "Return / Exchange Process",
    intro: "To initiate a return:",
    bullets: [
      "Email returns@elfinic.com with order number and issue.",
      "Attach clear photos/videos of item and packaging.",
      "Team responds within 24–48 hours.",
      "Pickup arranged or return address shared.",
    ],
    footer: "Unauthorized returns may be refused.",
  ),
  PolicySection(
    title: "Exchange Policy",
    intro: "Exchanges are allowed:",
    bullets: [
      "For size/color issues or defects (subject to stock).",
      "Store credit or refund if replacement unavailable.",
    ],
    footer: "Processing begins after QC approval.",
  ),
  PolicySection(
    title: "Refunds",
    intro: "Refund timelines:",
    bullets: [
      "India: 5–7 business days.",
      "International: 7–10 business days.",
      "Shipping fees are non-refundable unless defective.",
    ],
    footer: "",
  ),
  PolicySection(
    title: "Return Shipping Costs",
    intro: "Shipping responsibility:",
    bullets: [
      "India: Free reverse pickup in most locations.",
      "International: Customer pays unless item is defective.",
    ],
    footer: "",
  ),
  PolicySection(
    title: "Damaged or Wrong Item",
    intro: "Report issues:",
    bullets: [
      "Within 48 hours of delivery.",
      "Email returns@elfinic.com with photos/videos.",
    ],
    footer: "",
  ),
  PolicySection(
    title: "Non-Returnable Items",
    intro: "Unless defective:",
    bullets: [
      "Personal care & grooming items.",
      "Innerwear, swimwear, lingerie.",
      "Food, customized products, gift cards.",
    ],
    footer: "",
  ),
  PolicySection(
    title: "Cancellation Policy",
    intro: "Orders can be cancelled:",
    bullets: [
      "Only before shipment.",
      "Prepaid refunds processed within 5 business days.",
    ],
    footer: "",
  ),
  PolicySection(
    title: "Order Not Delivered",
    intro: "If order is lost:",
    bullets: [
      "Email returns@elfinic.com with order ID.",
      "Reshipment or refund after investigation.",
    ],
    footer: "",
  ),
  PolicySection(
    title: "International Orders",
    intro: "Important notes:",
    bullets: [
      "Customs duties are non-refundable.",
      "Return shipping & penalties deducted if refused.",
      "Replacements may take longer.",
    ],
    footer: "",
  ),
];

import 'package:elfinic_commerce_llc/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with TickerProviderStateMixin {
  /// FAB
  bool isFabExpanded = false;
  late AnimationController _fabController;

  /// Section expand state
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

  /// 🔹 CARD DECORATION
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
        colors: [
          Colors.white,
          Colors.grey.shade50,
        ],
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

  /// 🔹 NUMBER BOX COLOR (SAME FOR 1–12)
  Color sectionIndexColor() => AppColors.primaryAccent;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,

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
          "Privacy Policy",
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
            /// 🔹 INTRO (ALWAYS VISIBLE)
            Container(
              decoration: responsiveCardDecoration(context),
              padding: const EdgeInsets.all(16),
              child: const Text(
                "This Privacy Policy describes how Elfinic Commerce Pvt Ltd (India) "
                "and Elfinic Commerce LLC (USA) collect, use, store, and protect your "
                "personal information when you access or use Elfinic.com and our "
                "mobile application.\n\n"
                "By using our website or mobile app, you agree to the terms of this "
                "Privacy Policy.",
                style: TextStyle(fontSize: 15, height: 1.6),
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 SECTIONS 1–12
            ...List.generate(privacySections.length, (index) {
              final isLast = index == privacySections.length - 1;

              return Column(
                children: [
                  _collapsibleSection(index + 1, privacySections[index]),
                  if (!isLast) responsiveDivider(context),
                ],
              );
            }),

            // const SizedBox(height: 90),
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

      /// 🔹 SUPPORT FAB (BOTTOM RIGHT)
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

  /// 🔹 COLLAPSIBLE SECTION
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
          /// HEADER
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    expandedSections[index] = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: isExpanded ? 0.5 : 0,
                    child: const Icon(Icons.expand_more),
                  ),
                ),
              ),
            ],
          ),

          /// CONTENT
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.intro,
                  style: TextStyle(
                    fontSize: width < 600 ? 14 : 15,
                    height: 1.6,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                ...previewBullets.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("•  ",
                            style: TextStyle(fontSize: 18, height: 1.4)),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: width < 600 ? 14 : 15,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isExpanded && section.footer.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    section.footer,
                    style: TextStyle(
                      fontSize: width < 600 ? 14 : 15,
                      height: 1.6,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
                if (section.bullets.length > 2 || section.footer.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          expandedSections[index] = !isExpanded;
                        });
                      },
                      child: Text(isExpanded ? "Show Less" : "Show More"),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 RESPONSIVE DIVIDER
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

/// 🔹 DATA MODEL
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

/// 🔹 ALL 12 SECTIONS
final List<PolicySection> privacySections = [
  PolicySection(
    title: "Scope",
    intro: "This Privacy Policy applies to:",
    bullets: [
      "All visitors and registered users of Elfinic.com and its mobile application.",
      "Any interaction through our online stores, marketing platforms, or customer service channels.",
    ],
    footer:
        "It does not apply to third-party websites or services linked to from Elfinic.com.",
  ),
  PolicySection(
    title: "Information We Collect",
    intro: "We collect information in the following categories:",
    bullets: [
      "Personal information such as name, email, phone number, and addresses.",
      "Payment details processed securely via third-party gateways.",
      "Device and technical data including IP address, browser type, app version, cookies, and analytics.",
      "Transaction details such as orders, refunds, loyalty rewards, and purchase history.",
      "Optional data including reviews, feedback, and support communications.",
    ],
    footer: "",
  ),
  PolicySection(
    title: "How We Use Your Information",
    intro: "We use collected data to:",
    bullets: [
      "Process and deliver orders.",
      "Manage accounts and preferences.",
      "Provide customer support and notifications.",
      "Improve website and app performance.",
      "Send marketing updates (with consent).",
      "Detect and prevent fraud.",
      "Comply with legal obligations.",
    ],
    footer: "We do not sell or rent your personal data to third parties.",
  ),
  PolicySection(
    title: "Cookies and Tracking Technologies",
    intro: "Elfinic uses cookies to:",
    bullets: [
      "Recognize returning users.",
      "Analyze traffic and behavior.",
      "Provide personalized experiences.",
    ],
    footer:
        "You can disable cookies via browser settings, though some features may be affected.",
  ),
  PolicySection(
    title: "Data Sharing and Disclosure",
    intro: "We may share data with:",
    bullets: [
      "Service providers such as logistics, payments, and analytics partners.",
      "Legal authorities when required by law.",
      "Business partners during mergers or acquisitions.",
    ],
    footer: "All third parties follow strict data protection obligations.",
  ),
  PolicySection(
    title: "Data Retention",
    intro: "We retain data only as necessary to:",
    bullets: [
      "Fulfill orders and services.",
      "Meet legal and accounting requirements.",
      "Resolve disputes.",
    ],
    footer: "Data is securely deleted or anonymized when no longer needed.",
  ),
  PolicySection(
    title: "Data Security",
    intro: "We use industry-standard safeguards including:",
    bullets: [
      "SSL encryption.",
      "Two-factor authentication.",
      "PCI DSS–compliant payment gateways.",
      "Firewalls and regular audits.",
    ],
    footer:
        "No system is completely secure; users share data at their own risk.",
  ),
  PolicySection(
    title: "Your Rights",
    intro: "You may have the right to:",
    bullets: [
      "Access or update your data.",
      "Request deletion.",
      "Withdraw marketing consent.",
      "Request a copy of stored data.",
    ],
    footer:
        "Contact privacy@elfinic.com or returns@elfinic.com to exercise these rights.",
  ),
  PolicySection(
    title: "Children’s Privacy",
    intro: "Our services are intended for:",
    bullets: [
      "Users aged 18 years or older.",
    ],
    footer: "If data from minors is discovered, it will be deleted promptly.",
  ),
  PolicySection(
    title: "International Data Transfers",
    intro: "Data may be transferred:",
    bullets: [
      "Between India and the USA.",
      "Across affiliated entities.",
    ],
    footer: "All transfers follow global data-protection standards.",
  ),
  PolicySection(
    title: "Third-Party Services",
    intro: "Our platform may link to:",
    bullets: [
      "Payment gateways.",
      "Logistics providers.",
      "Social media platforms.",
    ],
    footer: "Elfinic is not responsible for third-party privacy practices.",
  ),
  PolicySection(
    title: "Updates to This Policy",
    intro: "This policy may be updated:",
    bullets: [
      "To reflect legal changes.",
      "To improve transparency.",
    ],
    footer: "Updates will be posted with a revised “Last Updated” date.",
  ),
];

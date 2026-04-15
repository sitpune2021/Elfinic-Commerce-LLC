import 'package:cached_network_image/cached_network_image.dart';
import 'package:elfinic_commerce_llc/screens/VendorDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final provider =
    Provider.of<VendorProvider>(context, listen: false);

    provider.fetchVendors(isRefresh: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        provider.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: const Text(
          "Vendors",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF050040), // dark navy
                Color(0xFF0A0A80),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          /// 🔍 SEARCH BAR

          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                textAlign: TextAlign.start, // ✅ center text
                textAlignVertical: TextAlignVertical.center, // ✅ vertical center
                decoration: InputDecoration(
                  hintText: "Search vendors...",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF050040),
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD39841),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white, size: 20),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  context.read<VendorProvider>().search(value);
                },
              ),
            ),
          ),
          /// LIST
          Expanded(
            child: Consumer<VendorProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading &&
                    provider.vendors.isEmpty) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final vendors = provider.filteredVendors;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: vendors.length +
                      (provider.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == vendors.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final vendor = vendors[index];
                    return _vendorCard(vendor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 PREMIUM CARD
  Widget _vendorCard(Vendor vendor) {
    final hasLogo = vendor.companyLogo != null &&
        vendor.companyLogo!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VendorDetailScreen(
              vendorId: vendor.vendorId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xfff8f9ff)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            /// 🔥 LOGO / AVATAR
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFD39841), Color(0xFFFFC107)],
                ),
              ),
              child: hasLogo
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: vendor.companyLogo!,
                  fit: BoxFit.cover,
                ),
              )
                  : Center(
                child: Text(
                  (vendor.companyName.isNotEmpty
                      ? vendor.companyName[0]
                      : "V")
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            /// 🔥 DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// COMPANY NAME
                  Text(
                    vendor.companyName.isNotEmpty
                        ? vendor.companyName
                        : "No Company",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF050040),
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// OWNER NAME
                  // Text(
                  //   "👤 ${vendor.name}",
                  //   style: TextStyle(
                  //     color: Colors.grey.shade700,
                  //     fontSize: 13,
                  //   ),
                  // ),

                  // const SizedBox(height: 4),

                  /// PHONE
                  // Text(
                  //   "📞 ${vendor.phone ?? '-'}",
                  //   style: TextStyle(
                  //     color: Colors.grey.shade600,
                  //     fontSize: 12,
                  //   ),
                  // ),

                  // const SizedBox(height: 6),
                  //
                  // /// PLAN BADGE
                  // Container(
                  //   padding:
                  //   const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFFD39841).withOpacity(0.15),
                  //     borderRadius: BorderRadius.circular(6),
                  //   ),
                  //   child: Text(
                  //     vendor.planName ?? "Basic Plan",
                  //     style: const TextStyle(
                  //       fontSize: 11,
                  //       color: Color(0xFF050040),
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),

            /// 🔥 ACTIONS
           /* Column(
              children: [
                InkWell(
                  onTap: () {
                    if (vendor.phone != null &&
                        vendor.phone!.isNotEmpty) {
                      _makePhoneCall(vendor.phone!);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Colors.green,
                      size: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ],
            ),*/
          ],
        ),
      ),
    );
  }
}

Future<void> _makePhoneCall(String phone) async {
  final Uri url = Uri(scheme: 'tel', path: phone);

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    debugPrint("Could not launch dialer");
  }
}







class VendorProvider with ChangeNotifier {
  List<Vendor> vendors = [];

  bool isLoading = false;
  bool isLoadingMore = false;

  int currentPage = 1;
  final int perPage = 10;
  bool hasMore = true;

  String searchQuery = '';

  Future<void> fetchVendors({bool isRefresh = false}) async {
    if (isLoading) return;

    if (isRefresh) {
      currentPage = 1;
      vendors.clear();
      hasMore = true;
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          "https://admin.elfinic.com/api/vendor/getAllVendors?page=$currentPage&per_page=$perPage",
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List data = jsonData['data'];

        final newVendors =
        data.map((e) => Vendor.fromJson(e)).toList();

        if (newVendors.length < perPage) {
          hasMore = false;
        }

        vendors.addAll(newVendors);
        currentPage++;
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();

    await fetchVendors();

    isLoadingMore = false;
    notifyListeners();
  }

  void search(String query) {
    searchQuery = query.toLowerCase();
    notifyListeners();
  }

  List<Vendor> get filteredVendors {
    if (searchQuery.isEmpty) return vendors;

    return vendors.where((v) {
      return v.companyName.toLowerCase().contains(searchQuery) ||
          v.name.toLowerCase().contains(searchQuery);
    }).toList();
  }
}



class Vendor {
  final int vendorId;
  final int userId;

  final String? gstNo;
  final String? companyLogo;
  final String companyName;
  final String? companyEmail;
  final String? companyType;

  final String? website;
  final String? country;
  final String? state;
  final String? city;

  final String? countryCode;
  final String? phone;
  final String? turnover;

  final String name;
  final String? planName;

  Vendor({
    required this.vendorId,
    required this.userId,
    this.gstNo,
    this.companyLogo,
    required this.companyName,
    this.companyEmail,
    this.companyType,
    this.website,
    this.country,
    this.state,
    this.city,
    this.countryCode,
    this.phone,
    this.turnover,
    required this.name,
    this.planName,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      vendorId: json['vendor_id'] ?? 0,
      userId: json['user_id'] ?? 0,

      gstNo: json['gst_no'],
      companyLogo: json['company_logo'],
      companyName: json['company_name'] ?? '',
      companyEmail: json['company_email'],
      companyType: json['company_type'],

      website: json['website'],
      country: json['country'],
      state: json['state'],
      city: json['city'],

      countryCode: json['country_code'],
      phone: json['phone'],
      turnover: json['turnover'],

      name: json['name'] ?? '',
      planName: json['plan_name'],
    );
  }
}

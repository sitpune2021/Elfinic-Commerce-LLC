// ignore_for_file: file_names

import 'dart:io';

import 'package:elfinic_commerce_llc/providers/delete_%20Account/delete_account_provider.dart';
import 'package:elfinic_commerce_llc/providers/profile_provider.dart';
import 'package:elfinic_commerce_llc/screens/about_us_screen.dart';
import 'package:elfinic_commerce_llc/screens/update_password_screen.dart';
import 'package:elfinic_commerce_llc/widget/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:elfinic_commerce_llc/screens/DashboardScreen.dart' as dashboard;
import 'package:share_plus/share_plus.dart';
import '../model/cart_models.dart';
import '../providers/LogoutProvider.dart';
import '../providers/ShippingProvider.dart';
import 'CartScreen.dart';
import 'address_screen.dart';
import 'EditProfileScreen.dart';
import 'OrdersScreen.dart';
import 'WishlistScreen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchUserProfile();
    });
  }

// app version
  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${info.version} (${info.buildNumber})';
    });
  }

  void _onPopInvoked(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboard.DashboardScreen()),
    );
  }

  // app share
  void shareApp() {
    String url;

    if (Platform.isAndroid) {
      url =
          'https://play.google.com/store/apps/details?id=com.sit.elfinic_commerce_llc';
    } else if (Platform.isIOS) {
      url = 'https://apps.apple.com/app/idYOUR_IOS_APP_ID';
    } else {
      url = 'https://www.elfinic.com/';
    }

    Share.share(
      'Check out this app 👇\n\n$url',
      subject: 'Awesome App',
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => _buildLogoutDialog(context),
    );
    if (!context.mounted) return;

    if (confirmed == true) {
      final logoutProvider =
          Provider.of<LogoutProvider>(context, listen: false);

      await logoutProvider.logout("admin@gmail.com", "Shubham12");
      if (!context.mounted) return;
      if (logoutProvider.logoutResponse?.status == "success") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(logoutProvider.errorMessage ?? "Logout failed")),
        );
      }
    }
  }

  // fuction delete
  Future<void> _deleteAccount(BuildContext context) async {
    debugPrint("🟢 _deleteAccount() started");

    // Loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CustomLoader()),
    );

    final provider = Provider.of<DeleteAccountProvider>(context, listen: false);

    final success = await provider.deleteAccount(context);

    if (!context.mounted) return;

    Navigator.pop(context); // close loader

    if (success) {
      debugPrint("➡️ Navigating to Login");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account deleted successfully"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) {
          _onPopInvoked(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF050040), // Deep Indigo
                    Color(0xFFD39841), // Golden Amber
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.only(
                  top: 60, left: 20, right: 20, bottom: 30),
              child: Consumer<ProfileProvider>(builder: (context, provider, _) {
                // ⏳ LOADING
                if (provider.isLoading) {
                  return const SizedBox(
                    height: 70,
                    child: Center(
                      child: CustomLoader(),
                    ),
                  );
                }

                // ❌ NO DATA
                if (provider.profile == null) {
                  return const Text(
                    "Profile not available",
                    style: TextStyle(color: Colors.white),
                  );
                }

                final data = provider.profile?.data;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage:
                          (data?.photo != null && data!.photo!.isNotEmpty)
                              ? NetworkImage(data.photo!)
                              : null,
                      child: (data?.photo == null || data!.photo!.isEmpty)
                          ? const Icon(Icons.person,
                              color: Colors.white, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data?.name ?? "Guest User",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data?.mobile ?? "",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data?.email ?? "",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditProfileScreen()),
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        child: const Icon(Icons.edit, color: Color(0xFFD39841)),
                      ),
                    ),
                  ],
                );
              }),
            ),
            // Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 20),
                    const Text(
                      "Account Information",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "See your info & activity as a member of Elfinic.com",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    _buildListTile(Icons.shopping_bag_outlined, "Orders", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrdersScreen()),
                      );
                    }),
                    _buildListTile(Icons.favorite_border, "Wishlist", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WishlistScreen()),
                      );
                    }),
                    // _buildListTile(Icons.card_giftcard, "Rewards", () {
                    //   // Navigate to RewardsScreen
                    // }),
                    _buildListTile(
                      Icons.security_outlined,
                      "Update password",
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UpdatePasswordScreen(),
                          ),
                        );
                      },
                    ),

                    _buildListTile(Icons.location_on_outlined, "Address", () {
                      NavigationHelper.navigateToAddressScreen(
                        context: context,
                        fromProfile: true,
                      );
                    }),
                    _buildListTile(
                      Icons.share_outlined,
                      "Share with Friends",
                      () {
                        shareApp();
                      },
                    ),
                    _buildListTile(Icons.info_outline, "About Us", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AboutUsScreen()),
                      );
                    }),
                    _buildListTile(Icons.delete_outline, "Delete Account", () {
                      _showDeleteAccountDialog(context);
                    }),
                    _buildAppListTile(
                      Icons.system_update,
                      "App Version",
                      null,
                      showArrow: false,
                      trailing: Text(
                        _appVersion,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    Center(
                      child: Consumer<LogoutProvider>(
                        builder: (context, provider, child) {
                          return ElevatedButton.icon(
                            onPressed: provider.isLoading
                                ? null
                                : () => _logout(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                            ),
                            icon: provider.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CustomLoader(
                                        // strokeWidth: 2,
                                        // color: Colors.white,
                                        ),
                                  )
                                : const Icon(Icons.logout,
                                    color: Colors.white, size: 20),
                            label: Text(
                              provider.isLoading ? "Logging out..." : "Logout",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // delete wsheet
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.redAccent,
                    size: 34,
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                const Text(
                  "Delete Account?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 10),

                // Instructions
                Text(
                  "This action is permanent and cannot be undone.\n\n"
                  "• Your profile data will be removed\n"
                  "• Order history will be deleted\n"
                  "• You will lose access permanently",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Continue
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          debugPrint("⚠️ User confirmed account deletion");

                          Navigator.pop(context);
                          debugPrint("📤 Dialog closed");

                          debugPrint("🚀 Calling _deleteAccount()");

                          await _deleteAccount(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //app version widget
  Widget _buildAppListTile(
    IconData icon,
    String title,
    VoidCallback? onTap, {
    Widget? trailing,
    bool showArrow = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF050040).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF050040),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: trailing ??
            (showArrow
                ? const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                    size: 20,
                  )
                : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF050040).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF050040),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.grey,
          size: 20,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildLogoutDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
                size: 30,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            const Text(
              "Logout?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              "Are you sure you want to logout from your account?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: Colors.grey[300]!,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Logout Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                      shadowColor: Colors.redAccent.withValues(alpha: 0.3),
                    ),
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationHelper {
  static Future<void> navigateToAddressScreen({
    required BuildContext context,
    bool fromProfile = false,
    double? subtotalAmount,
    List<UserCartItem>? cartItems,
  }) async {
    // Get providers from context
    final addressProvider =
        Provider.of<AddressProvider>(context, listen: false);
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);

    // Fetch addresses if needed
    if (addressProvider.addresses.isEmpty) {
      await addressProvider.fetchAddresses();
    }
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: addressProvider),
            ChangeNotifierProvider.value(value: couponProvider),
          ],
          child: AddressScreen(
            fromProfile: fromProfile,
            subtotalAmount: subtotalAmount ?? 0.0,
            cartItems: cartItems ?? [],
            appliedCoupon: couponProvider.appliedCoupon,
            couponDiscount: couponProvider.couponDiscount,
          ),
        ),
      ),
    );
  }
}

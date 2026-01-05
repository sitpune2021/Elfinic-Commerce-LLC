import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../model/cart_models.dart';
import '../providers/CartProvider.dart';
import '../providers/ShippingProvider.dart';
import '../services/api_service.dart';
import '../utils/BaseScreen.dart';
import '../utils/lottie_overlay.dart';
import 'ProductDetailPage.dart';
import 'ProfileScreen.dart';

import 'package:elfinic_commerce_llc/screens/DashboardScreen.dart' as dashboard;
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  final bool fromProductDetail;
  final bool fromNavBar;

  const CartScreen({
    super.key,
    this.fromProductDetail = false,
    this.fromNavBar = false,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isApplyingPromo = false;
  final bool _showSuccessAnimation = false;
  final TextEditingController _promoCodeController = TextEditingController();
  late CouponProvider _couponProvider;

  @override
  void initState() {
    super.initState();
    _initializeCart();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _couponProvider = Provider.of<CouponProvider>(context, listen: false);
      _couponProvider.loadAppliedCoupon();
      _couponProvider.fetchCoupons();
    });
  }

  void _initializeCart() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      if (cartProvider.cartItems.isEmpty) {
        await cartProvider.fetchCartItems();
      } else {
        cartProvider.selectAll();
      }

      if (!mounted) return;
      // Update coupon provider subtotal
      final subtotal = _calculateSubtotal(cartProvider);
      final couponProvider =
          Provider.of<CouponProvider>(context, listen: false);
      couponProvider.setSubtotal(subtotal);
    });
  }

  Future<void> _refreshCartData() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.fetchCartItems();

    if (!mounted) return;

    // Update subtotal in coupon provider
    final subtotal = _calculateSubtotal(cartProvider);
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);
    couponProvider.setSubtotal(subtotal);
  }

  void _onPopInvoked(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboard.DashboardScreen()),
    );
  }

  Future<void> _applyPromoCode() async {
    final couponCode = _promoCodeController.text.trim();

    if (couponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a promo code')),
      );
      return;
    }

    setState(() => _isApplyingPromo = true);

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final couponProvider = Provider.of<CouponProvider>(context, listen: false);

    final selectedItems = cartProvider.getSelectedCartItems();

    if (selectedItems.isEmpty) {
      setState(() => _isApplyingPromo = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select items to apply coupon')),
      );
      return;
    }

    // ✅ Get userId safely from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString("user_id");
    final userId = int.tryParse(userIdString ?? '');

    if (userId == null || userId == 0) {
      setState(() => _isApplyingPromo = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    // ✅ APPLY COUPON
    final result = await couponProvider.applyCoupon(
      couponCode,
      selectedItems,
      userId,
    );

    setState(() => _isApplyingPromo = false);

    if (result['success'] == true) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Coupon applied'),
          backgroundColor: Colors.green,
        ),
      );

      // Keep coupon visible in input
      _promoCodeController.text = couponCode; // ✅ show applied coupon
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to apply coupon'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double _getUnitPrice(UserCartProduct product) {
    try {
      final originalPrice =
          double.tryParse(product.price.replaceAll(',', '')) ?? 0;
      final discountValue =
          double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;
      return discountValue < originalPrice
          ? originalPrice - discountValue
          : discountValue;
    } catch (e) {
      return double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;
    }
  }

  double _calculateSubtotal(CartProvider cartProvider) {
    double total = 0.0;
    for (final item in cartProvider.cartItems) {
      if (cartProvider.isSelected(item)) {
        final unitPrice = _getUnitPrice(item.product);
        total += item.quantity * unitPrice;
      }
    }
    return total;
  }

  String formatPrice(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final cartItems = cartProvider.cartItems;
        final isLoading = cartProvider.isLoading;
        final allSelected = cartItems.isNotEmpty &&
            cartProvider.selectedCount == cartItems.length;
        final subtotal = _calculateSubtotal(cartProvider);

        return Consumer<CouponProvider>(
          builder: (context, couponProvider, __) {
            // Update coupon provider subtotal whenever it changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              couponProvider.setSubtotal(subtotal);

              final selectedItems = cartProvider.getSelectedCartItems();
              couponProvider.validateAppliedCoupon(selectedItems);
              final removed =
                  couponProvider.validateAppliedCoupon(selectedItems);

              if (removed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Applied coupon removed as it is no longer applicable'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            });

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (bool didPop, Object? result) {
                if (!didPop) {
                  _onPopInvoked(context);
                }
              },
              child: BaseScreen(
                child: LottieOverlay(
                  child: Scaffold(
                    backgroundColor: const Color(0xffffffff),
                    body: isLoading && cartItems.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : cartItems.isEmpty
                            ? _buildEmptyCart()
                            : _buildCartWithItems(
                                cartProvider,
                                couponProvider,
                                cartItems,
                                allSelected,
                                subtotal,
                              ),
                    bottomNavigationBar: cartItems.isEmpty
                        ? null
                        : _buildBottomNavigationBar(
                            cartProvider,
                            couponProvider,
                            subtotal,
                          ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCartWithItems(
    CartProvider cartProvider,
    CouponProvider couponProvider,
    List<UserCartItem> cartItems,
    bool allSelected,
    double subtotal,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        leading: widget.fromNavBar
            ? null // Don't show back button when from navbar
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if (widget.fromProductDetail) {
                    Navigator.pop(context); // Go back to ProductDetailScreen
                  } else {
                    _refreshCartData();
                    _onPopInvoked(context); // Go to DashboardScreen
                  }
                },
              ),
        automaticallyImplyLeading: !widget.fromNavBar,
        title: Text(
          "Cart (${cartItems.length} items)",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (allSelected) {
                    cartProvider.clearSelection();
                  } else {
                    cartProvider.selectAll();
                  }
                },
                child: Text(
                  allSelected ? "Deselect all" : "Select all",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCartData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              // Cart Items List
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: cartItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return CartItemWidget(
                    key: ValueKey('${item.cartId}_${item.quantity}'),
                    item: item,
                    onQuantityChanged: _refreshCartData,
                  );
                },
              ),

              // Promo Code and Note Section
              _buildPromoAndNoteSection(couponProvider, subtotal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              "Your cart is empty",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Add some items to get started",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () => _onPopInvoked(context),
              child: const Text(
                "Continue Shopping",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoAndNoteSection(
      CouponProvider couponProvider, double subtotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Applied Coupon Section
          // if (couponProvider.hasAppliedCoupon)
          // _buildAppliedCouponSection(couponProvider),

          // Promo Code Section
          _buildPromoCodeSection(couponProvider),
          const SizedBox(height: 20),

          // Coupon Section
          _buildMyCouponsSection(),
          const SizedBox(height: 20),

          // Add Note Section
          // _buildAddNoteSection(),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection(CouponProvider couponProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.star, color: Colors.black54),
            SizedBox(width: 8),
            Text(
              "Promo Code",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _promoCodeController,
                decoration: InputDecoration(
                  hintText: "e.g. YEAREND#2025",
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        BorderSide(color: Colors.blue.shade300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        BorderSide(color: Colors.blue.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        BorderSide(color: Colors.blue.shade300, width: 1),
                  ),
                  suffixIcon: const Icon(Icons.local_offer_outlined,
                      color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildApplyButton(),
          ],
        ),

        // Available coupons dropdown
        if (couponProvider.coupons.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Available Coupons:",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: couponProvider.coupons.length,
                    itemBuilder: (context, index) {
                      final coupon = couponProvider.coupons[index];
                      final cartProvider =
                          Provider.of<CartProvider>(context, listen: false);
                      final selectedItems = cartProvider.getSelectedCartItems();

                      final isValid =
                          couponProvider.isCouponValid(coupon, selectedItems);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(coupon.code),
                          selected: false,
                          onSelected: (selected) {
                            if (selected && isValid) {
                              _promoCodeController.text = coupon.code;
                            }
                          },
                          backgroundColor: isValid
                              ? Colors.blue.shade50
                              : Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isValid ? Colors.blue : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildApplyButton() {
    if (_showSuccessAnimation) {
      return SizedBox(
        width: 60,
        height: 48,
        child: Lottie.asset(
          'assets/animations/shop_bag.json',
          fit: BoxFit.contain,
          repeat: false,
        ),
      );
    }

    return _isApplyingPromo
        ? SizedBox(
            width: 60,
            height: 48,
            child: Lottie.asset(
              'assets/animations/shop_bag.json',
              fit: BoxFit.contain,
              repeat: false,
            ),
          )
        : SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF050040),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _applyPromoCode,
              child: const Text(
                "APPLY",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
  }

  Widget _buildMyCouponsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Coupons",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final selectedCoupon = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllCouponsScreen(),
                    ),
                  );

                  if (selectedCoupon != null && selectedCoupon.isNotEmpty) {
                    setState(() {
                      _promoCodeController.text =
                          selectedCoupon; // 👈 Autofill textfield
                    });

                    // Optional: auto apply
                    _applyPromoCode();
                  }
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Consumer<CouponProvider>(
            builder: (context, couponProvider, _) {
              if (couponProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (couponProvider.coupons.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.local_offer_outlined, color: Colors.grey),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "No coupons available right now",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show first 2 coupons
              final cartProvider =
                  Provider.of<CartProvider>(context, listen: false);
              final selectedItems = cartProvider.getSelectedCartItems();

              final displayedCoupons = couponProvider.coupons
                  .where((c) => couponProvider.isCouponValid(c, selectedItems))
                  .take(2)
                  .toList();

              if (displayedCoupons.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "No coupons applicable for selected items",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: displayedCoupons.map((coupon) {
                  return _couponCard(
                    coupon: coupon,
                    onTap: () {
                      _promoCodeController.text = coupon.code;
                      _applyPromoCode();
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _couponCard({
    required Coupon coupon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFFFF5E0), Color(0xFFF2E3FF)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_offer,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.code,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coupon.discountText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Min. order: ₹${formatPrice(coupon.minimumAmount)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    'Valid until',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    "${coupon.endDate.day.toString().padLeft(2, '0')}/"
                    "${coupon.endDate.month.toString().padLeft(2, '0')}/"
                    "${coupon.endDate.year}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(CartProvider cartProvider,
      CouponProvider couponProvider, double subtotal) {
    final finalAmount =
        couponProvider.hasAppliedCoupon ? couponProvider.finalAmount : subtotal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Coupon discount row
          if (couponProvider.hasAppliedCoupon)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Subtotal",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "₹${formatPrice(subtotal)}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

          if (couponProvider.hasAppliedCoupon)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Discount (${couponProvider.appliedCoupon!.code})",
                    style: const TextStyle(color: Colors.green),
                  ),
                  Text(
                    "-₹${formatPrice(couponProvider.couponDiscount)}",
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),

          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "₹${formatPrice(finalAmount)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    couponProvider.hasAppliedCoupon ? "Total" : "Subtotal",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: cartProvider.selectedCount > 0
                    ? () => _navigateToCheckout(cartProvider, finalAmount)
                    : null,
                child: Text(
                  "CHECKOUT (${cartProvider.selectedCount} ${cartProvider.selectedCount == 1 ? 'item' : 'items'})",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToCheckout(
      CartProvider cartProvider, double finalAmount) async {
    final selectedItems = cartProvider.getSelectedCartItems();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select items to checkout'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Get existing AddressProvider from widget tree
      final addressProvider =
          Provider.of<AddressProvider>(context, listen: false);
      Provider.of<CouponProvider>(context, listen: false);

      // Fetch addresses before navigation
      await addressProvider.fetchAddresses();

      if (mounted) Navigator.of(context).pop();
      if (!mounted) return;

      await NavigationHelper.navigateToAddressScreen(
        context: context,
        fromProfile: false,
        subtotalAmount: finalAmount,
        cartItems: selectedItems,
      );

      // Refresh cart after returning from checkout
      await _refreshCartData();
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// All Coupons Screen
class AllCouponsScreen extends StatefulWidget {
  const AllCouponsScreen({super.key});

  @override
  State<AllCouponsScreen> createState() => _AllCouponsScreenState();
}

class _AllCouponsScreenState extends State<AllCouponsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final couponProvider =
          Provider.of<CouponProvider>(context, listen: false);
      couponProvider.fetchCoupons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Coupons'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Consumer<CouponProvider>(
        builder: (context, couponProvider, _) {
          if (couponProvider.isLoading && couponProvider.coupons.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (couponProvider.coupons.isEmpty) {
            return const Center(
              child: Text('No coupons available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: couponProvider.coupons.length,
            itemBuilder: (context, index) {
              final coupon = couponProvider.coupons[index];
              final cartProvider =
                  Provider.of<CartProvider>(context, listen: false);
              final selectedItems = cartProvider.getSelectedCartItems();

              final isValid =
                  couponProvider.isCouponValid(coupon, selectedItems);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isValid
                                  ? Colors.orange.shade100
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.local_offer,
                                color: isValid ? Colors.orange : Colors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              coupon.code,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isValid ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isValid
                                  ? Colors.green.shade100
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              coupon.discountText,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isValid ? Colors.green : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Minimum order: ₹${coupon.minimumAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Valid: ${coupon.startDate} to ${coupon.endDate}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Usage: ${coupon.usedCount}/${coupon.maxUsage}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isValid)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context, coupon.code);
                            },
                            child: const Text(
                              'Apply Coupon',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Not Applicable',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CouponGridScreen extends StatelessWidget {
  final String title;

  const CouponGridScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<CouponProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final coupons = provider.coupons;

          if (coupons.isEmpty) {
            return const Center(child: Text("No coupons available"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: coupons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              final cartProvider =
                  Provider.of<CartProvider>(context, listen: false);
              final selectedItems = cartProvider.getSelectedCartItems();

              final disabled = !provider.isCouponValid(coupon, selectedItems);

              return Opacity(
                opacity: disabled ? 0.5 : 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD39841), Color(0xFFA9D4E7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_offer_rounded,
                            size: 48, color: Colors.white),
                        const SizedBox(height: 10),
                        Text(
                          coupon.code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          coupon.discountText,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Min ₹${coupon.minimumAmount.toInt()}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          coupon.couponStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: coupon.isValid
                                ? Colors.greenAccent
                                : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final UserCartItem item;
  final VoidCallback? onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.item,
    this.onQuantityChanged,
  });

  Future<void> _updateQuantity(BuildContext context, int newQuantity) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    try {
      await cartProvider.updateQuantity(item, newQuantity);

      if (onQuantityChanged != null) {
        onQuantityChanged!();
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update quantity: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double _getUnitPrice(UserCartProduct product) {
    try {
      final originalPrice =
          double.tryParse(product.price.replaceAll(',', '')) ?? 0;
      final discountValue =
          double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;

      // If discountValue is less than original price, treat it as discount amount
      // Otherwise, treat it as final price
      return discountValue < originalPrice
          ? originalPrice - discountValue
          : discountValue;
    } catch (e) {
      return double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;
    }
  }

  String _calculateDiscountedPrice(UserCartProduct product) {
    return formatPrice(_getUnitPrice(product));
  }

// doublle pass
  String formatPrice(double value) {
    // If value has no decimal part → show as int
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    // Otherwise show up to 2 decimals (no trailing zeros)
    return value
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final product = item.product;
        final unitPrice = _getUnitPrice(product);
        final totalPrice = item.quantity * unitPrice;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: cartProvider.isSelected(item),
                    onChanged: (_) => cartProvider.toggleSelection(item),
                    activeColor: Colors.orange,
                  ),
                  GestureDetector(
                    onTap: () => _openProduct(context, product),
                    child: _buildProductImage(product),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openProduct(context, product),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                "₹${product.price}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "₹${_calculateDiscountedPrice(product)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Qty: ${item.quantity}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            "Size: ${product.variants.isNotEmpty ? product.variants.first.variant : 'N/A'}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteBottomSheet(
                      context,
                      item,
                      (cartId) async {
                        await Provider.of<CartProvider>(context, listen: false)
                            .removeFromCart(item, context);

                        if (onQuantityChanged != null) {
                          onQuantityChanged!();
                        }
                      },
                    ),
                  )
                ],
              ),

              // Quantity Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: () =>
                              _updateQuantity(context, item.quantity - 1),
                        ),
                        Text(
                          item.quantity.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () =>
                              _updateQuantity(context, item.quantity + 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "₹${formatPrice(totalPrice)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductImage(UserCartProduct product) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD39841), width: 0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 70,
          height: 70,
          color: Colors.grey.shade100,
          child: _buildOptimizedImage(product.thumb),
        ),
      ),
    );
  }

  void _openProduct(BuildContext context, UserCartProduct product) {
    if (kDebugMode) {
      print('🛒 Cart product tapped: ${product.name}');
      print('🛒 Product ID: ${product.id}');
      print('🛒 Product Slug: ${product.slug}');
    }

    if (product.slug == null || product.slug!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product details not available")),
      );
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailScreen(
          slug: product.slug!, // ✅ Cart → ProductDetail via slug
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildOptimizedImage(String? thumb) {
    if (thumb == null || thumb.isEmpty) {
      return Image.asset(
        'assets/images/no_product_img2.png',
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      );
    }

    final imageUrl = "${ApiService.baseUrl}/assets/img/products-thumbs/$thumb";

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,

        // 🔥 Cache optimization (VERY IMPORTANT)
        memCacheWidth: 140, // 2x for better quality on high DPI
        memCacheHeight: 140,
        maxWidthDiskCache: 140,
        maxHeightDiskCache: 140,

        // 🔥 Fade-in animation
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 200),

        // 🔥 Shimmer loader
        placeholder: (context, url) => _thumbShimmer(),

        // 🔥 Error fallback
        errorWidget: (context, url, error) {
          debugPrint("❌ Thumb image failed: $imageUrl");
          return Image.asset(
            'assets/images/no_product_img2.png',
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  Widget _thumbShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 70,
        height: 70,
        color: Colors.white,
      ),
    );
  }

  void _showDeleteBottomSheet(
      BuildContext context, UserCartItem item, Function(int) onDelete) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 32,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Want to remove item?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Are you sure to remove the product from cart?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.indigo.shade900),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "NO",
                        style: TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        onDelete(item.cartId);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "YES, DELETE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class CouponProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Coupon> _coupons = [];
  Coupon? _appliedCoupon;
  double _couponDiscount = 0.0;
  double _subtotal = 0.0;

  // Getters
  bool get isLoading => _isLoading;

  String? get error => _error;

  List<Coupon> get coupons => List.unmodifiable(_coupons);

  Coupon? get appliedCoupon => _appliedCoupon;

  double get couponDiscount => _couponDiscount;

  double get subtotal => _subtotal;

  bool get hasAppliedCoupon => _appliedCoupon != null;

  // Set subtotal (called from cart)
  void setSubtotal(double amount) {
    _subtotal = amount;
    // Recalculate discount if coupon is applied
    if (_appliedCoupon != null) {
      _calculateDiscount(_appliedCoupon!);
    }
    notifyListeners();
  }

  // Fetch active coupons
  Future<void> fetchCoupons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.fetchActiveCoupons();

      if (response.isSuccess) {
        // ✅ FIX
        _coupons = response.data;
      } else {
        _error = response.message;
        _coupons = [];
      }
    } catch (e) {
      _error = e.toString();
      _coupons = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply coupon
  Future<Map<String, dynamic>> applyCoupon(
    String couponCode,
    List<UserCartItem> selectedItems,
    int userId,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.applyCoupon(
        userId: userId,
        couponCode: couponCode,
        cartItems: selectedItems,
        subtotal: _subtotal,
      );

      _couponDiscount = response.pricing.totalDiscount;
      final apiCoupon = _coupons.firstWhere(
        (c) => c.code == couponCode,
        orElse: () => throw Exception("Coupon not found"),
      );

      _appliedCoupon = apiCoupon;
      _couponDiscount = response.pricing.totalDiscount;

      return {
        'success': true,
        'discount': response.pricing.totalDiscount,
        'payable_amount': response.pricing.totalPayableAmount,
        'message': response.coupon?.message ?? 'Coupon applied',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove applied coupon
  Future<Map<String, dynamic>> removeCoupon() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.removeCoupon();

      if (result['success'] == true) {
        _appliedCoupon = null;
        _couponDiscount = 0.0;

        // Remove from shared preferences
        await _removeAppliedCoupon();

        return {
          'success': true,
          'message': result['message'],
        };
      } else {
        return {
          'success': false,
          'message': result['message'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error removing coupon: $e',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate discount locally
  void _calculateDiscount(Coupon coupon) {
    if (coupon.isPercent) {
      _couponDiscount = (_subtotal * coupon.discountValue) / 100;
    } else {
      _couponDiscount = coupon.discountValue;
    }

    if (_couponDiscount > _subtotal) {
      _couponDiscount = _subtotal;
    }
  }

  // Calculate final amount after discount
  double get finalAmount {
    return _subtotal - _couponDiscount;
  }

  // Check if coupon is valid for current cart
  bool isCouponValid(Coupon coupon, List<UserCartItem> selectedItems) {
    if (!coupon.isUsable) return false;
    if (!coupon.isValidForAmount(_subtotal)) return false;

    // Product based validation
    if (coupon.productIds.isNotEmpty) {
      final selectedProductIds =
          selectedItems.map((e) => e.product.id).toList();

      final hasMatch =
          selectedProductIds.any((id) => coupon.productIds.contains(id));

      if (!hasMatch) return false;
    }

    return true;
  }

  // Load applied coupon from shared preferences
  Future<void> loadAppliedCoupon() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final couponJson = prefs.getString('applied_coupon');

      if (couponJson != null) {
        final Map<String, dynamic> data = json.decode(couponJson);
        _appliedCoupon = Coupon.fromJson(data);
        _couponDiscount = prefs.getDouble('coupon_discount') ?? 0.0;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading applied coupon: $e');
      }
    }
  }

  // Save applied coupon to shared preferences

  // Remove applied coupon from shared preferences
  Future<void> _removeAppliedCoupon() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('applied_coupon');
      await prefs.remove('coupon_discount');
    } catch (e) {
      if (kDebugMode) {
        print('Error removing applied coupon: $e');
      }
    }
  }

  // Clear all data
  void clear() {
    _coupons.clear();
    _appliedCoupon = null;
    _couponDiscount = 0.0;
    _error = null;
    notifyListeners();
  }

  bool validateAppliedCoupon(List<UserCartItem> selectedItems) {
    if (_appliedCoupon == null) return false;

    final isStillValid = isCouponValid(_appliedCoupon!, selectedItems);

    if (!isStillValid) {
      _appliedCoupon = null;
      _couponDiscount = 0.0;
      notifyListeners();
      return true;
    }
    return false;
  }
}

class Coupon {
  final int id;
  final String code;
  final String? title;
  final String? description;
  final String discountType; // flat / percent
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> productIds;
  final String termCondition;
  final double minimumAmount;
  final int maxUsage;
  final int usedCount;
  final String couponStatus;

  Coupon({
    required this.id,
    required this.code,
    this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    required this.productIds,
    required this.termCondition,
    required this.minimumAmount,
    required this.maxUsage,
    required this.usedCount,
    required this.couponStatus,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: int.tryParse(json['id'].toString()) ?? 0,
      code: json['code'] ?? '',
      title: json['title'],
      description: json['description'],
      discountType: json['discount_type'] ?? '',
      discountValue: double.tryParse(json['discount_value'].toString()) ?? 0,
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      productIds: _parseProductIds(json['product_id']),
      termCondition: json['term_condition'] ?? '',
      minimumAmount: double.tryParse(json['minimum_amount'].toString()) ?? 0,
      maxUsage: int.tryParse(json['max_usage'].toString()) ?? 0,
      usedCount: int.tryParse(json['used_count'].toString()) ?? 0,
      couponStatus: json['coupon_status'] ?? '',
    );
  }

  static List<int> _parseProductIds(dynamic value) {
    if (value == null || value.toString().isEmpty) return [];
    return value
        .toString()
        .split(',')
        .map((e) => int.tryParse(e.trim()) ?? 0)
        .where((e) => e > 0)
        .toList();
  }

  // ---------- HELPERS ----------

  bool get isValid => couponStatus.toLowerCase() == 'valid';

  bool get isPercent => discountType == 'percent';

  bool isValidForAmount(double amount) => amount >= minimumAmount;

  bool isApplicableToProduct(int productId) {
    if (productIds.isEmpty) return true;
    return productIds.contains(productId);
  }

  bool get isUsable {
    final now = DateTime.now();
    return isValid &&
        now.isAfter(startDate.subtract(const Duration(days: 1))) &&
        now.isBefore(endDate.add(const Duration(days: 1))) &&
        usedCount < maxUsage;
  }

  String get discountText {
    if (isPercent) {
      return "${discountValue.toInt()}% OFF";
    } else {
      return "₹${discountValue.toInt()} OFF";
    }
  }
}

class CouponResponse {
  final String status;
  final String message;
  final List<Coupon> data;

  CouponResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    return CouponResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Coupon.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  bool get isSuccess => status.toLowerCase() == 'success';
}

class ApplyCouponRequest {
  final int userId;
  final String couponCode;
  final CouponCart cart;

  ApplyCouponRequest({
    required this.userId,
    required this.couponCode,
    required this.cart,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "coupon_code": couponCode,
      "cart": cart.toJson(),
    };
  }
}

class CouponCart {
  final List<CouponCartItem> items;
  final double cartSubtotal;

  CouponCart({
    required this.items,
    required this.cartSubtotal,
  });

  Map<String, dynamic> toJson() {
    return {
      "items": items.map((e) => e.toJson()).toList(),
      "cart_subtotal": cartSubtotal.toInt(),
    };
  }
}

class CouponCartItem {
  final int productId;
  final int? variantId;
  final int quantity;
  final double clientPrice;

  CouponCartItem({
    required this.productId,
    this.variantId,
    required this.quantity,
    required this.clientPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "variant_id": variantId,
      "quantity": quantity,
      "client_price": clientPrice.toInt(),
    };
  }
}

class ApplyCouponResponse {
  final bool success;
  final CouponInfo? coupon;
  final PricingInfo pricing;
  final List<ItemDiscount> itemDiscounts;

  ApplyCouponResponse({
    required this.success,
    this.coupon,
    required this.pricing,
    required this.itemDiscounts,
  });

  factory ApplyCouponResponse.fromJson(Map<String, dynamic> json) {
    return ApplyCouponResponse(
      success: json['success'] == 'success',
      coupon:
          json['coupon'] != null ? CouponInfo.fromJson(json['coupon']) : null,
      pricing: PricingInfo.fromJson(json['pricing']),
      itemDiscounts: (json['item_discounts'] as List? ?? [])
          .map((e) => ItemDiscount.fromJson(e))
          .toList(),
    );
  }
}

class CouponInfo {
  final int id;
  final String code;
  final String type;
  final String message;

  CouponInfo({
    required this.id,
    required this.code,
    required this.type,
    required this.message,
  });

  factory CouponInfo.fromJson(Map<String, dynamic> json) {
    return CouponInfo(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class PricingInfo {
  final double totalDiscount;
  final double cartSubtotal;
  final double totalPayableAmount;

  PricingInfo({
    required this.totalDiscount,
    required this.cartSubtotal,
    required this.totalPayableAmount,
  });

  factory PricingInfo.fromJson(Map<String, dynamic> json) {
    return PricingInfo(
      totalDiscount: double.tryParse(json['total_discount'].toString()) ?? 0,
      cartSubtotal: double.tryParse(json['cart_subtotal'].toString()) ?? 0,
      totalPayableAmount:
          double.tryParse(json['total_payable_amount'].toString()) ?? 0,
    );
  }
}

class ItemDiscount {
  final int productId;
  final int? variantId;
  final double discountAmount;

  ItemDiscount({
    required this.productId,
    this.variantId,
    required this.discountAmount,
  });

  factory ItemDiscount.fromJson(Map<String, dynamic> json) {
    return ItemDiscount(
      productId: json['product_id'] ?? 0,
      variantId: json['variant_id'],
      discountAmount: double.tryParse(json['discount_amount'].toString()) ?? 0,
    );
  }
}

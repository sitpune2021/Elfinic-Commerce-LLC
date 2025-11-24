import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/AddressModel.dart';
import '../model/cart_models.dart';
import '../providers/CartProvider.dart';
import '../providers/ShippingProvider.dart';
import '../services/api_service.dart';
import '../utils/BaseScreen.dart';
import '../utils/lottie_overlay.dart';
import 'AddressListScreen.dart';
import 'address_screen.dart';
import 'DashboardScreen.dart';
import 'EditAddressScreen.dart';
import 'ShoppingScreen.dart';

import 'package:elfinic_commerce_llc/screens/DashboardScreen.dart' as dashboard;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'delivery_screen.dart';






class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isApplyingPromo = false;
  bool _showSuccessAnimation = false;
  final TextEditingController _promoCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  void _initializeCart() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      if (cartProvider.cartItems.isEmpty) {
        await cartProvider.fetchCartItems();
      } else {
        // Ensure selection for existing items
        cartProvider.selectAll();
      }
    });
  }

  Future<void> _refreshCartData() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.fetchCartItems();
  }

  // Handle back button press
  void _onPopInvoked(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboard.DashboardScreen()),
    );
  }

  Future<void> _applyPromoCode() async {
    if (_promoCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a promo code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isApplyingPromo = true);

    await Future.delayed(const Duration(seconds: 2));
    bool isValid = _validatePromoCode(_promoCodeController.text.trim());

    setState(() => _isApplyingPromo = false);

    if (isValid) {
      setState(() => _showSuccessAnimation = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo code ${_promoCodeController.text} applied successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      _promoCodeController.clear();

      // Hide animation after completion
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showSuccessAnimation = false);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid promo code: ${_promoCodeController.text}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validatePromoCode(String code) {
    List<String> validCodes = ['SAVE50', 'WELCOME10', 'FLAT20', 'SUMMER25'];
    return validCodes.contains(code.toUpperCase());
  }

  // Helper method to calculate unit price
  double _getUnitPrice(UserCartProduct product) {
    try {
      final originalPrice = double.tryParse(product.price.replaceAll(',', '')) ?? 0;
      final discountValue = double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;
      return discountValue < originalPrice ? originalPrice - discountValue : discountValue;
    } catch (e) {
      return double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;
    }
  }

  // Calculate subtotal for selected items
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

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) {
              _onPopInvoked(context);
            }
          },
          child: SafeArea(
            child: LottieOverlay(
              child: Scaffold(
                backgroundColor: const Color(0xfffdf6ef),
                body: isLoading && cartItems.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : cartItems.isEmpty
                    ? _buildEmptyCart()
                    : _buildCartWithItems(cartProvider, cartItems, allSelected),
                bottomNavigationBar: cartItems.isEmpty ? null : _buildBottomNavigationBar(cartProvider),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartWithItems(CartProvider cartProvider, List<UserCartItem> cartItems, bool allSelected) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  _refreshCartData();
                  _onPopInvoked(context);
                },
              ),
              const SizedBox(width: 12),
              Text(
                "Cart (${cartItems.length} items)",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              GestureDetector(
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
            ],
          ),
        ),

        Expanded(
          child: RefreshIndicator(
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
                  _buildPromoAndNoteSection(),
                ],
              ),
            ),
          ),
        ),
      ],
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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

  Widget _buildPromoAndNoteSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Promo Code Section
          _buildPromoCodeSection(),
          const SizedBox(height: 20),
          // Coupon Section
          _buildMyCouponsSection(),
          const SizedBox(height: 20),

          // Add Note Section
          _buildAddNoteSection(),
        ],
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
                onPressed: () {},
                child: const Text(
                  "Add Coupon",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Coupon 1
          _couponCard(
            color1: const Color(0xFFFFF5E0),
            color2: const Color(0xFFF2E3FF),
            icon: "assets/images/banner1.png",
            title: "Buy on Rewards store and Save Big",
            subtitle: "Limited Brand Rewards!",
            cta: "Explore Fire Drops",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CouponGridScreen(
                    title: "Explore Fire Drops",
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Coupon 2
          _couponCard(
            color1: const Color(0xFFFFF2E0),
            color2: const Color(0xFFFFE9F5),
            icon: "assets/images/banner1.png",
            title: "More Rewards & Coupons",
            subtitle: "Get up to 100% Off using Coins",
            cta: "SuperCoin Zone",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CouponGridScreen(
                    title: "SuperCoin Zone",
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _couponCard({
    required Color color1,
    required Color color2,
    required String icon,
    required String title,
    required String subtitle,
    required String cta,
    VoidCallback? onTap, // 👈 add this
  }) {
    return GestureDetector(
      onTap: onTap, // 👈 handle tap
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [color1, color2],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Left circular clip
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Container(
                color: Colors.transparent,
                width: 90,
                height: 90,
                padding: const EdgeInsets.all(12),
                child: Image.asset(icon, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 8),

            // Text content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cta,
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: Colors.blueAccent),
                      ],
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


  Widget _buildPromoCodeSection() {
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
                  hintText: "e.g. SAVE50",
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
                  ),
                  suffixIcon: const Icon(Icons.local_offer_outlined, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildApplyButton(),
          ],
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
        ? Container(
      width: 80,
      height: 48,
      padding: const EdgeInsets.all(12),
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF050040)),
      ),
    )
        : SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF050040),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

  Widget _buildAddNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.note_add_outlined, color: Colors.black54),
            SizedBox(width: 8),
            Text(
              "Add Note",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "e.g. Leave outside the door",
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(CartProvider cartProvider) {
    final subtotal = _calculateSubtotal(cartProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "₹${subtotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Subtotal",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: cartProvider.selectedCount > 0 ? () => _navigateToCheckout(cartProvider) : null,
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
    );
  }

  Future<void> _navigateToCheckout(CartProvider cartProvider) async {
    final double subtotalAmount = _calculateSubtotal(cartProvider);
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
      final addressProvider = AddressProvider();
      await addressProvider.fetchAddresses();

      if (mounted) Navigator.of(context).pop();

      // Use the shared AddressScreen for checkout
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: addressProvider,
            child: AddressScreen(
              fromProfile: false,
              subtotalAmount: subtotalAmount,
              cartItems: selectedItems,
            ),
          ),
        ),
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

class CouponGridScreen extends StatelessWidget {
  final String title;
  const CouponGridScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final coupons = List.generate(8, (i) => "Offer ${i + 1}");

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: coupons.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // ✅ ecommerce-style grid
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD39841), Color(0xFFA9D4E7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_offer_rounded,
                    size: 48, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  coupons[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
      final originalPrice = double.tryParse(product.price.replaceAll(',', '')) ?? 0;
      final discountValue = double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;

      // If discountValue is less than original price, treat it as discount amount
      // Otherwise, treat it as final price
      return discountValue < originalPrice ? originalPrice - discountValue : discountValue;
    } catch (e) {
      return double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;
    }
  }

  String _calculateDiscountedPrice(UserCartProduct product) {
    return _getUnitPrice(product).toStringAsFixed(2);
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
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
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

                  _buildProductImage(product),

                  const SizedBox(width: 10),
                  Expanded(
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
                      ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: () => _updateQuantity(context, item.quantity - 1),
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
                          onPressed: () => _updateQuantity(context, item.quantity + 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "₹${totalPrice.toStringAsFixed(2)}",
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

    debugPrint("🖼️ Loading product thumb: $imageUrl");

    return Image.network(
      imageUrl,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 70,
          height: 70,
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint("❌ Thumb image failed: $imageUrl");

        return Image.asset(
          'assets/images/no_product_img2.png',
          width: 70,
          height: 70,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag, color: Colors.grey, size: 30),
          SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
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

/*
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isApplyingPromo = false;
  bool _showSuccessAnimation = false;
  final TextEditingController _promoCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  void _initializeCart() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      if (cartProvider.cartItems.isEmpty) {
        await cartProvider.fetchCartItems();
      } else {
        // Ensure selection for existing items
        cartProvider.selectAll();
      }
    });
  }

  Future<void> _refreshCartData() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.fetchCartItems();
  }

  // Handle back button press
  void _onPopInvoked(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => dashboard.DashboardScreen()),
    );
  }

  Future<void> _applyPromoCode() async {
    if (_promoCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a promo code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isApplyingPromo = true);

    await Future.delayed(const Duration(seconds: 2));
    bool isValid = _validatePromoCode(_promoCodeController.text.trim());

    setState(() => _isApplyingPromo = false);

    if (isValid) {
      setState(() => _showSuccessAnimation = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo code ${_promoCodeController.text} applied successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      _promoCodeController.clear();

      // Hide animation after completion
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showSuccessAnimation = false);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid promo code: ${_promoCodeController.text}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validatePromoCode(String code) {
    List<String> validCodes = ['SAVE50', 'WELCOME10', 'FLAT20', 'SUMMER25'];
    return validCodes.contains(code.toUpperCase());
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

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) {
              _onPopInvoked(context);
            }
          },// Use the custom back handler
          child: SafeArea(
            child: LottieOverlay(
              child: Scaffold(
                backgroundColor: const Color(0xfffdf6ef),
                body: isLoading && cartItems.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : cartItems.isEmpty
                    ? _buildEmptyCart()
                    : _buildCartWithItems(cartProvider, cartItems, allSelected),

                bottomNavigationBar: cartItems.isEmpty ? null : _buildBottomNavigationBar(cartProvider),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartWithItems(CartProvider cartProvider, List<UserCartItem> cartItems, bool allSelected) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  _refreshCartData();
                  _onPopInvoked(context);// Use the same navigation logic as back button
                },
              ),
              const SizedBox(width: 12),
              Text(
                "Cart (${cartItems.length} items)",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              GestureDetector(
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
            ],
          ),
        ),

        Expanded(
          child: RefreshIndicator(
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
                  _buildPromoAndNoteSection(),
                ],
              ),
            ),
          ),
        ),
      ],
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () =>  _onPopInvoked(context), // Use the same navigation logic
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

  Widget _buildPromoAndNoteSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Promo Code Section
          _buildPromoCodeSection(),
          const SizedBox(height: 20),
          // Add Note Section
          _buildAddNoteSection(),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection() {
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
                  hintText: "e.g. SAVE50",
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
                  ),
                  suffixIcon: const Icon(Icons.local_offer_outlined, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildApplyButton(),
          ],
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
        ? Container(
      width: 80,
      height: 48,
      padding: const EdgeInsets.all(12),
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF050040)),
      ),
    )
        : SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF050040),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

  Widget _buildAddNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.note_add_outlined, color: Colors.black54),
            SizedBox(width: 8),
            Text(
              "Add Note",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "e.g. Leave outside the door",
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "₹${cartProvider.subtotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Subtotal",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: cartProvider.selectedCount > 0 ? () => _navigateToCheckout(cartProvider) : null,
            child: Text(
              "CHECKOUT (${cartProvider.selectedCount} items)",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
// In your CartScreen, update the _navigateToCheckout method:
  Future<void> _navigateToCheckout(CartProvider cartProvider) async {
    final double subtotalAmount = cartProvider.subtotal;
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
      final addressProvider = AddressProvider();
      await addressProvider.fetchAddresses();

      if (mounted) Navigator.of(context).pop();

      // Use the shared AddressScreen for checkout
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: addressProvider,
            child: AddressScreen(
              fromProfile: false, // Important: fromProfile = false for checkout
              subtotalAmount: subtotalAmount,
              cartItems: selectedItems,
            ),
          ),
        ),
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
  */
/*Future<void> _navigateToCheckout(CartProvider cartProvider) async {
    final double subtotalAmount = cartProvider.subtotal;
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
      final addressProvider = AddressProvider();
      await addressProvider.fetchAddresses();

      if (mounted) Navigator.of(context).pop();

      if (addressProvider.hasAddresses) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: addressProvider,
              child: AddressListScreen(
                subtotalAmount: subtotalAmount,
                cartItems: selectedItems,
              ),
            ),
          ),
        );
      } else {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShippingScreen(
              subtotalAmount: subtotalAmount,
              cartItems: selectedItems,
            ),
          ),
        );
      }

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
  }*//*

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
      final originalPrice = double.tryParse(product.price.replaceAll(',', '')) ?? 0;
      final discountValue = double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;

      // If discountValue is less than original price, treat it as discount amount
      // Otherwise, treat it as final price
      return discountValue < originalPrice ? originalPrice - discountValue : discountValue;
    } catch (e) {
      return double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final product = item.product;
        final unitPrice = _getUnitPrice(product); // Use the calculated unit price
        final totalPrice = item.quantity * unitPrice; // Calculate total using the same unit price

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
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

                  // Use the product_thumb instead of images[0]
                  _buildProductImage(product),

                  const SizedBox(width: 10),
                  Expanded(
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
                        // Row(
                        //   children: [
                        //     Text(
                        //       "₹${product.price}",
                        //       style: const TextStyle(
                        //         color: Colors.grey,
                        //         decoration: TextDecoration.lineThrough,
                        //         fontSize: 12,
                        //       ),
                        //     ),
                        //     const SizedBox(width: 6),
                        //     Text(
                        //       "₹${product.discountPrice}",
                        //       style: const TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //         fontSize: 14,
                        //         color: Colors.green,
                        //       ),
                        //     ),
                        //   ],
                        // ),
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
                      ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: () => _updateQuantity(context, item.quantity - 1),
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
                          onPressed: () => _updateQuantity(context, item.quantity + 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "₹${totalPrice.toStringAsFixed(2)}", // This shows total: ₹1990 × quantity
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
        border: Border.all(color: Color(0xFFD39841), width: 0),
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

// Show product thumb if available, otherwise show default local asset image
  Widget _buildOptimizedImage(String? thumb) {
    // If thumb is null or empty, show default image
    if (thumb == null || thumb.isEmpty) {
      return Image.asset(
        'assets/images/no_product_img2.png', // <-- your local default image
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      );
    }

    final imageUrl = "${ApiService.baseUrl}/assets/img/products-thumbs/$thumb";

    debugPrint("🖼️ Loading product thumb: $imageUrl");

    return Image.network(
      imageUrl,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 70,
          height: 70,
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint("❌ Thumb image failed: $imageUrl");

        // Fallback to default local asset if network fails
        return Image.asset(
          'assets/images/no_product_img2.png',
          width: 70,
          height: 70,
          fit: BoxFit.cover,
        );
      },
    );
  }

*/
/*
  Widget _buildProductImage(UserCartProduct product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 70,
        height: 70,
        color: Colors.grey.shade100,
        child: _buildOptimizedImage(product.thumb), // Use thumb instead of images[0]
      ),
    );
  }

  // Simplified image widget that only tries the correct thumb URL
  Widget _buildOptimizedImage(String thumb) {
    final imageUrl = "${ApiService.baseUrl}/assets/img/products-thumbs/$thumb";

    debugPrint("🖼️ Loading product thumb: $imageUrl");

    return Image.network(
      imageUrl,
      width: 70,
      height: 70,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          debugPrint("✅ Thumb image loaded successfully: $imageUrl");
          return child;
        }
        return Container(
          width: 70,
          height: 70,
          color: Colors.grey.shade200,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint("❌ Thumb image failed: $imageUrl");

        // Try fallback to main products directory
        final fallbackUrl = "${ApiService.baseUrl}/assets/img/products/$thumb";
        debugPrint("🔄 Trying fallback: $fallbackUrl");

        return Image.network(
          fallbackUrl,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint("❌ Fallback also failed");
            return _buildPlaceholder();
          },
        );
      },
    );
  }
*//*


  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag, color: Colors.grey, size: 30),
          SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
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

  String _calculateDiscountedPrice(UserCartProduct product) {
    try {
      final originalPrice = double.tryParse(product.price.replaceAll(',', '')) ?? 0;
      final discountValue = double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;

      // If discountValue is greater than original price, it's probably the final price
      // If discountValue is smaller, it's probably the discount amount
      final finalPrice = discountValue > originalPrice ? discountValue : originalPrice - discountValue;

      return finalPrice.toStringAsFixed(2);
    } catch (e) {
      return product.discountPrice;
    }
  }


*/
/* void _showDeleteBottomSheet(BuildContext context, UserCartItem item, Function(int) onDelete) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Remove Item",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Are you sure you want to remove this item from your cart?"),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      onDelete(item.cartId);
                      Navigator.pop(context);
                    },
                    child: const Text("Remove", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }*//*

}

*/




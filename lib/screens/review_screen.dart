import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../model/AddressModel.dart';
import '../model/OrderModel.dart';
import '../model/cart_models.dart';
import '../model/delivery_type.dart';
import '../providers/CartProvider.dart';
import '../providers/OrderProvider.dart';
import '../providers/ShippingProvider.dart';
import '../providers/delivery_provider.dart';
import '../services/api_service.dart';
import '../utils/BaseScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DashboardScreen.dart';





import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';


class ReviewScreen extends StatefulWidget {
  final Address selectedAddress;
  final String deliveryOption;
  final double deliveryCost;
  final double subtotalAmount;
  final double totalAmount;
  final List<UserCartItem> cartItems;

  const ReviewScreen({
    super.key,
    required this.selectedAddress,
    required this.deliveryOption,
    required this.deliveryCost,
    required this.subtotalAmount,
    required this.totalAmount,
    required this.cartItems,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _agreeToTerms = false;
  bool _agreeToMarketing = false;
  final TextEditingController _promoCodeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  late List<UserCartItem> _cartItems;
  late double _subtotal;
  late double _total;

  late Razorpay _razorpay;
  String? _currentOrderId;

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.cartItems);
    _calculateTotals();

    _razorpay = Razorpay();

    // Only use the available Razorpay events
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    if (kDebugMode) {
      print('🎯 Razorpay initialized with listeners');
      print('📋 Available events:');
      print('   - EVENT_PAYMENT_SUCCESS: ${Razorpay.EVENT_PAYMENT_SUCCESS}');
      print('   - EVENT_PAYMENT_ERROR: ${Razorpay.EVENT_PAYMENT_ERROR}');
      print('   - EVENT_EXTERNAL_WALLET: ${Razorpay.EVENT_EXTERNAL_WALLET}');
    }
  }



  @override
  void dispose() {
    _promoCodeController.dispose();
    _noteController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _calculateTotals() {
    _subtotal = _cartItems.fold(0.0, (sum, item) {
      final sellingPrice = _getSellingPrice(item.product);
      return sum + sellingPrice * item.quantity;
    });
    _total = _subtotal + widget.deliveryCost;
  }

  double _getSellingPrice(UserCartProduct product) {
    final regularPrice = double.tryParse(product.price.replaceAll(',', '')) ?? 0;
    final discountAmount = double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;
    final finalPrice = regularPrice - discountAmount;
    return finalPrice > 0 ? finalPrice : regularPrice;
  }

  bool _hasDiscount(UserCartProduct product) {
    final discountAmount = double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;
    return discountAmount > 0;
  }

  Future<void> _updateQuantity(UserCartItem item, int newQuantity) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      if (newQuantity < 1) {
        await cartProvider.removeFromCart(item, context);
        setState(() {
          _cartItems.removeWhere((e) => e.cartId == item.cartId);
          _calculateTotals();
        });
      } else {
        await cartProvider.updateQuantity(item, newQuantity);
        setState(() {
          final index = _cartItems.indexWhere((e) => e.cartId == item.cartId);
          if (index != -1) _cartItems[index].quantity = newQuantity;
          _calculateTotals();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update quantity: $e")),
      );
    }
  }

  void _incrementQuantity(UserCartItem item) => _updateQuantity(item, item.quantity + 1);

  void _decrementQuantity(UserCartItem item) {
    if (item.quantity > 1) {
      _updateQuantity(item, item.quantity - 1);
    }
  }

  void _showRemoveConfirmation(UserCartItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Item"),
        content: const Text("Are you sure you want to remove this item from your cart?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateQuantity(item, 0);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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

    await Future.delayed(const Duration(seconds: 2));
    bool isValid = _validatePromoCode(_promoCodeController.text.trim());

    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo code ${_promoCodeController.text} applied successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      _promoCodeController.clear();
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

  Future<bool> _onWillPop() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.fetchCartItems();
    return true;
  }

  Future<void> _openRazorpayCheckout() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    _logPaymentFlow('Starting checkout process');

    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Creating order...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Create order first using the API with model
      final CreateOrderResponse? orderResponse = await orderProvider.createOrder(_total);

      if (orderResponse == null) {
        _logPaymentFlow('Order creation failed', extra: {'error': orderProvider.error});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order: ${orderProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Store the order ID for verification
      _currentOrderId = orderResponse.orderId;

      _logPaymentFlow('Order created successfully', extra: {
        'orderId': orderResponse.orderId,
        'amount': orderResponse.amount,
      });

      // Use the model properties
      final orderId = orderResponse.orderId;
      final amount = orderResponse.amount;

      // Enhanced Razorpay options
      var options = {
        'key': 'rzp_test_RMUfaKMC7moQpC', // Your test key
        'amount': (amount * 100).toInt(), // Amount in paise
        'currency': 'INR', // Explicitly set currency
        'name': 'Elfinic Commerce', // Your business name
        'description': 'Order Payment',
        'order_id': orderId,
        'timeout': 300, // 3 minutes timeout
        'retry': {'enabled': true, 'max_count': 1},
        'prefill': {
          'contact': widget.selectedAddress.phone,
          'email': 'test@elfinic.com', // Use a test email
        },
        'notes': {
          'order_type': 'ecommerce',
          'source': 'flutter_app'
        },
        'theme': {
          'color': '#2D89EF',
          'backdrop_color': '#FFFFFF',
        }
      };

      _logPaymentFlow('Opening Razorpay checkout', extra: {'options': options});

      // Add delay to ensure UI is ready
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        _razorpay.open(options);
      } catch (e) {
        _logPaymentFlow('Razorpay opening error', extra: {'error': e.toString()});

        // More specific error handling
        if (e.toString().contains('INVALID_OPTIONS')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid payment configuration. Please contact support.'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (e.toString().contains('NETWORK_ERROR')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Network error. Please check your internet connection.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

    } catch (e) {
      _logPaymentFlow('Checkout process error', extra: {'error': e.toString()});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ 💰 PAYMENT SUCCESS CALLBACK TRIGGERED');
      print('├─────────────────────────────────────────────────────────────');
      print('│ Full Response: $response');
      print('│ Order ID: ${response.orderId}');
      print('│ Payment ID: ${response.paymentId}');
      print('│ Signature: ${response.signature}');
      print('│ Timestamp: ${DateTime.now()}');
      print('└─────────────────────────────────────────────────────────────');
    }

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Show verifying payment dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const VerifyingPaymentDialog(),
    );

    try {
      // Verify that we have all required data
      if (response.orderId == null || response.paymentId == null || response.signature == null) {
        throw Exception('Missing payment data from Razorpay');
      }

      if (kDebugMode) {
        print('🔄 Starting payment verification with server...');
      }

      // Verify payment with your server
      final verifyResponse = await orderProvider.verifyPayment(
        razorpayOrderId: response.orderId!,
        razorpayPaymentId: response.paymentId!,
        razorpaySignature: response.signature!,
      );

      // Close verifying dialog
      Navigator.pop(context);

      if (verifyResponse != null && verifyResponse.success) {
        // Payment verified successfully
        if (kDebugMode) {
          print('✅ Payment verified successfully by server!');
          print('📦 Server response: ${verifyResponse.message}');
        }

        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => OrderSuccessDialog(
            orderNumber: response.paymentId,
            totalAmount: _total,
            deliveryAddress: widget.selectedAddress,
            razorpayOrderId: _currentOrderId,
            paymentVerified: true,
          ),
        );

        // Clear cart after successful payment
        try {
          await cartProvider.clearCart();
          if (kDebugMode) {
            print('🛒 Cart cleared successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Could not clear cart: $e');
          }
          // Fallback: clear cart locally
          cartProvider.handleEmptyCart();
        }

      } else {
        // Payment verification failed
        final errorMessage = verifyResponse?.message ?? 'Unknown verification error';
        if (kDebugMode) {
          print('❌ Payment verification failed: $errorMessage');
        }

        // Show success dialog but indicate verification issue
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => OrderSuccessDialog(
            orderNumber: response.paymentId,
            totalAmount: _total,
            deliveryAddress: widget.selectedAddress,
            razorpayOrderId: _currentOrderId,
            paymentVerified: false,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment received but verification pending: $errorMessage'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }

    } catch (e, stackTrace) {
      // Close verifying dialog
      Navigator.pop(context);

      if (kDebugMode) {
        print('💥 Error during payment processing:');
        print('Error: $e');
        print('Stack trace: $stackTrace');
      }

      // Show success dialog but indicate there was an error in processing
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => OrderSuccessDialog(
          orderNumber: response.paymentId,
          totalAmount: _total,
          deliveryAddress: widget.selectedAddress,
          razorpayOrderId: _currentOrderId,
          paymentVerified: false,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment received but processing error: $e'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ ❌ PAYMENT ERROR CALLBACK TRIGGERED');
      print('├─────────────────────────────────────────────────────────────');
      print('│ Code: ${response.code}');
      print('│ Message: ${response.message}');
      print('│ Timestamp: ${DateTime.now()}');
      print('└─────────────────────────────────────────────────────────────');
    }

    // Check if it's a user cancellation
    if (response.code == 2) {
      // User manually closed the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment was cancelled'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      // Other payment errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment failed: ${response.code} - ${response.message}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External Wallet Selected: ${response.walletName}"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: BaseScreen(
        child: Scaffold(
          backgroundColor: const Color(0xfffdf6ef),
          appBar: AppBar(
            surfaceTintColor: const Color(0xfffdf6ef),
            backgroundColor: const Color(0xfffdf6ef),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () async {
                final cartProvider = Provider.of<CartProvider>(context, listen: false);
                await cartProvider.fetchCartItems();
                Navigator.pop(context);
              },
            ),
            title: const Text(
              "Checkout",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "₹${_total.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Estimated Total",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              )
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _stepBox("1 SHIPPING", false),
                        _stepBox("2 DELIVERY", false),
                        _stepBox("3 REVIEW", true),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Order Summary Section
                    const Text(
                      "Order Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF160042),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildCartItemsList(),

                    const SizedBox(height: 16),

                    // Delivery Information
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Delivery Information",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.selectedAddress.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(widget.selectedAddress.addressLine1),
                                    if (widget.selectedAddress.addressLine2!.isNotEmpty)
                                      Text(widget.selectedAddress.addressLine2.toString()),
                                    Text("${widget.selectedAddress.city}, ${widget.selectedAddress.state} - ${widget.selectedAddress.postalCode}"),
                                    Text("Phone: ${widget.selectedAddress.phone}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.delivery_dining, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${widget.deliveryOption} Delivery - ₹${widget.deliveryCost.toStringAsFixed(2)}",
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Details Section
                    const Text(
                      "Payment Detail",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF160042)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow("Subtotal", "₹${_subtotal.toStringAsFixed(2)}"),
                          _buildSummaryRow(
                            "Shipment Fee",
                            widget.deliveryCost == 0 ? "Free" : "₹${widget.deliveryCost.toStringAsFixed(2)}",
                            color: widget.deliveryCost == 0 ? Colors.green : Colors.black,
                          ),
                          const Divider(),
                          _buildSummaryRow(
                            "Total Payment",
                            "₹${_total.toStringAsFixed(2)}",
                            isBold: true,
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Promo Code Section
                    const Text("Promo Code", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF160042))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _promoCodeController,
                            decoration: _inputDecoration("e.g. SAVE50"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          onPressed: _applyPromoCode,
                          child: const Text("APPLY", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Add Note Section
                    const Text("Add Note", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF160042))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: _inputDecoration("e.g. Leave outside the door"),
                    ),
                    const SizedBox(height: 20),

                    // Terms and Conditions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            value: _agreeToTerms,
                            onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
                            title: const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: "I agree to the "),
                                  TextSpan(text: "Terms & Conditions, Privacy Policy, Return Policy", style: TextStyle(color: Colors.blue)),
                                  TextSpan(text: " and "),
                                  TextSpan(text: "Contact Seller", style: TextStyle(color: Colors.blue)),
                                ],
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            value: _agreeToMarketing,
                            onChanged: (v) => setState(() => _agreeToMarketing = v ?? false),
                            title: const Text("Send me marketing communications via email and SMS"),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _mainButton(
                        "CONTINUE TO PAYMENT",
                        orderProvider.isLoading ? null : _openRazorpayCheckout
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Loading overlay
              if (orderProvider.isLoading || orderProvider.isVerifyingPayment)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Processing...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ... Rest of your helper methods (_buildCartItemsList, _buildSummaryRow, _stepBox, _mainButton, _inputDecoration) remain the same
  // Copy them from your existing code

  Widget _buildCartItemsList() {
    // Your existing _buildCartItemsList implementation
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Items (${_cartItems.length})",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Total: ₹${_subtotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          // Cart Items ListView.builder...
          // Your existing implementation
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              final product = item.product;
              final sellingPrice = _getSellingPrice(product);
              final hasDiscount = _hasDiscount(product);
              final regularPrice = double.tryParse(product.price.replaceAll(',', '')) ?? 0;
              final totalPrice = item.quantity * sellingPrice;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: index < _cartItems.length - 1
                        ? BorderSide(color: Colors.grey.shade300)
                        : BorderSide.none,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFD39841), width: 0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (product.thumb == null || product.thumb!.isEmpty)
                            ? Image.asset(
                          'assets/images/no_product_img2.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                            : Image.network(
                          "${ApiService.baseUrl}/assets/img/products-thumbs/${product.thumb}",
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            'assets/images/no_product_img2.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (hasDiscount)
                            Row(
                              children: [
                                Text(
                                  "₹${regularPrice.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "₹${sellingPrice.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              "₹${sellingPrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              InkWell(
                                onTap: () => _decrementQuantity(item),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.remove, size: 16),
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 30,
                                alignment: Alignment.center,
                                child: Text(
                                  item.quantity.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _incrementQuantity(item),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(Icons.add, size: 16, color: Colors.green.shade800),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {
    bool isBold = false,
    double fontSize = 16,
    Color color = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBox(String text, bool active) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.amber : Colors.white,
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _mainButton(String text, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo.shade900,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

// Add a retry button
  Widget _retryButton() {
    return TextButton(
      onPressed: () {
        _openRazorpayCheckout();
      },
      child: const Text(
        'Retry Payment',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.black87, width: 1.2),
      ),
    );
  }

  void _logPaymentFlow(String message, {Map<String, dynamic>? extra}) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ 💳 PAYMENT FLOW: $message');
      print('├─────────────────────────────────────────────────────────────');
      if (extra != null) {
        extra.forEach((key, value) {
          print('│ $key: $value');
        });
      }
      print('│ Timestamp: ${DateTime.now()}');
      print('└─────────────────────────────────────────────────────────────');
    }
  }
}

// Verifying Payment Dialog
class VerifyingPaymentDialog extends StatelessWidget {
  const VerifyingPaymentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFDF6EF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              strokeWidth: 6,
            ),
            const SizedBox(height: 20),
            Text(
              "Verifying Payment",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please wait while we verify your payment...",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Updated OrderSuccessDialog with payment verification status
class OrderSuccessDialog extends StatelessWidget {
  final String? orderNumber;
  final double? totalAmount;
  final Address? deliveryAddress;
  final String? razorpayOrderId;
  final bool paymentVerified;

  const OrderSuccessDialog({
    super.key,
    this.orderNumber,
    this.totalAmount,
    this.deliveryAddress,
    this.razorpayOrderId,
    this.paymentVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Dialog(
      backgroundColor: const Color(0xFFFDF6EF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: paymentVerified ? Colors.green.shade600 : Colors.orange.shade600,
                shape: BoxShape.circle,
              ),
              child: Icon(
                paymentVerified ? Icons.check : Icons.verified,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              paymentVerified ? "Payment Verified!" : "Order Placed!",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              paymentVerified
                  ? "Your payment has been successfully verified"
                  : "You have successfully placed your order",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Order Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  if (razorpayOrderId != null)
                    _buildDetailRow("Order ID", razorpayOrderId!),
                  if (orderNumber != null)
                    _buildDetailRow("Payment ID", orderNumber!),
                  if (totalAmount != null)
                    _buildDetailRow(
                      "Total Amount",
                      "₹${totalAmount!.toStringAsFixed(2)}",
                      isAmount: true,
                    ),
                  if (paymentVerified) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified, color: Colors.green.shade600, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "Payment Verified",
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // Explore More Button
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: const BorderSide(color: Colors.black87, width: 1.5),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToHome(context);
                    },
                    child: const Text(
                      "EXPLORE MORE",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // View Order Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToOrderDetails(context);
                    },
                    child: const Text(
                      "VIEW ORDER",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Continue Shopping Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                        (route) => false,
                  );
                },
                child: const Text(
                  "Continue Shopping",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              color: isAmount ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
          (route) => false,
    );
  }

  void _navigateToOrderDetails(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/order-details',
          (route) => false,
      arguments: {
        'orderNumber': razorpayOrderId ?? orderProvider.orderId,
        'totalAmount': totalAmount,
        'deliveryAddress': deliveryAddress,
      },
    );
  }
}
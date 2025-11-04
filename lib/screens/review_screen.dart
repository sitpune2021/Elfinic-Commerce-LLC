import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../model/AddressModel.dart';
import '../model/cart_models.dart';
import '../model/delivery_type.dart';
import '../providers/CartProvider.dart';
import '../providers/ShippingProvider.dart';
import '../providers/delivery_provider.dart';
import '../services/api_service.dart';
import '../utils/BaseScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DashboardScreen.dart';



// class ReviewScreen extends StatefulWidget {
//   final Address selectedAddress;
//   final String deliveryOption;
//   final double deliveryCost;
//   final double subtotalAmount;
//   final double totalAmount;
//   final List<UserCartItem> cartItems;
//
//   const ReviewScreen({
//     super.key,
//     required this.selectedAddress,
//     required this.deliveryOption,
//     required this.deliveryCost,
//     required this.subtotalAmount,
//     required this.totalAmount,
//     required this.cartItems,
//   });
//
//   @override
//   State<ReviewScreen> createState() => _ReviewScreenState();
// }
//
// class _ReviewScreenState extends State<ReviewScreen> {
//   bool _agreeToTerms = false;
//   bool _agreeToMarketing = false;
//   final TextEditingController _promoCodeController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();
//
//   late List<UserCartItem> _cartItems;
//   late double _subtotal;
//   late double _gst;
//   late double _total;
//
//   late Razorpay _razorpay;
//
//   @override
//   void initState() {
//     super.initState();
//     _cartItems = List.from(widget.cartItems);
//     _calculateTotals(); // Calculate all totals initially
//
//     // Razorpay init
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }
//
//   @override
//   void dispose() {
//     _promoCodeController.dispose();
//     _noteController.dispose();
//     _razorpay.clear();
//     super.dispose();
//   }
//
//   // Calculate all totals
//   void _calculateTotals() {
//     _subtotal = _cartItems.fold(0.0, (sum, item) {
//       final sellingPrice = _getSellingPrice(item.product);
//       return sum + sellingPrice * item.quantity;
//     });
//     _gst = _subtotal * 0.18;
//     _total = _subtotal + widget.deliveryCost + _gst;
//   }
//
//   // Helper method to get the actual selling price
//   double _getSellingPrice(UserCartProduct product) {
//     final regularPrice = double.tryParse(product.price.replaceAll(',', '')) ?? 0;
//     final discountAmount = double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;
//
//     // Calculate final price: regularPrice - discountAmount
//     final finalPrice = regularPrice - discountAmount;
//
//     // Ensure final price is not negative
//     return finalPrice > 0 ? finalPrice : regularPrice;
//   }
//
//   // Helper method to check if product has discount
//   bool _hasDiscount(UserCartProduct product) {
//     final discountAmount = double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;
//     return discountAmount > 0;
//   }
//
//   Future<void> _updateQuantity(UserCartItem item, int newQuantity) async {
//     try {
//       final cartProvider = Provider.of<CartProvider>(context, listen: false);
//
//       if (newQuantity < 1) {
//         await cartProvider.removeFromCart(item, context);
//         setState(() {
//           _cartItems.removeWhere((e) => e.cartId == item.cartId);
//           _calculateTotals(); // Recalculate all totals
//         });
//       } else {
//         await cartProvider.updateQuantity(item, newQuantity);
//         setState(() {
//           final index = _cartItems.indexWhere((e) => e.cartId == item.cartId);
//           if (index != -1) _cartItems[index].quantity = newQuantity;
//           _calculateTotals(); // Recalculate all totals
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to update quantity: $e")),
//       );
//     }
//   }
//
//   void _incrementQuantity(UserCartItem item) => _updateQuantity(item, item.quantity + 1);
//
//   void _decrementQuantity(UserCartItem item) {
//     if (item.quantity > 1) {
//       _updateQuantity(item, item.quantity - 1);
//     }
//   }
//
//   void _showRemoveConfirmation(UserCartItem item) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Remove Item"),
//         content: const Text("Are you sure you want to remove this item from your cart?"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _updateQuantity(item, 0);
//             },
//             child: const Text("Remove", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _applyPromoCode() async {
//     if (_promoCodeController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a promo code'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     await Future.delayed(const Duration(seconds: 2));
//     bool isValid = _validatePromoCode(_promoCodeController.text.trim());
//
//     if (isValid) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Promo code ${_promoCodeController.text} applied successfully!'),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//       _promoCodeController.clear();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Invalid promo code: ${_promoCodeController.text}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   bool _validatePromoCode(String code) {
//     List<String> validCodes = ['SAVE50', 'WELCOME10', 'FLAT20', 'SUMMER25'];
//     return validCodes.contains(code.toUpperCase());
//   }
//
//   Future<bool> _onWillPop() async {
//     final cartProvider = Provider.of<CartProvider>(context, listen: false);
//     await cartProvider.fetchCartItems();
//     return true;
//   }
//
//   void _openRazorpayCheckout() {
//     var options = {
//       'key': 'rzp_test_A2FMazOH75YzLT',
//       'amount': (_total * 100).toInt(), // Amount in paise
//       'name': 'Your Store Name',
//       'description': 'Order Payment',
//       'prefill': {
//         'contact': widget.selectedAddress.phone,
//         'email': 'customer@example.com',
//       },
//       'external': {
//         'wallets': ['paytm']
//       }
//     };
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       debugPrint('Error in Razorpay: $e');
//     }
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     showDialog(
//       context: context,
//       builder: (context) => OrderSuccessDialog(
//         orderNumber: response.paymentId,
//         totalAmount: _total,
//         deliveryAddress: widget.selectedAddress,
//       ),
//     );
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text("Payment failed: ${response.code} - ${response.message}"),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text("External Wallet Selected: ${response.walletName}"),
//         backgroundColor: Colors.orange,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: BaseScreen(
//         child: Scaffold(
//           backgroundColor: const Color(0xfffdf6ef),
//           appBar: AppBar(
//             surfaceTintColor: const Color(0xfffdf6ef),
//             backgroundColor: const Color(0xfffdf6ef),
//             elevation: 0,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
//               onPressed: () async {
//                 final cartProvider = Provider.of<CartProvider>(context, listen: false);
//                 await cartProvider.fetchCartItems();
//                 Navigator.pop(context);
//               },
//             ),
//             title: const Text(
//               "Checkout",
//               style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//             ),
//             actions: [
//               Padding(
//                 padding: const EdgeInsets.only(right: 16),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "₹${_total.toStringAsFixed(2)}",
//                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     const Text(
//                       "Estimated Total",
//                       style: TextStyle(fontSize: 12, color: Colors.black54),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Step Indicator
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _stepBox("1 SHIPPING", false),
//                     _stepBox("2 DELIVERY", false),
//                     _stepBox("3 REVIEW", true),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Order Summary Section
//                 const Text(
//                   "Order Summary",
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF160042),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//
//                 _buildCartItemsList(),
//
//                 const SizedBox(height: 16),
//
//                 // Delivery Information
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Delivery Information",
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Icon(Icons.location_on, color: Colors.green, size: 20),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(widget.selectedAddress.name, style: const TextStyle(fontWeight: FontWeight.bold)),
//                                 Text(widget.selectedAddress.addressLine1),
//                                 if (widget.selectedAddress.addressLine2!.isNotEmpty)
//                                   Text(widget.selectedAddress.addressLine2.toString()),
//                                 Text("${widget.selectedAddress.city}, ${widget.selectedAddress.state} - ${widget.selectedAddress.postalCode}"),
//                                 Text("Phone: ${widget.selectedAddress.phone}"),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           const Icon(Icons.delivery_dining, color: Colors.blue, size: 20),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               "${widget.deliveryOption} Delivery - ₹${widget.deliveryCost.toStringAsFixed(2)}",
//                               style: const TextStyle(fontWeight: FontWeight.w500),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Payment Details Section
//                 const Text(
//                   "Payment Detail",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF160042)),
//                 ),
//                 const SizedBox(height: 10),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: Column(
//                     children: [
//                       _buildSummaryRow("Subtotal", "₹${_subtotal.toStringAsFixed(2)}"),
//                       _buildSummaryRow(
//                         "Shipment Fee",
//                         widget.deliveryCost == 0 ? "Free" : "₹${widget.deliveryCost.toStringAsFixed(2)}",
//                         color: widget.deliveryCost == 0 ? Colors.green : Colors.black,
//                       ),
//                       _buildSummaryRow("GST (18%)", "₹${_gst.toStringAsFixed(2)}"),
//                       const Divider(),
//                       _buildSummaryRow(
//                         "Total Payment",
//                         "₹${_total.toStringAsFixed(2)}",
//                         isBold: true,
//                         fontSize: 18,
//                         color: Colors.green,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Promo Code Section
//                 const Text("Promo Code", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF160042))),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _promoCodeController,
//                         decoration: _inputDecoration("e.g. SAVE50"),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey.shade400,
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                       ),
//                       onPressed: _applyPromoCode,
//                       child: const Text("APPLY", style: TextStyle(color: Colors.white)),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Add Note Section
//                 const Text("Add Note", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF160042))),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                   controller: _noteController,
//                   maxLines: 3,
//                   decoration: _inputDecoration("e.g. Leave outside the door"),
//                 ),
//                 const SizedBox(height: 20),
//
//                 // Terms and Conditions
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: Column(
//                     children: [
//                       CheckboxListTile(
//                         value: _agreeToTerms,
//                         onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
//                         title: const Text.rich(
//                           TextSpan(
//                             children: [
//                               TextSpan(text: "I agree to the "),
//                               TextSpan(text: "Terms & Conditions, Privacy Policy, Return Policy", style: TextStyle(color: Colors.blue)),
//                               TextSpan(text: " and "),
//                               TextSpan(text: "Contact Seller", style: TextStyle(color: Colors.blue)),
//                             ],
//                           ),
//                         ),
//                         controlAffinity: ListTileControlAffinity.leading,
//                         contentPadding: EdgeInsets.zero,
//                       ),
//                       CheckboxListTile(
//                         value: _agreeToMarketing,
//                         onChanged: (v) => setState(() => _agreeToMarketing = v ?? false),
//                         title: const Text("Send me marketing communications via email and SMS"),
//                         controlAffinity: ListTileControlAffinity.leading,
//                         contentPadding: EdgeInsets.zero,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 _mainButton("CONTINUE TO PAYMENT", () {
//                   if (!_agreeToTerms) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Please agree to the Terms & Conditions'),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                     return;
//                   }
//                   _openRazorpayCheckout();
//                 }),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Updated method to build cart items list with proper price calculation
//   Widget _buildCartItemsList() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Column(
//         children: [
//           // Header
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Items (${_cartItems.length})",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 Text(
//                   "Total: ₹${_subtotal.toStringAsFixed(2)}",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Cart Items
//           ListView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             itemCount: _cartItems.length,
//             itemBuilder: (context, index) {
//               final item = _cartItems[index];
//               final product = item.product;
//               final sellingPrice = _getSellingPrice(product);
//               final hasDiscount = _hasDiscount(product);
//               final regularPrice = double.tryParse(product.price.replaceAll(',', '')) ?? 0;
//               final totalPrice = item.quantity * sellingPrice;
//
//               return Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   border: Border(
//                     bottom: index < _cartItems.length - 1
//                         ? BorderSide(color: Colors.grey.shade300)
//                         : BorderSide.none,
//                   ),
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Product Image
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Color(0xFFD39841), width: 0),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: (product.thumb == null || product.thumb!.isEmpty)
//                             ? Image.asset(
//                           'assets/images/no_product_img2.png',
//                           width: 60,
//                           height: 60,
//                           fit: BoxFit.cover,
//                         )
//                             : Image.network(
//                           "${ApiService.baseUrl}/assets/img/products-thumbs/${product.thumb}",
//                           width: 60,
//                           height: 60,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) => Image.asset(
//                             'assets/images/no_product_img2.png',
//                             width: 60,
//                             height: 60,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(width: 12),
//
//                     // Product Details and Quantity Controls
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             product.name,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w500,
//                               fontSize: 14,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//
//                           // Price Display - Show both prices if there's a discount
//                           if (hasDiscount)
//                             Row(
//                               children: [
//                                 Text(
//                                   "₹${regularPrice.toStringAsFixed(2)}",
//                                   style: const TextStyle(
//                                     color: Colors.grey,
//                                     decoration: TextDecoration.lineThrough,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   "₹${sellingPrice.toStringAsFixed(2)}",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                               ],
//                             )
//                           else
//                             Text(
//                               "₹${sellingPrice.toStringAsFixed(2)}",
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                               ),
//                             ),
//
//                           const SizedBox(height: 8),
//
//                           // Quantity Controls
//                           Row(
//                             children: [
//                               // Decrement Button
//                               InkWell(
//                                 onTap: () => _decrementQuantity(item),
//                                 child: Container(
//                                   width: 30,
//                                   height: 30,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade200,
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   child: const Icon(Icons.remove, size: 16),
//                                 ),
//                               ),
//
//                               // Quantity Display
//                               Container(
//                                 width: 40,
//                                 height: 30,
//                                 alignment: Alignment.center,
//                                 child: Text(
//                                   item.quantity.toString(),
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ),
//
//                               // Increment Button
//                               InkWell(
//                                 onTap: () => _incrementQuantity(item),
//                                 child: Container(
//                                   width: 30,
//                                   height: 30,
//                                   decoration: BoxDecoration(
//                                     color: Colors.green.shade100,
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   child: Icon(Icons.add, size: 16, color: Colors.green.shade800),
//                                 ),
//                               ),
//
//                               const Spacer(),
//
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // Total Price
//                     Text(
//                       "₹${totalPrice.toStringAsFixed(2)}",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryRow(String title, String value, {
//     bool isBold = false,
//     double fontSize = 16,
//     Color color = Colors.black,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: fontSize,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//               color: color,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: fontSize,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper Widgets
//   Widget _stepBox(String text, bool active) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: active ? Colors.amber : Colors.white,
//           border: Border.all(color: Colors.black26),
//           borderRadius: BorderRadius.circular(6),
//         ),
//         child: Center(
//           child: Text(
//             text,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: active ? Colors.white : Colors.black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _mainButton(String text, VoidCallback onPressed) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.indigo.shade900,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//         ),
//         onPressed: onPressed,
//         child: Text(
//           text,
//           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
//
//   InputDecoration _inputDecoration(String hintText) {
//     return InputDecoration(
//       hintText: hintText,
//       filled: true,
//       fillColor: Colors.white,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30),
//         borderSide: BorderSide(color: Colors.grey.shade400),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30),
//         borderSide: BorderSide(color: Colors.grey.shade400),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30),
//         borderSide: const BorderSide(color: Colors.black87, width: 1.2),
//       ),
//     );
//   }
// }
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

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.cartItems);
    _calculateTotals(); // Calculate all totals initially

    // Razorpay init
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    _noteController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  // Calculate all totals
  void _calculateTotals() {
    _subtotal = _cartItems.fold(0.0, (sum, item) {
      final sellingPrice = _getSellingPrice(item.product);
      return sum + sellingPrice * item.quantity;
    });
    _total = _subtotal + widget.deliveryCost; // Removed GST calculation
  }

  // Helper method to get the actual selling price
  double _getSellingPrice(UserCartProduct product) {
    final regularPrice = double.tryParse(product.price.replaceAll(',', '')) ?? 0;
    final discountAmount = double.tryParse(product.discountPrice.replaceAll(',', '')) ?? 0;

    // Calculate final price: regularPrice - discountAmount
    final finalPrice = regularPrice - discountAmount;

    // Ensure final price is not negative
    return finalPrice > 0 ? finalPrice : regularPrice;
  }

  // Helper method to check if product has discount
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
          _calculateTotals(); // Recalculate all totals
        });
      } else {
        await cartProvider.updateQuantity(item, newQuantity);
        setState(() {
          final index = _cartItems.indexWhere((e) => e.cartId == item.cartId);
          if (index != -1) _cartItems[index].quantity = newQuantity;
          _calculateTotals(); // Recalculate all totals
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

  void _openRazorpayCheckout() {
    var options = {
      'key': 'rzp_test_A2FMazOH75YzLT',
      'amount': (_total * 100).toInt(), // Amount in paise
      'name': 'Your Store Name',
      'description': 'Order Payment',
      'prefill': {
        'contact': widget.selectedAddress.phone,
        'email': 'customer@example.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error in Razorpay: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    showDialog(
      context: context,
      builder: (context) => OrderSuccessDialog(
        orderNumber: response.paymentId,
        totalAmount: _total,
        deliveryAddress: widget.selectedAddress,
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment failed: ${response.code} - ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
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
          body: SingleChildScrollView(
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

                _mainButton("CONTINUE TO PAYMENT", () {
                  if (!_agreeToTerms) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please agree to the Terms & Conditions'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  _openRazorpayCheckout();
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Updated method to build cart items list with proper price calculation
  Widget _buildCartItemsList() {
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

          // Cart Items
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
                        border: Border.all(color: Color(0xFFD39841), width: 0),
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

                    // Product Details and Quantity Controls
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

                          // Price Display - Show both prices if there's a discount
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

                          // Quantity Controls
                          Row(
                            children: [
                              // Decrement Button
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

                              // Quantity Display
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

                              // Increment Button
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

                    // Total Price
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

  // Helper Widgets
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

  Widget _mainButton(String text, VoidCallback onPressed) {
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
}
class OrderSuccessDialog extends StatelessWidget {
  final String? orderNumber;
  final double? totalAmount;
  final Address? deliveryAddress;

  const OrderSuccessDialog({
    super.key,
    this.orderNumber,
    this.totalAmount,
    this.deliveryAddress,
  });

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
            // Success Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              "Order Placed Successfully!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtitle
            const Text(
              "You have successfully placed your order",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Order Details
            if (orderNumber != null || totalAmount != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    if (orderNumber != null)
                      _buildDetailRow("Order Number", orderNumber!),
                    if (totalAmount != null)
                      _buildDetailRow(
                        "Total Amount",
                        "₹${totalAmount!.toStringAsFixed(2)}",
                        isAmount: true,
                      ),
                    if (deliveryAddress != null) ...[
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Delivery Address",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  deliveryAddress!.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "${deliveryAddress!.addressLine1}, ${deliveryAddress!.city}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Success Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "You will receive order confirmation shortly",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
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
                      Navigator.pop(context); // Close dialog
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
                      Navigator.pop(context); // Close dialog
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
                  Navigator.pop(context); // Close the dialog first

                  // Navigate to DashboardScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                        (route) => false, // Removes all previous routes
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
    // Navigate to home screen and remove all previous routes
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
          (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Continue shopping for more great products!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _navigateToOrderDetails(BuildContext context) {
    // Navigate to order details screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/order-details',
          (route) => false,
      arguments: {
        'orderNumber': orderNumber,
        'totalAmount': totalAmount,
        'deliveryAddress': deliveryAddress,
      },
    );
  }
}



// Input Decoration Helper
InputDecoration inputDecoration(String hintText) {
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


// Optional: Basic OrderDetailsScreen example
class OrderDetailsScreen extends StatelessWidget {
  final String orderNumber;
  final double totalAmount;
  final Address? deliveryAddress;

  const OrderDetailsScreen({
    super.key,
    required this.orderNumber,
    required this.totalAmount,
    this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: const Color(0xFF050040),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #$orderNumber', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Total: ₹${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.green)),
            if (deliveryAddress != null) ...[
              const SizedBox(height: 16),
              const Text('Delivery Address:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(deliveryAddress!.name),
              Text('${deliveryAddress!.addressLine1}, ${deliveryAddress!.city}'),
            ],
          ],
        ),
      ),
    );
  }
}




Widget summaryRow(String title, String value,
    {bool isBold = false, double fontSize = 14, Color? color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize)),
        Text(value,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize,
                color: color ?? Colors.black)),
      ],
    ),
  );
}

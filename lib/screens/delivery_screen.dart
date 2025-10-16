
import 'package:elfinic_commerce_llc/screens/review_screen.dart';
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
import 'ShoppingScreen.dart';

class DeliveryScreen extends StatefulWidget {
  final Address? selectedAddress;
  final double subtotalAmount;
  final List<UserCartItem> cartItems;

  const DeliveryScreen({
    super.key,
    this.selectedAddress,
    required this.subtotalAmount,
    required this.cartItems,
  });

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  int? _selectedDeliveryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().fetchDeliveryTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryProvider>();

    // Get selected delivery type or fallback
    final selectedType = provider.deliveryTypes.firstWhere(
          (t) => t.id == _selectedDeliveryId,
      orElse: () => provider.deliveryTypes.isNotEmpty
          ? provider.deliveryTypes.first
          : DeliveryType(
        id: 0,
        type: "Normal",
        charge: 0,
        minOrderAmount: 0,
        days: "0-0 DAYS",
      ),
    );

    double deliveryCost = selectedType.charge;
    double totalAmount = widget.subtotalAmount + deliveryCost;

    return BaseScreen(
      child: Scaffold(
        backgroundColor: const Color(0xfffdf6ef),
        appBar: AppBar(
          backgroundColor: const Color(0xfffdf6ef),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
            onPressed: () => Navigator.pop(context),
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
                    "₹${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text("Estimated Total",
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            )
          ],
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.errorMessage != null
            ? Center(child: Text(provider.errorMessage!))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  stepBox("1 SHIPPING", false),
                  stepBox("2 DELIVERY", true),
                  stepBox("3 REVIEW", false),
                ],
              ),
              const SizedBox(height: 20),

              _buildOrderSummary(deliveryCost, totalAmount),
              const SizedBox(height: 20),

              if (widget.selectedAddress != null)
                _buildAddressCard(widget.selectedAddress!),
              const SizedBox(height: 20),

              const Text(
                "Delivery Options:",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF160042)),
              ),
              const SizedBox(height: 15),

              ...provider.deliveryTypes.map((type) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedDeliveryId == type.id
                          ? Colors.amber
                          : Colors.grey.shade300,
                      width: _selectedDeliveryId == type.id ? 2 : 1,
                    ),
                  ),
                  child: RadioListTile<int>(
                    value: type.id,
                    groupValue: _selectedDeliveryId,
                    onChanged: (val) {
                      setState(() => _selectedDeliveryId = val);
                    },
                    title: Text(type.type,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(type.days),
                    secondary: Text(
                      "₹${type.charge.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    activeColor: Colors.amber,
                  ),
                );
              }),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Delivery Cost:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      "₹${deliveryCost.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Continue Button
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 10),
                child: mainButton("REVIEW YOUR ORDER", () {
                  if (widget.selectedAddress == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select an address first'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (_selectedDeliveryId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a delivery option'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewScreen(
                        selectedAddress: widget.selectedAddress!,
                        deliveryOption: selectedType.type,
                        deliveryCost: selectedType.charge,
                        subtotalAmount: widget.subtotalAmount,
                        totalAmount: totalAmount,
                        cartItems: widget.cartItems,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildOrderSummary(double deliveryCost, double totalAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Order Summary",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal:"),
              Text("₹${widget.subtotalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Delivery:"),
              Text("₹${deliveryCost.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("₹${totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(address.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              if (address.type.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    address.type,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(address.addressLine1),
          if (address.addressLine2!.isNotEmpty) Text(address.addressLine2!),
          Text("${address.city}, ${address.state} - ${address.postalCode}"),
          Text(address.country),
          const SizedBox(height: 8),
          Text("Phone: ${address.phone}",
              style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}


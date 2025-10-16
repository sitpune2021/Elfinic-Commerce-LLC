import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/AddressModel.dart';
import '../model/cart_models.dart';
import '../providers/ShippingProvider.dart';
import 'AddressListScreen.dart';
import 'ShoppingScreen.dart';


class EditAddressScreen extends StatefulWidget {
  final Address address;
  final double subtotalAmount;
  final List<UserCartItem> cartItems;
  final bool fromProfile; // Add this parameter

  const EditAddressScreen({
    super.key,
    required this.address,
    required this.subtotalAmount,
    required this.cartItems,
    this.fromProfile = false, // Default to false for backward compatibility
  });

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;

  String? selectedAddressType;
  bool useBillingAddress = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing address data
    _fullNameController = TextEditingController(text: widget.address.name);
    _phoneController = TextEditingController(text: widget.address.phone);
    _addressLine1Controller = TextEditingController(text: widget.address.addressLine1);
    _addressLine2Controller = TextEditingController(text: widget.address.addressLine2);
    _cityController = TextEditingController(text: widget.address.city);
    _stateController = TextEditingController(text: widget.address.state);
    _postalCodeController = TextEditingController(text: widget.address.postalCode);

    selectedAddressType = widget.address.type;
    useBillingAddress = widget.address.isDefault == 1;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _updateAddress(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);

      final updatedAddress = Address(
        id: widget.address.id,
        userId: widget.address.userId,
        name: _fullNameController.text.trim(),
        type: selectedAddressType ?? "Home",
        phone: _phoneController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: 'India',
        postalCode: _postalCodeController.text.trim(),
        isDefault: useBillingAddress ? 1 : 0,
      );

      print("🔄 Updating Address: ${updatedAddress.toJson()}");

      final success = await addressProvider.updateAddress(updatedAddress);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back - the parent screen will handle refresh
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${addressProvider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xfffdf6ef),
          appBar: AppBar(
            backgroundColor: const Color(0xfffdf6ef),
            elevation: 0,
            surfaceTintColor: const Color(0xfffdf6ef),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.fromProfile ? "Edit Address" : "Edit Shipping Address",
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            actions: [
              // Only show subtotal if not from profile (i.e., from checkout)
              if (!widget.fromProfile)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "₹${widget.subtotalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Order Subtotal",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Card - Only show for checkout, not for profile
                  if (!widget.fromProfile)
                    _buildOrderSummary(),

                  if (!widget.fromProfile) const SizedBox(height: 20),

                  _label("Address Type*"),
                  _addressTypeSelector(),

                  _label("Full Name*"),
                  _textField(
                    controller: _fullNameController,
                    hint: "Enter full name",
                  ),

                  _label("Mobile Number*"),
                  _textField(
                    controller: _phoneController,
                    hint: "Enter mobile number",
                    keyboardType: TextInputType.phone,
                  ),

                  _label("Address Line 1*"),
                  _textField(
                    controller: _addressLine1Controller,
                    hint: "House no, Street name",
                    suffixIcon: const Icon(Icons.location_on_outlined),
                  ),

                  _label("Address Line 2"),
                  _textField(
                    controller: _addressLine2Controller,
                    hint: "Apartment, suite, etc. (optional)",
                  ),

                  _label("City*"),
                  _textField(
                    controller: _cityController,
                    hint: "Enter city name",
                  ),

                  _label("State*"),
                  _textField(
                    controller: _stateController,
                    hint: "Enter state name",
                  ),

                  _label("Zip / Postal Code*"),
                  _textField(
                    controller: _postalCodeController,
                    hint: "411038",
                    keyboardType: TextInputType.number,
                  ),

                  Row(
                    children: [
                      Checkbox(
                        value: useBillingAddress,
                        onChanged: (val) => setState(() => useBillingAddress = val!),
                      ),
                      const Text("Use as Billing Address"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (addressProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _updateButton("UPDATE ADDRESS", () => _updateAddress(context)),

                  const SizedBox(height: 10),

                  _cancelButton("CANCEL", () => Navigator.pop(context)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Order Summary Widget (only for checkout)
  Widget _buildOrderSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal:"),
              Text(
                "₹${widget.subtotalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Cart Items Summary
          if (widget.cartItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.shopping_cart, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "${widget.cartItems.length} item${widget.cartItems.length != 1 ? 's' : ''} selected",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Helper Widgets

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF160042),
      ),
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "This field is required";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
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
      ),
    );
  }

  Widget _addressTypeSelector() {
    final types = ["Home", "Office", "Other"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: types.map((type) {
        final isSelected = selectedAddressType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => selectedAddressType = type);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.indigo.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.indigo.shade900 : Colors.grey.shade400,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : [],
              ),
              child: Center(
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _updateButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
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

  Widget _cancelButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
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
}

/*
class EditAddressScreen extends StatefulWidget {
  final Address address;
  final double subtotalAmount;
  final List<UserCartItem> cartItems; // Add this

  const EditAddressScreen({
    super.key,
    required this.address,
    required this.subtotalAmount,
    required this.cartItems, // Add this
  });

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;

  String? selectedAddressType;
  bool useBillingAddress = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing address data
    _fullNameController = TextEditingController(text: widget.address.name);
    _phoneController = TextEditingController(text: widget.address.phone);
    _addressLine1Controller = TextEditingController(text: widget.address.addressLine1);
    _addressLine2Controller = TextEditingController(text: widget.address.addressLine2);
    _cityController = TextEditingController(text: widget.address.city);
    _stateController = TextEditingController(text: widget.address.state);
    _postalCodeController = TextEditingController(text: widget.address.postalCode);

    selectedAddressType = widget.address.type;
    useBillingAddress = widget.address.isDefault == 1;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _updateAddress(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);

      final updatedAddress = Address(
        id: widget.address.id,
        userId: widget.address.userId,
        name: _fullNameController.text.trim(),
        type: selectedAddressType ?? "Home",
        phone: _phoneController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: 'India',
        postalCode: _postalCodeController.text.trim(),
        isDefault: useBillingAddress ? 1 : 0,
      );

      print("🔄 Updating Address: ${updatedAddress.toJson()}");

      final success = await addressProvider.updateAddress(updatedAddress);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Simply pop back to AddressListScreen
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${addressProvider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xfffdf6ef),
          appBar: AppBar(
            backgroundColor: const Color(0xfffdf6ef),
            elevation: 0,
            surfaceTintColor: const Color(0xfffdf6ef),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Edit Address",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            actions: [
              // Display subtotal in app bar
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "₹${widget.subtotalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Order Subtotal",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Order Summary",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Subtotal:"),
                            Text(
                              "₹${widget.subtotalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Cart Items Summary
                        if (widget.cartItems.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.shopping_cart, size: 16, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                "${widget.cartItems.length} item${widget.cartItems.length != 1 ? 's' : ''} selected",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _label("Address Type*"),
                  _addressTypeSelector(),

                  _label("Full Name*"),
                  _textField(
                    controller: _fullNameController,
                    hint: "Enter full name",
                  ),

                  _label("Mobile Number*"),
                  _textField(
                    controller: _phoneController,
                    hint: "Enter mobile number",
                    keyboardType: TextInputType.phone,
                  ),

                  _label("Address Line 1*"),
                  _textField(
                    controller: _addressLine1Controller,
                    hint: "House no, Street name",
                    suffixIcon: const Icon(Icons.location_on_outlined),
                  ),

                  _label("Address Line 2"),
                  _textField(
                    controller: _addressLine2Controller,
                    hint: "Apartment, suite, etc. (optional)",
                  ),

                  _label("City*"),
                  _textField(
                    controller: _cityController,
                    hint: "Enter city name",
                  ),

                  _label("State*"),
                  _textField(
                    controller: _stateController,
                    hint: "Enter state name",
                  ),

                  _label("Zip / Postal Code*"),
                  _textField(
                    controller: _postalCodeController,
                    hint: "411038",
                    keyboardType: TextInputType.number,
                  ),

                  Row(
                    children: [
                      Checkbox(
                        value: useBillingAddress,
                        onChanged: (val) => setState(() => useBillingAddress = val!),
                      ),
                      const Text("Use as Billing Address"),
                    ],
                  ),

                  const SizedBox(height: 20),
                  if (addressProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _updateButton("UPDATE ADDRESS", () => _updateAddress(context)),

                  const SizedBox(height: 10),

                  _cancelButton("CANCEL", () => Navigator.pop(context)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper Widgets

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF160042),
      ),
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "This field is required";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
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
      ),
    );
  }

  Widget _addressTypeSelector() {
    final types = ["Home", "Office", "Other"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: types.map((type) {
        final isSelected = selectedAddressType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => selectedAddressType = type);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.indigo.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? Colors.indigo.shade900 : Colors.grey.shade400,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : [],
              ),
              child: Center(
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _updateButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
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

  Widget _cancelButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
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
}
*/


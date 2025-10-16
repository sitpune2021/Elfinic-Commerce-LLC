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
import 'delivery_screen.dart';




// ------------------- Shipping Screen -------------------
// Shipping Screen (Used for both adding and editing addresses)
class ShippingScreen extends StatefulWidget {
  final double subtotalAmount;
  final List<UserCartItem> cartItems;
  final bool fromProfile;
  final Address? address; // For edit mode

  const ShippingScreen({
    super.key,
    required this.subtotalAmount,
    required this.cartItems,
    this.fromProfile = false,
    this.address,
  });

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? gstOption;
  bool useBillingAddress = false;
  String? selectedAddressType;

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  int? _userId;
  String? _userName;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _resetProviderState();
    _initializeEditMode();
  }

  void _initializeEditMode() {
    if (widget.address != null) {
      _isEditMode = true;
      _populateFormWithAddress(widget.address!);
    }
  }

  void _populateFormWithAddress(Address address) {
    _fullNameController.text = address.name;
    _phoneController.text = address.phone;
    _addressLine1Controller.text = address.addressLine1;
    _addressLine2Controller.text = address.addressLine2!;
    _cityController.text = address.city;
    _stateController.text = address.state;
    _postalCodeController.text = address.postalCode;
    selectedAddressType = address.type;
    useBillingAddress = address.isDefault == 1;
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = int.tryParse(prefs.getString("user_id") ?? '');
        _userName = prefs.getString("user_name");
      });

      if (_userName != null && _userName!.isNotEmpty && !_isEditMode) {
        _fullNameController.text = _userName!;
      }
    } catch (e) {
      print("❌ Error loading user data: $e");
    }
  }

  void _resetProviderState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      addressProvider.resetLoading();
    });
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

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to continue'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final addressProvider = Provider.of<AddressProvider>(context, listen: false);

      final address = Address(
        id: _isEditMode ? widget.address!.id : null,
        userId: _userId!,
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

      final success = _isEditMode
          ? await addressProvider.updateAddress(address)
          : await addressProvider.addAddress(address);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Address ${_isEditMode ? 'updated' : 'added'} successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        _resetForm();

        // Navigate based on context
        if (widget.fromProfile || _isEditMode) {
          // Go back to address list
          Navigator.pop(context);
        } else {
          // Proceed to delivery for checkout
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DeliveryScreen(
                selectedAddress: address,
                subtotalAmount: widget.subtotalAmount,
                cartItems: widget.cartItems,
              ),
            ),
          );
        }
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

  void _resetForm() {
    if (!_isEditMode) {
      _formKey.currentState?.reset();
      setState(() {
        selectedAddressType = null;
        useBillingAddress = false;
      });
      _fullNameController.clear();
      _phoneController.clear();
      _addressLine1Controller.clear();
      _addressLine2Controller.clear();
      _cityController.clear();
      _stateController.clear();
      _postalCodeController.clear();

      if (_userName != null && _userName!.isNotEmpty) {
        _fullNameController.text = _userName!;
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
              onPressed: () {
                addressProvider.resetLoading();
                Navigator.pop(context);
              },
            ),
            title: Text(
              _isEditMode ? "Edit Address" : "Add Address",
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            actions: widget.fromProfile ? null : [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "₹${widget.subtotalAmount.toStringAsFixed(2)}",
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
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Step indicator (only for checkout)
                          if (!widget.fromProfile) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _stepBox("1 SHIPPING", true),
                                _stepBox("2 DELIVERY", false),
                                _stepBox("3 REVIEW", false),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Order Summary Card (only for checkout)
                          if (!widget.fromProfile)
                            _buildOrderSummary(),

                          const SizedBox(height: 16),

                          if (_userId != null)
                            _buildUserInfo(),

                          const SizedBox(height: 16),
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
                            _mainButton(
                                _isEditMode ? "UPDATE ADDRESS" : "CONTINUE",
                                    () => _submitForm(context)
                            ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal:"),
              Text(
                "₹${widget.subtotalAmount.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (widget.cartItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.shopping_cart, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "${widget.cartItems.length} item${widget.cartItems.length != 1 ? 's' : ''}",
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

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Logged in as: $_userName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

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
            onTap: () => setState(() => selectedAddressType = type),
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
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ] : [],
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
}


/*
class ShippingScreen extends StatefulWidget {
  final double subtotalAmount;
  final List<UserCartItem> cartItems; // Add this

  const ShippingScreen({
    super.key,
    required this.subtotalAmount,
    required this.cartItems, // Add this
  });

  @override
  State<ShippingScreen> createState() => _ShippingScreenState();
}

class _ShippingScreenState extends State<ShippingScreen> {
  final _formKey = GlobalKey<FormState>();

  String? gstOption;
  bool useBillingAddress = false;

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  String? selectedAddressType;

  int? _userId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _resetProviderState();
  }

  // Load user data
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = int.tryParse(prefs.getString("user_id") ?? '');
        _userName = prefs.getString("user_name");
      });

      if (_userName != null && _userName!.isNotEmpty) {
        _fullNameController.text = _userName!;
      }
    } catch (e) {
      print("❌ Error loading user data: $e");
    }
  }

  // Reset provider state when screen initializes
  void _resetProviderState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      addressProvider.resetLoading(); // Call the new reset method
    });
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

    // Reset loading state when screen is disposed
    _resetLoadingState();
    super.dispose();
  }

  Future<void> _resetLoadingState() async {
    // Use a delayed future to ensure context is still available
    await Future.delayed(Duration.zero);

    // Check if the widget is still mounted and context is available
    if (mounted) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);

      // Option 1: If you added resetLoading() method to AddressProvider
      addressProvider.resetLoading();

      // Option 2: If you don't have resetLoading(), call fetchAddresses to reset state
      // addressProvider.fetchAddresses().catchError((_) {});
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to continue'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final addressProvider = Provider.of<AddressProvider>(context, listen: false);

      final address = Address(
        userId: _userId!,
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

      print("📦 Address Data: ${address.toJson()}");

      final success = await addressProvider.addAddress(address);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset the form after successful submission
        _resetForm();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DeliveryScreen(
              selectedAddress: address, // 👈 Pass the new address
              subtotalAmount: widget.subtotalAmount, // 👈 Pass subtotal to DeliveryScreen
              cartItems: widget.cartItems, // 👈 Pass cart items to DeliveryScreen
            ),
          ),
        );

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

  // Reset form fields
  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      selectedAddressType = null;
      useBillingAddress = false;
    });
    _fullNameController.clear();
    _phoneController.clear();
    _addressLine1Controller.clear();
    _addressLine2Controller.clear();
    _cityController.clear();
    _stateController.clear();
    _postalCodeController.clear();

    // Reload user name if available
    if (_userName != null && _userName!.isNotEmpty) {
      _fullNameController.text = _userName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        // Reset loading state when screen builds
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (addressProvider.isLoading) {
            addressProvider.resetLoading();
          }
        });

        return BaseScreen(
          child: Scaffold(
            backgroundColor: const Color(0xfffdf6ef),
            appBar: AppBar(
              backgroundColor: const Color(0xfffdf6ef),
              elevation: 0,
              surfaceTintColor: const Color(0xfffdf6ef),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
                onPressed: () {
                  // Reset provider state when going back
                  addressProvider.resetLoading();
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
                        "₹${widget.subtotalAmount.toStringAsFixed(2)}", // Updated to use passed subtotal
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

            body: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // Important: Use min instead of max
                          children: [
                            // Step indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                stepBox("1 SHIPPING", true),
                                stepBox("2 DELIVERY", false),
                                stepBox("3 REVIEW", false),
                              ],
                            ),
                            const SizedBox(height: 20),

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
                                  )
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
                                          "${widget.cartItems.length} item${widget.cartItems.length != 1 ? 's' : ''}",
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
                            const SizedBox(height: 16),

                            if (_userId != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Logged in as: $_userName',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 16),
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

                            // Always show the CONTINUE button, only show loader during actual submission
                            if (addressProvider.isLoading)
                              const Center(child: CircularProgressIndicator())
                            else
                              mainButton("CONTINUE", () => _submitForm(context)),

                            // Add extra bottom padding for better scrolling
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Helper Widgets (keep the same as before)
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
}
*/

// --- Reusable Widgets ---
Widget stepBox(String text, bool active) {
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

Widget mainButton(String text, VoidCallback onPressed) {
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



// ------------------- Delivery Screen -------------------






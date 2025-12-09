import 'package:flutter/material.dart';


import '../model/AddressModel.dart';
import '../model/cart_models.dart';
import '../providers/ShippingProvider.dart';
import 'CartScreen.dart';
import 'EditAddressScreen.dart';
import 'ShoppingScreen.dart';

import 'package:provider/provider.dart';

import 'delivery_screen.dart';
class AddressScreen extends StatefulWidget {
  final bool fromProfile;
  final double subtotalAmount;
  final List<UserCartItem> cartItems;
  final Coupon? appliedCoupon;
  final double couponDiscount;

  const AddressScreen({
    super.key,
    required this.fromProfile,
    this.subtotalAmount = 0.0,
    this.cartItems = const [],
    this.appliedCoupon,
    this.couponDiscount = 0.0,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  Address? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      addressProvider.fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: const Color(0xfffdf6ef),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.fromProfile ? 'My Addresses' : 'Select Address'),
        backgroundColor: const Color(0xFF050040),
      ),
      body: addressProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : addressProvider.addresses.isEmpty
          ? _buildEmptyState(addressProvider)
          : _buildAddressList(addressProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddAddress(context),
        icon: const Icon(Icons.add_location,color: Color(0xFF050040),),
        label: const Text("Add Address",style: TextStyle(color: Color(0xFF050040)),),
        backgroundColor: Colors.amber.shade700,
      ),
    );
  }

  Widget _buildEmptyState(AddressProvider addressProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No addresses found",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              "Add New Address",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _navigateToAddAddress(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(AddressProvider addressProvider) {
    return Column(
      children: [
        // Order Summary (only for checkout)
        if (!widget.fromProfile && widget.subtotalAmount != null) ...[
          _buildOrderSummary(),
          if (widget.cartItems != null && widget.cartItems!.isNotEmpty)
            _buildCartSummary(),
        ],
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: addressProvider.addresses.length,
            itemBuilder: (context, index) {
              final address = addressProvider.addresses[index];
              final isSelected = _selectedAddress == address;

              return _buildAddressItem(address, isSelected, addressProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.amber.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Order Subtotal:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "₹${widget.subtotalAmount!.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const Icon(Icons.shopping_cart, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            "${widget.cartItems!.length} item${widget.cartItems!.length != 1 ? 's' : ''} selected",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
          const Spacer(),
          Text(
            "Total: ₹${widget.subtotalAmount!.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressItem(Address address, bool isSelected, AddressProvider addressProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
        border: isSelected && !widget.fromProfile
            ? Border.all(color: Colors.green, width: 1.5)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: widget.fromProfile
            ? _buildAddressTypeIcon(address.type)
            : Radio<Address>(
          value: address,
          groupValue: _selectedAddress,
          onChanged: (Address? value) {
            setState(() {
              _selectedAddress = value;
            });
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                address.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            // if (address.type.isNotEmpty && !widget.fromProfile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                address.type,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${address.addressLine1}, ${address.city}, ${address.state}, ${address.country} - ${address.postalCode}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                "Phone: ${address.phone}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected && !widget.fromProfile)
              const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF050040)),
              onPressed: () => _navigateToEditScreen(context, address),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmationDialog(context, addressProvider, address),
            ),
          ],
        ),
        onTap: widget.fromProfile
            ? null
            : () {
          setState(() {
            _selectedAddress = address;
          });
          _navigateToDelivery(context, address);
        },
      ),
    );
  }

  Widget _buildAddressTypeIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'home':
        icon = Icons.home;
        color = Color(0xFF050040);
        break;
      case 'office':
        icon = Icons.work;
        color = Colors.green;
        break;
      default:
        icon = Icons.location_on;
        color =  const Color(0xFFD39841);
    }

    return Icon(icon, color: color);
  }

  void _navigateToAddAddress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShippingScreen(
          subtotalAmount: widget.subtotalAmount ?? 0.0,
          cartItems: widget.cartItems ?? [],
          fromProfile: widget.fromProfile,
        ),
      ),
    ).then((_) {
      _loadAddresses();
    });
  }

  void _navigateToEditScreen(BuildContext context, Address address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAddressScreen(
          address: address,
          subtotalAmount: widget.subtotalAmount ?? 0.0,
          cartItems: widget.cartItems ?? [],
          fromProfile: widget.fromProfile,
        ),
      ),
    ).then((_) {
      _loadAddresses();
    });
  }

  void _navigateToDelivery(BuildContext context, Address address) {
    if (widget.fromProfile || widget.subtotalAmount == null || widget.cartItems == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DeliveryScreen(
          selectedAddress: address,
          subtotalAmount: widget.subtotalAmount!,
          cartItems: widget.cartItems!,
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context,
      AddressProvider addressProvider,
      Address address
      ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: const Color(0x20D39841), // #D39841 with 12% opacity
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFD39841), // #D39841
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Delete Address",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Content
                Text(
                  "Are you sure you want to delete ${address.name}'s address?",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),



                const SizedBox(height: 28),

                // Actions
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Delete Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _deleteAddress(context, addressProvider, address);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD39841), // #D39841
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Delete",
                          style: TextStyle(
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
      },
    );
  }
  Future<void> _deleteAddress(BuildContext context, AddressProvider addressProvider, Address address) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final success = await addressProvider.deleteAddress(address.id!);

      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('${address.name}\'s address deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete address: ${addressProvider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error deleting address: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


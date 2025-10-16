import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/AddressModel.dart';
import '../model/cart_models.dart';
import '../providers/ShippingProvider.dart';
import 'EditAddressScreen.dart';
import 'ShoppingScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'delivery_screen.dart';

  class AddressListScreen extends StatefulWidget {
  final double subtotalAmount;
  final List<UserCartItem> cartItems; // Add this

  const AddressListScreen({
    super.key,
    required this.subtotalAmount,
    required this.cartItems, // Add this
  });

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  Address? _selectedAddress;

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
        title: const Text('My Addresses'),
        backgroundColor: const Color(0xFF050040),
      ),
      body: addressProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : addressProvider.addresses.isEmpty
          ? Center(
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShippingScreen(
                      subtotalAmount: widget.subtotalAmount,
                      cartItems: widget.cartItems, // Pass cart items
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Display subtotal at the top
          Container(
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
                  "₹${widget.subtotalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          // Cart Items Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
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
                const Spacer(),
                Text(
                  "Total: ₹${widget.subtotalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: addressProvider.addresses.length,
              itemBuilder: (context, index) {
                final address = addressProvider.addresses[index];
                final isSelected = _selectedAddress == address;

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
                    border: isSelected
                        ? Border.all(color: Colors.green, width: 1.5)
                        : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Radio<Address>(
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
                        if (address.type.isNotEmpty)
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
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        // Edit Button
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _navigateToEditScreen(context, address);
                          },
                        ),
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, addressProvider, address);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _selectedAddress = address;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeliveryScreen(
                            selectedAddress: address,
                            subtotalAmount: widget.subtotalAmount,
                            cartItems: widget.cartItems, // Pass cart items to DeliveryScreen
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShippingScreen(
                subtotalAmount: widget.subtotalAmount,
                cartItems: widget.cartItems, // Pass cart items
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_location),
        label: const Text("Add Address"),
        backgroundColor: Colors.amber.shade700,
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, Address address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAddressScreen(
          address: address,
          subtotalAmount: widget.subtotalAmount,
          cartItems: widget.cartItems, // Pass cart items to EditAddressScreen
        ),
      ),
    ).then((_) {
      // Refresh the address list when returning from edit screen
      Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, AddressProvider addressProvider, Address address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Address"),
          content: Text("Are you sure you want to delete ${address.name}'s address?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAddress(context, addressProvider, address);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
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




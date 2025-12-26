import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../model/ProductsResponse.dart';
import '../model/cart_models.dart';
import '../services/api_service.dart';




import 'dart:convert';
import 'package:flutter/foundation.dart';
class CartProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<UserCartItem> _cartItems = [];
  final Set<int> _selectedCartIds = {};
  // bool _cartClearedByPayment = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserCartItem> get cartItems => List.unmodifiable(_cartItems);
  int get selectedCount => _selectedCartIds.length;
  int get totalCartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _cartItems
      .where((item) => _selectedCartIds.contains(item.cartId))
      .fold(0.0, (sum, item) {
    final price = double.tryParse(item.product.discountPrice.replaceAll(',', '')) ?? 0;
    return sum + (price * item.quantity);
  });

  // Initialize the flag from SharedPreferences
  CartProvider() {
    _loadCartClearedFlag();
  }

  // Load the flag from persistent storage
  Future<void> _loadCartClearedFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // _cartClearedByPayment = prefs.getBool('cart_cleared_by_payment') ?? false;
      //
      // if (kDebugMode) {
      //   print('🛒 Cart cleared flag loaded: $_cartClearedByPayment');
      // }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading cart cleared flag: $e');
      }
    }
  }

  // Save the flag to persistent storage
  /*Future<void> _saveCartClearedFlag(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('cart_cleared_by_payment', value);
      // _cartClearedByPayment = value;

      if (kDebugMode) {
        print('🛒 Cart cleared flag saved: $value');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving cart cleared flag: $e');
      }
    }
  }*/

  // UPDATED: Local-only cart clearance with persistent flag
  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Set flag to prevent server reload (persistently)
      // await _saveCartClearedFlag(true);

      // Clear local cart state only
      _cartItems.clear();
      _selectedCartIds.clear();
      _error = null;

      if (kDebugMode) {
        print('🛒 Cart cleared locally (payment completed)');
      }
    } catch (e) {
      _error = 'Error clearing cart: $e';
      if (kDebugMode) {
        print('❌ Error clearing cart: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MODIFIED: Fetch cart items with payment check
  Future<void> fetchCartItems() async {
    // Don't fetch from server if cart was cleared by payment
    // if (_cartClearedByPayment) {
    //   if (kDebugMode) {
    //     print('🛒 Skipping server fetch - cart cleared by payment');
    //   }
    //   return;
    // }

    _isLoading = true;
    notifyListeners();

    try {
      _cartItems = await ApiService.fetchCartItems();
      _error = null;

      // Auto-select all items when cart loads
      _selectedCartIds.clear();
      _selectedCartIds.addAll(_cartItems.map((e) => e.cartId));

      if (kDebugMode) {
        print('🛒 Cart loaded from server: ${_cartItems.length} items');
      }
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('Cart is empty')) {
        handleEmptyCart();
      } else {
        _error = e.toString();
        debugPrint("❌ fetchCartItems error: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NEW: Reset the flag when user adds items to cart
  Future<void> addToCart(Product product, int quantity, {int? variantId}) async {
    try {
      // Reset cleared flag if needed
      // if (_cartClearedByPayment) {
      //   await _saveCartClearedFlag(false);
      //   if (kDebugMode) {
      //     print('🛒 Cart cleared flag reset - user adding new items');
      //   }
      // }

      /// Check if same product + variant already exists
    /*  final existingIndex = _cartItems.indexWhere((item) =>
      item.productId == product.id &&
          item.product.variantId == variantId);

      if (existingIndex != -1) {
        // Increase quantity
        final existingItem = _cartItems[existingIndex];
        await updateQuantity(existingItem, existingItem.quantity + quantity);
        return;
      }*/

      // Call API
      final response = await ApiService.addToCartApi(
        productId: product.id,
        quantity: quantity,
        variantId: variantId,
      );

      if (response.status != "success") {
        throw Exception(response.message);
      }

      // 🚀 Always sync cart from backend after add
      await fetchCartItems();

    } catch (e) {
      debugPrint("❌ addToCart error: $e");
      rethrow;
    }
  }


  // NEW: Manual method to reset the flag if needed
  Future<void> resetCartClearedFlag() async {
    // await _saveCartClearedFlag(false);
    if (kDebugMode) {
      print('🛒 Cart cleared flag manually reset');
    }
  }

  // NEW: Check if cart was cleared by payment
  // bool get wasCartClearedByPayment => _cartClearedByPayment;

  // ... rest of your existing methods (updateQuantity, removeFromCart, etc.) remain the same
  Future<void> updateQuantity(UserCartItem item, int newQty) async {
    try {
      if (newQty < 1) {
        await removeFromCart(item, null);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = int.parse(prefs.getString("user_id")!);

      final isIncrease = newQty > item.quantity;

      await ApiService.updateQuantity(
        userId: userId,
        productId: item.productId,
        variantId: item.product.selectedVariantId, // ✅ FIX
        increase: isIncrease,
      );

      // Single source of truth
      await fetchCartItems();

    } catch (e) {
      debugPrint("❌ updateQuantity failed: $e");
      rethrow;
    }
  }


  Future<void> removeFromCart(UserCartItem item, BuildContext? context) async {
    try {
      final success = await ApiService.removeCartItem(item.cartId);

      if (success) {
        removeLocalItem(item.cartId);

        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Item removed from cart")),
          );
        }
      } else {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to remove item")),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ removeFromCart error: $e");
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  // Product utilities
  bool isProductInCart(int productId) => getQuantityForProduct(productId) > 0;

  UserCartItem? getCartItemForProduct(int productId) {
    try {
      return _cartItems.firstWhere((item) => item.productId == productId && item.quantity > 0);
    } catch (e) {
      return null;
    }
  }

  int getQuantityForProduct(int productId) {
    final cartItem = getCartItemForProduct(productId);
    return cartItem?.quantity ?? 0;
  }

  // Selection methods and other existing methods...
  bool isSelected(UserCartItem item) => _selectedCartIds.contains(item.cartId);

  void toggleSelection(UserCartItem item) {
    if (_selectedCartIds.contains(item.cartId)) {
      _selectedCartIds.remove(item.cartId);
    } else {
      _selectedCartIds.add(item.cartId);
    }
    notifyListeners();
  }

  void selectAll() {
    _selectedCartIds.addAll(_cartItems.map((e) => e.cartId));
    notifyListeners();
  }

  void clearSelection() {
    _selectedCartIds.clear();
    notifyListeners();
  }

  List<UserCartItem> getSelectedCartItems() {
    return _cartItems.where((item) => _selectedCartIds.contains(item.cartId)).toList();
  }

  void updateLocalQuantity(int cartId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.cartId == cartId);
    if (index != -1) {
      _cartItems[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  void removeLocalItem(int cartId) {
    _cartItems.removeWhere((item) => item.cartId == cartId);
    _selectedCartIds.remove(cartId);
    notifyListeners();
  }

  void handleEmptyCart() {
    _cartItems.clear();
    _selectedCartIds.clear();
    _error = null;
    notifyListeners();
  }
}







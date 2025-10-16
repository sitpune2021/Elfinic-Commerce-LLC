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

  // Selection methods
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

  // Local state management
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

  // API operations
  Future<void> fetchCartItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cartItems = await ApiService.fetchCartItems();
      _error = null;

      // Auto-select all items when cart loads
      _selectedCartIds.clear();
      _selectedCartIds.addAll(_cartItems.map((e) => e.cartId));



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

  Future<void> addToCart(Product product, int quantity) async {
    try {
      final existingItemIndex = _cartItems.indexWhere((item) => item.productId == product.id);

      if (existingItemIndex != -1) {
        final existingItem = _cartItems[existingItemIndex];
        await updateQuantity(existingItem, existingItem.quantity + quantity);
      } else {
        final response = await ApiService.addToCartApi(
          productId: product.id,
          quantity: quantity,
        );

        // Use product_thumb instead of images[0]
        final cartItem = UserCartItem(
            cartId: response.data?.id ?? 0,
            productId: product.id,
            userId: response.data?.userId ?? 0,
            quantity: response.data?.quantity ?? quantity,
            product: UserCartProduct(
              id: product.id,
              name: product.name,
              sku: product.sku ?? '',
              barcode: product.barcode ?? '',
              images: product.images ?? [],
              thumb: product.productThumb ?? '', // Use product_thumb here
              description: product.description ?? '',
              price: product.price.toString(),
              discountPrice: product.discountPrice.toString(),
              stock: product.stock ?? 0,
              status: product.status ?? '',
            )
        );

        _cartItems.add(cartItem);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ addToCart error: $e");
      rethrow;
    }
  }
  Future<void> updateQuantity(UserCartItem item, int newQty) async {
    try {
      if (newQty < 1) {
        await removeFromCart(item, null);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString('user_id') ?? "0") ?? 0;

      final isIncrease = newQty > item.quantity;
      final updatedQty = await ApiService.updateQuantity(
        userId: userId,
        productId: item.productId,
        increase: isIncrease,
      );

      if (updatedQty == 0) {
        await removeFromCart(item, null);
      } else {
        updateLocalQuantity(item.cartId, updatedQty);
      }
    } catch (e) {
      debugPrint("❌ updateQuantity error: $e");
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
}

/*
class CartProvider with ChangeNotifier {

  bool _isLoading = false;
  String? _error;
  List<UserCartItem> _cartItems = [];
  final Set<int> _selectedCartIds = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserCartItem> get cartItems => _cartItems;
  int get selectedCount => _selectedCartIds.length;

  // Get total cart count (sum of all quantities)
  int get totalCartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _cartItems
      .where((item) => _selectedCartIds.contains(item.cartId))
      .fold(0.0, (sum, item) {
    final price = double.tryParse(item.product.discountPrice.replaceAll(',', '')) ?? 0;
    return sum + price * item.quantity;
  });

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

  // ✅ Get selected cart items
  List<UserCartItem> getSelectedCartItems() {
    return _cartItems.where((item) => _selectedCartIds.contains(item.cartId)).toList();
  }

  // ✅ Get all cart items
  List<UserCartItem> getAllCartItems() {
    return List.from(_cartItems);
  }

  // ✅ NEW: Update specific cart item quantity locally
  void updateLocalQuantity(int cartId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.cartId == cartId);
    if (index != -1) {
      _cartItems[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  // ✅ NEW: Remove item locally
  void removeLocalItem(int cartId) {
    _cartItems.removeWhere((item) => item.cartId == cartId);
    _selectedCartIds.remove(cartId);
    notifyListeners();
  }

  // ✅ NEW: Handle empty cart properly
  void handleEmptyCart() {
    _cartItems.clear();
    _selectedCartIds.clear();
    _error = null;
    notifyListeners();
  }

  /// ✅ Fetch Cart Items - IMPROVED: Handle empty cart scenario
  Future<void> fetchCartItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cartItems = await ApiService.fetchCartItems();
      _error = null;

      // Auto-select all items when cart loads
      _selectedCartIds.clear();
      _selectedCartIds.addAll(_cartItems.map((e) => e.cartId));
    } catch (e) {
      // Handle empty cart scenario (404 error)
      if (e.toString().contains('404') || e.toString().contains('Cart is empty')) {
        handleEmptyCart();
      } else {
        _error = e.toString();
        debugPrint("❌ fetchCartItems error: $e");
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ Add to Cart
  Future<void> addToCart(Product product, int quantity) async {
    try {
      final existingItemIndex = _cartItems.indexWhere((item) => item.productId == product.id);

      if (existingItemIndex != -1) {
        final existingItem = _cartItems[existingItemIndex];
        await updateQuantity(existingItem, existingItem.quantity + quantity);
      } else {
        final response = await ApiService.addToCartApi(
          productId: product.id,
          quantity: quantity,
        );

        _cartItems.add(UserCartItem(
            cartId: response.data?.id ?? 0,
            productId: product.id,
            userId: response.data?.userId ?? 0,
            quantity: response.data?.quantity ?? quantity,
            product: UserCartProduct(
              id: product.id,
              name: product.name,
              sku: product.sku ?? '',
              barcode: product.barcode ?? '',
              images: product.images ?? [],
              thumb: (product.images != null && product.images.isNotEmpty) ? product.images[0] : '',
              description: product.description ?? '',
              price: product.price.toString(),
              discountPrice: product.discountPrice.toString(),
              stock: product.stock ?? 0,
              status: product.status ?? '',
            )
        ));

        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ addToCart error: $e");
    }
  }

  /// ✅ Update Quantity
  Future<void> updateQuantity(UserCartItem item, int newQty) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString('user_id') ?? "0") ?? 0;

      if (newQty < 1) {
        await removeFromCart(item, null);
        return;
      }

      final isIncrease = newQty > item.quantity;
      final updatedQty = await ApiService.updateQuantity(
        userId: userId,
        productId: item.productId,
        increase: isIncrease,
      );

      if (updatedQty == 0) {
        await removeFromCart(item, null);
      } else {
        updateLocalQuantity(item.cartId, updatedQty);
      }
    } catch (e) {
      debugPrint("❌ updateQuantity error: $e");
    }
  }

  /// ✅ Remove from Cart
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

  /// ✅ Check if product is in cart
  bool isProductInCart(int productId) {
    return getQuantityForProduct(productId) > 0;
  }

  /// ✅ Get cart item for product
  UserCartItem? getCartItemForProduct(int productId) {
    return _cartItems.firstWhereOrNull((item) => item.productId == productId && item.quantity > 0);
  }

  /// ✅ Get quantity for a specific product
  int getQuantityForProduct(int productId) {
    final cartItem = _cartItems.firstWhereOrNull((item) => item.productId == productId && item.quantity > 0);
    return cartItem?.quantity ?? 0;
  }
}
*/



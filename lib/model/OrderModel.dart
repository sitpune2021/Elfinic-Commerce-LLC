// models/create_order_request.dart
class CreateOrderRequest {
  final int userId;
  final double totalAmount;
  final String? couponCode;
  final double discountAmount;
  final double coinsUsed;
  final int addressId;
  final List<OrderCartItem> cart;

  CreateOrderRequest({
    required this.userId,
    required this.totalAmount,
    this.couponCode,
    required this.discountAmount,
    required this.coinsUsed,
    required this.addressId,
    required this.cart,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "total_amount": totalAmount,
      "coupon_code": couponCode,
      "discount_amount": discountAmount,
      "coins_used": coinsUsed,
      "address_id": addressId,
      "cart": cart.map((e) => e.toJson()).toList(),
    };
  }
}


// models/create_order_response.dart
class OrderCartItem {
  final int productId;
  final int variantId;
  final int quantity;
  final double price;
  final double discount;

  OrderCartItem({
    required this.productId,
    required this.variantId,
    required this.quantity,
    required this.price,
    required this.discount,
  });

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "variant_id": variantId,
      "quantity": quantity,
      "price": price,
      "discount": discount,
    };
  }
}
class CreateOrderResponse {
  final int orderId;
  final String razorpayOrderId;
  final double amount;
  final String currency;
  final String keyId;

  CreateOrderResponse({
    required this.orderId,
    required this.razorpayOrderId,
    required this.amount,
    required this.currency,
    required this.keyId,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      orderId: json['order_id'],
      razorpayOrderId: json['razorpay_order_id'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      keyId: json['key_id'],
    );
  }
}

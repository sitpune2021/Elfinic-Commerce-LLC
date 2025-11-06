// models/create_order_request.dart
class CreateOrderRequest {
  final double amount;

  CreateOrderRequest({
    required this.amount,
  });

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
    };
  }

  // For debugging
  @override
  String toString() {
    return 'CreateOrderRequest{amount: $amount}';
  }
}

// models/create_order_response.dart
class CreateOrderResponse {
  final String orderId;
  final double amount;

  CreateOrderResponse({
    required this.orderId,
    required this.amount,
  });

  // Factory constructor to create instance from JSON
  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  // Convert to JSON (if needed for storage)
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'amount': amount,
    };
  }

  // For debugging
  @override
  String toString() {
    return 'CreateOrderResponse{orderId: $orderId, amount: $amount}';
  }

  // Override equality for testing
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CreateOrderResponse &&
              runtimeType == other.runtimeType &&
              orderId == other.orderId &&
              amount == other.amount;

  @override
  int get hashCode => orderId.hashCode ^ amount.hashCode;
}
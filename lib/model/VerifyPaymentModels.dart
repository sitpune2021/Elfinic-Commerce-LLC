// models/verify_payment_request.dart
class VerifyPaymentRequest {
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  VerifyPaymentRequest({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  Map<String, dynamic> toJson() {
    return {
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
    };
  }

  @override
  String toString() {
    return 'VerifyPaymentRequest{razorpayOrderId: $razorpayOrderId, razorpayPaymentId: $razorpayPaymentId, razorpaySignature: $razorpaySignature}';
  }
}



// models/verify_payment_response.dart
// models/verify_payment_response.dart
class VerifyPaymentResponse {
  final bool success;
  final String message;
  final String? orderId;
  final String? paymentId;

  VerifyPaymentResponse({
    required this.success,
    required this.message,
    this.orderId,
    this.paymentId,
  });

  factory VerifyPaymentResponse.fromJson(Map<String, dynamic> json) {
    return VerifyPaymentResponse(
      // Handle both 'success' boolean and 'status' string
      success: _parseSuccess(json),
      message: json['message'] as String? ?? 'No message provided',
      orderId: json['order_id'] as String?,
      paymentId: json['payment_id'] as String?,
    );
  }

  // Helper method to parse success from different field names
  static bool _parseSuccess(Map<String, dynamic> json) {
    // Try 'success' field first (boolean)
    if (json['success'] != null) {
      return json['success'] as bool;
    }

    // Try 'status' field as alternative (string)
    if (json['status'] != null) {
      final status = json['status'] as String;
      return status.toLowerCase() == 'success';
    }

    // Default to false if neither field is present
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'order_id': orderId,
      'payment_id': paymentId,
    };
  }

  @override
  String toString() {
    return 'VerifyPaymentResponse{success: $success, message: $message, orderId: $orderId, paymentId: $paymentId}';
  }
}
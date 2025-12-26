// models/verify_payment_request.dart
class VerifyPaymentRequest {
  final String orderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  VerifyPaymentRequest({
    required this.orderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  Map<String, dynamic> toJson() {
    return {
      "order_id": orderId,   // 🔥 backend expects this
      "razorpay_payment_id": razorpayPaymentId,
      "razorpay_signature": razorpaySignature,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}




// models/verify_payment_response.dart
class VerifyPaymentResponse {
  final bool success;
  final String message;

  VerifyPaymentResponse({
    required this.success,
    required this.message,
  });

  factory VerifyPaymentResponse.fromJson(Map<String, dynamic> json) {
    return VerifyPaymentResponse(
      success: json['status'] == 'success',   // 🔥 your API returns string
      message: json['message'] ?? '',
    );
  }

  @override
  String toString() {
    return "VerifyPaymentResponse{success: $success, message: $message}";
  }
}

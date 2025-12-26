import 'dart:convert';

class AddToCartResponse {
  final String status;
  final String message;

  AddToCartResponse({
    required this.status,
    required this.message,
  });

  factory AddToCartResponse.fromJson(Map<String, dynamic> json) {
    return AddToCartResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }

  static AddToCartResponse fromRawJson(String str) =>
      AddToCartResponse.fromJson(json.decode(str));
}


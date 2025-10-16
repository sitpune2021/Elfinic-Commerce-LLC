import 'dart:convert';

class RegisterResponse {
  final String status;
  final String message;
  final RegisterData data;
  final String token;

  RegisterResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.token,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'] ?? "",
      message: json['message'] ?? "",
      data: RegisterData.fromJson(json['data']),
      token: json['token'] ?? "",
    );
  }

  factory RegisterResponse.fromRawJson(String str) =>
      RegisterResponse.fromJson(json.decode(str));
}

class RegisterData {
  final int id;
  final String name;
  final String email;

  RegisterData({
    required this.id,
    required this.name,
    required this.email,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      email: json['email'] ?? "",
    );
  }
}

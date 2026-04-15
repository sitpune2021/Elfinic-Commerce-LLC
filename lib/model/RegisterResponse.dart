// ignore_for_file: file_names

import 'dart:convert';

RegisterResponse registerResponseFromRawJson(String str) =>
    RegisterResponse.fromJson(json.decode(str));

class RegisterResponse {
  final String status;
  final String? message;
  final RegisterData? data;
  final String? token;

  RegisterResponse({
    required this.status,
    this.message,
    this.data,
    this.token,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'] ?? '',
      message: json['message'],
      token: json['token'],
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
    );
  }
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
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

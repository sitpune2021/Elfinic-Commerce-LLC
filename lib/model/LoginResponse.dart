// ignore_for_file: file_names

import 'dart:convert';

LoginResponse loginResponseFromRawJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

class LoginResponse {
  final String status;
  final String? message;
  final User? user;
  final String? token;

  LoginResponse({
    required this.status,
    this.message,
    this.user,
    this.token,
  });

  /// ✅ ADDED (this was missing)
  factory LoginResponse.fromRawJson(String str) =>
      LoginResponse.fromJson(json.decode(str));

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? '',
      message: json['message'],
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'user': user?.toJson(),
      'token': token,
    };
  }
}

class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

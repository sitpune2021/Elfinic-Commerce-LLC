// // models/address_model.dart

// models/address_model.dart
class Address {
  final int? id;
  final int userId;
  final String name;
  final String type;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final int isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Address({
    this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      type: json['type'],
      phone: json['phone'],
      addressLine1: json['address_line1'],
      addressLine2: json['address_line2'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code'],
      isDefault: json['is_default'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id, // Add this line - only include id if it's not null
      'user_id': userId,
      'name': name,
      'type': type,
      'phone': phone,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'is_default': isDefault,
    };
  }
}
// class Address {
//   final int? id;
//   final int userId;
//   final String name;
//   final String type;
//   final String phone;
//   final String addressLine1;
//   final String? addressLine2;
//   final String city;
//   final String state;
//   final String country;
//   final String postalCode;
//   final int isDefault;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//
//   Address({
//     this.id,
//     required this.userId,
//     required this.name,
//     required this.type,
//     required this.phone,
//     required this.addressLine1,
//     this.addressLine2,
//     required this.city,
//     required this.state,
//     required this.country,
//     required this.postalCode,
//     required this.isDefault,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   factory Address.fromJson(Map<String, dynamic> json) {
//     return Address(
//       id: json['id'],
//       userId: json['user_id'],
//       name: json['name'],
//       type: json['type'],
//       phone: json['phone'],
//       addressLine1: json['address_line1'],
//       addressLine2: json['address_line2'],
//       city: json['city'],
//       state: json['state'],
//       country: json['country'],
//       postalCode: json['postal_code'],
//       isDefault: json['is_default'],
//       createdAt: json['created_at'] != null
//           ? DateTime.parse(json['created_at'])
//           : null,
//       updatedAt: json['updated_at'] != null
//           ? DateTime.parse(json['updated_at'])
//           : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'user_id': userId,
//       'name': name,
//       'type': type,
//       'phone': phone,
//       'address_line1': addressLine1,
//       'address_line2': addressLine2,
//       'city': city,
//       'state': state,
//       'country': country,
//       'postal_code': postalCode,
//       'is_default': isDefault,
//     };
//   }
// }
import 'dart:convert';

OrderHistoryDetailsModel orderHistoryDetailsModelFromJson(String str) =>
    OrderHistoryDetailsModel.fromJson(json.decode(str));

String orderHistoryDetailsModelToJson(OrderHistoryDetailsModel data) =>
    json.encode(data.toJson());

class OrderHistoryDetailsModel {
  final String? status;
  final String? message;
  final List<Datum> data;

  OrderHistoryDetailsModel({
    this.status,
    this.message,
    required this.data,
  });

  factory OrderHistoryDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryDetailsModel(
      status: json["status"],
      message: json["message"],
      data: (json["data"] as List<dynamic>?)
              ?.map((x) => Datum.fromJson(x))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.map((x) => x.toJson()).toList(),
      };
}

class Datum {
  final String? orderNumber;
  final int? orderId;
  final int? userId;
  final int? variantId;
  final String? vendorId;
  final String? vendorName;
  final String? productName;
  final String? productThumb;
  final String? slug;
  final String? totalAmount;
  final String? couponCode;
  final String? discountAmount;
  final String? coinsUsed;
  final String? deliveredStatus;
  final String? paymentStatus;
  final DateTime? paidAt;
  final int? productId;
  final String? variantName;
  final int? quantity;
  final String? discount;
  final String? finalPrice;
  final Address? address;
  final List<History> history;

  Datum({
    this.orderNumber,
    this.orderId,
    this.userId,
    this.variantId,
    this.vendorId,
    this.vendorName,
    this.productName,
    this.productThumb,
    this.slug,
    this.totalAmount,
    this.couponCode,
    this.discountAmount,
    this.coinsUsed,
    this.deliveredStatus,
    this.paymentStatus,
    this.paidAt,
    this.productId,
    this.variantName,
    this.quantity,
    this.discount,
    this.finalPrice,
    this.address,
    required this.history,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      orderNumber: json["order_number"],
      orderId: json["order_id"],
      userId: json["user_id"],
      variantId: json["variant_id"],
      vendorId: json["vendor_id"]?.toString(),
      vendorName: json["vendor_name"],
      productName: json["product_name"],
      productThumb: json["product_thumb"],
      slug: json["slug"],
      totalAmount: json["total_amount"],
      couponCode: json["coupon_code"],
      discountAmount: json["discount_amount"],
      coinsUsed: json["coins_used"],
      deliveredStatus: json["delivered_status"],
      paymentStatus: json["payment_status"],

      /// ✅ FIXED DATE PARSING
      paidAt: json["paid_at"] != null && json["paid_at"].toString().isNotEmpty
          ? DateTime.tryParse(
              json["paid_at"].toString().replaceFirst(' ', 'T'),
            )
          : null,

      productId: json["product_id"],
      variantName: json["variant_name"],
      quantity: json["quantity"],
      discount: json["discount"],
      finalPrice: json["final_price"],
      address:
          json["address"] != null ? Address.fromJson(json["address"]) : null,
      history: (json["history"] as List<dynamic>?)
              ?.map((x) => History.fromJson(x))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        "order_number": orderNumber,
        "order_id": orderId,
        "user_id": userId,
        "variant_id": variantId,
        "vendor_id": vendorId,
        "vendor_name": vendorName,
        "product_name": productName,
        "product_thumb": productThumb,
        "slug": slug,
        "total_amount": totalAmount,
        "coupon_code": couponCode,
        "discount_amount": discountAmount,
        "coins_used": coinsUsed,
        "delivered_status": deliveredStatus,
        "payment_status": paymentStatus,
        "paid_at": paidAt?.toIso8601String(),
        "product_id": productId,
        "variant_name": variantName,
        "quantity": quantity,
        "discount": discount,
        "final_price": finalPrice,
        "address": address?.toJson(),
        "history": history.map((x) => x.toJson()).toList(),
      };
}

class Address {
  final String? name;
  final String? phone;
  final String? type;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  Address({
    this.name,
    this.phone,
    this.type,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        name: json["name"],
        phone: json["phone"],
        type: json["type"],
        addressLine1: json["address_line1"],
        addressLine2: json["address_line2"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        postalCode: json["postal_code"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "phone": phone,
        "type": type,
        "address_line1": addressLine1,
        "address_line2": addressLine2,
        "city": city,
        "state": state,
        "country": country,
        "postal_code": postalCode,
      };
}

class History {
  final String? historyStatus;
  final String? historyMessage;
  final String? createdAt;

  History({
    this.historyStatus,
    this.historyMessage,
    this.createdAt,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
        historyStatus: json["history_status"],
        historyMessage: json["history_message"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "history_status": historyStatus,
        "history_message": historyMessage,
        "created_at": createdAt,
      };
}

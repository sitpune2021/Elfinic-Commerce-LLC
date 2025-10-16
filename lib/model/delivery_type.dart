class DeliveryType {
  final int id;
  final String type;
  final double charge;
  final double minOrderAmount;
  final String days;

  DeliveryType({
    required this.id,
    required this.type,
    required this.charge,
    required this.minOrderAmount,
    required this.days,
  });

  factory DeliveryType.fromJson(Map<String, dynamic> json) {
    return DeliveryType(
      id: json['id'],
      type: json['type'],
      charge: double.tryParse(json['charge'].toString()) ?? 0.0,
      minOrderAmount: double.tryParse(json['min_order_amount'].toString()) ?? 0.0,
      days: json['days'] ?? '',
    );
  }
}

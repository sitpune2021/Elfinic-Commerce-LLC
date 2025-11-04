class BannerResponse {
  final String status;
  final String message;
  final List<BannerData> data;

  BannerResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => BannerData.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class BannerData {
  final int id;
  final String type;
  final String title;
  final String? description;
  final String status;
  final int order;
  final List<String> images;

  BannerData({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    required this.status,
    required this.order,
    required this.images,
  });

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? '',
      order: json['order'] ?? 0,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'status': status,
      'order': order,
      'images': images,
    };
  }
}

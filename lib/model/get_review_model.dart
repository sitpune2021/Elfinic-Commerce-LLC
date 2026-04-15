import 'dart:convert';

GetReviewModel getReviewModelFromJson(String str) =>
    GetReviewModel.fromJson(json.decode(str));

String getReviewModelToJson(GetReviewModel data) => json.encode(data.toJson());

class GetReviewModel {
  final String status;
  final String message;
  final Data data;

  GetReviewModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetReviewModel.fromJson(Map<String, dynamic> json) {
    return GetReviewModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: Data.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data.toJson(),
      };
}

class Data {
  final RatingSummary ratingSummary;
  final List<Review> reviews;

  Data({
    required this.ratingSummary,
    required this.reviews,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      ratingSummary: RatingSummary.fromJson(json['ratingSummary'] ?? {}),
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => Review.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'ratingSummary': ratingSummary.toJson(),
        'reviews': reviews.map((e) => e.toJson()).toList(),
      };
}

class RatingSummary {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> starCounts;

  RatingSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.starCounts,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    return RatingSummary(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      starCounts: (json['starCounts'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'averageRating': averageRating,
        'totalReviews': totalReviews,
        'starCounts': starCounts,
      };
}

class Review {
  final String reviewId;
  final User user;
  final int rating;
  final String title;
  final String content;
  final Media media;
  final String postAt; // 👈 FIXED

  Review({
    required this.reviewId,
    required this.user,
    required this.rating,
    required this.title,
    required this.content,
    required this.media,
    required this.postAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      rating: json['rating'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      media: Media.fromJson(json['media'] ?? {}),
      postAt: json['post_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'reviewId': reviewId,
        'user': user.toJson(),
        'rating': rating,
        'title': title,
        'content': content,
        'media': media.toJson(),
        'post_at': postAt,
      };
}

class Media {
  final List<String> images;
  final List<String> videos;

  Media({
    required this.images,
    required this.videos,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      videos: (json['videos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'images': images,
        'videos': videos,
      };
}

class User {
  final String id;
  final String name;

  User({
    required this.id,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

import 'dart:convert';

ProductReviewResponse productReviewResponseFromJson(String str) =>
    ProductReviewResponse.fromJson(json.decode(str));

String productReviewResponseToJson(ProductReviewResponse data) =>
    json.encode(data.toJson());

class ProductReviewResponse {
  final String status;
  final String message;
  final ReviewData data;

  ProductReviewResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProductReviewResponse.fromJson(Map<String, dynamic> json) {
    return ProductReviewResponse(
      status: json["status"],
      message: json["message"],
      data: ReviewData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class ReviewData {
  final RatingSummary ratingSummary;
  final List<Review> reviews;

  ReviewData({
    required this.ratingSummary,
    required this.reviews,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      ratingSummary: RatingSummary.fromJson(json["ratingSummary"]),
      reviews:
          (json["reviews"] as List).map((e) => Review.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "ratingSummary": ratingSummary.toJson(),
        "reviews": reviews.map((e) => e.toJson()).toList(),
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
      averageRating: (json["averageRating"] as num).toDouble(),
      totalReviews: json["totalReviews"],
      starCounts: Map<String, int>.from(json["starCounts"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "averageRating": averageRating,
        "totalReviews": totalReviews,
        "starCounts": starCounts,
      };
}

class Review {
  final String reviewId;
  final User user;
  final int rating;
  final String title;
  final String? comment;
  final Media media;
  final String postAt;

  Review({
    required this.reviewId,
    required this.user,
    required this.rating,
    required this.title,
    this.comment,
    required this.media,
    required this.postAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json["reviewId"],
      user: User.fromJson(json["user"]),
      rating: json["rating"],
      title: json["title"],
      comment: json["comment"],
      media: Media.fromJson(json["media"]),
      postAt: json["post_at"],
    );
  }

  Map<String, dynamic> toJson() => {
        "reviewId": reviewId,
        "user": user.toJson(),
        "rating": rating,
        "title": title,
        "comment": comment,
        "media": media.toJson(),
        "post_at": postAt,
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
      images: List<String>.from(json["images"] ?? []),
      videos: List<String>.from(json["videos"] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        "images": images,
        "videos": videos,
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
      id: json["id"],
      name: json["name"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

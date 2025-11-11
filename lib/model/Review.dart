class Review {
  final int id;
  final int productId;
  final int userId;
  // final String userName;
  // final String userEmail;
  final int rating;
  final String review;
  final String createdAt;
  final String userPhoto;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    // required this.userName,
    // required this.userEmail,
    required this.rating,
    required this.review,
    required this.createdAt,
    required this.userPhoto,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    print('🟡 Parsing Review JSON: $json');

    final review = Review(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      // userName: json['user_name'] ?? 'Anonymous',
      // userEmail: json['user_email'] ?? '',
      rating: json['rating'] ?? 0,
      review: json['review'] ?? '',
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      userPhoto: json['user_photo'] ?? '',
    );

    print('🟢 Parsed Review - ${review.rating} stars');
    return review;
  }

  // Helper method to convert to map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      // 'user_name': userName,
      // 'user_email': userEmail,
      'rating': rating,
      'review': review,
      'created_at': createdAt,
      'user_photo': userPhoto,
    };
  }

  @override
  String toString() {
    return 'Review{id: $id,  rating: $rating, product: $productId}';
  }
}
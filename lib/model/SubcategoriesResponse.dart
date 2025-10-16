class SubCategoriesResponse {
  final bool status;
  final List<SubCategoryModel> data;

  SubCategoriesResponse({
    required this.status,
    required this.data,
  });

  factory SubCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return SubCategoriesResponse(
      status: json['status'] == 'success', // convert string to bool
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class SubCategoryModel {
  final int id;
  final int categoryId;
  final String name;
  final String slug;
  final String? image;
  final String? description;
  final String status;

  SubCategoryModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.image,
    this.description,
    required this.status,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'],
      description: json['description'],
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'slug': slug,
      'image': image,
      'description': description,
      'status': status,
    };
  }
}

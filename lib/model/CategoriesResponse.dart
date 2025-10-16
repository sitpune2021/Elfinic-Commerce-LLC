class CategoriesResponse {
  final bool status;
  final List<CategoryModel> data;

  CategoriesResponse({
    required this.status,
    required this.data,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesResponse(
      status: (json['status'] == 'success' || json['status'] == true),
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String image;
  final String? description;
  final String status;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
    this.description,
    required this.status,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] is String) ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'] ?? '',
      description: json['description'],
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'image': image,
      'description': description,
      'status': status,
    };
  }
}



/*
class CategoriesResponse {
  final bool status;
  final List<CategoryModel> data;

  CategoriesResponse({
    required this.status,
    required this.data,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList()
          ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
class CategoryModel {
  final String? id;
  final String name;
  final String slug;
  final String image;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.image,
    this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString(), // ✅ Convert int to String
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'] ?? '',
      description: json['description'],
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.tryParse(json['deleted_at'])
          : null,
    );
  }

  // factory CategoryModel.fromJson(Map<String, dynamic> json) {
  //   return CategoryModel(
  //     id: json['id'] ?? 0,
  //     name: json['name'] ?? '',
  //     slug: json['slug'] ?? '',
  //     image: json['image'] ?? '',
  //     description: json['description'],
  //     status: json['status'] ?? '',
  //     createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
  //     updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
  //     deletedAt: json['deleted_at'] != null
  //         ? DateTime.tryParse(json['deleted_at'])
  //         : null,
  //   );
  // }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'image': image,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
*/

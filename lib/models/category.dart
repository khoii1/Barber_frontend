class Category {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}


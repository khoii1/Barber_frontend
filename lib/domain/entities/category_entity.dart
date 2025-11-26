/// Domain entity for Category
class CategoryEntity {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isActive;

  CategoryEntity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.isActive = true,
  });
}


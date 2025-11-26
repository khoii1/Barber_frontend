import '../../domain/entities/category_entity.dart';
import '../models/category.dart';

class CategoryMapper {
  static CategoryEntity toEntity(Category model) {
    return CategoryEntity(
      id: model.id,
      name: model.name,
      description: model.description,
      imageUrl: model.imageUrl,
      isActive: model.isActive,
    );
  }

  static Category toModel(CategoryEntity entity) {
    return Category(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      imageUrl: entity.imageUrl,
      isActive: entity.isActive,
    );
  }
}


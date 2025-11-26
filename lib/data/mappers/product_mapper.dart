import '../../domain/entities/product_entity.dart';
import '../models/product.dart';

class ProductMapper {
  static ProductEntity toEntity(Product model) {
    return ProductEntity(
      id: model.id,
      name: model.name,
      priceVnd: model.priceVnd,
      stock: model.stock,
      isActive: model.isActive,
      description: model.description,
      imageUrl: model.imageUrl,
      sku: model.sku,
      categoryId: model.categoryId,
    );
  }

  static Product toModel(ProductEntity entity) {
    return Product(
      id: entity.id,
      name: entity.name,
      priceVnd: entity.priceVnd,
      stock: entity.stock,
      isActive: entity.isActive,
      description: entity.description,
      imageUrl: entity.imageUrl,
      sku: entity.sku,
      categoryId: entity.categoryId,
    );
  }
}


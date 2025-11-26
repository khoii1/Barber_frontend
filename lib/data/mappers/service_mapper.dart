import '../../domain/entities/service_entity.dart';
import '../models/service.dart';

class ServiceMapper {
  static ServiceEntity toEntity(Service model) {
    return ServiceEntity(
      id: model.id,
      name: model.name,
      durationMin: model.durationMin,
      priceVnd: model.priceVnd,
      isActive: model.isActive,
      description: model.description,
      imageUrl: model.imageUrl,
      categoryId: model.categoryId,
    );
  }

  static Service toModel(ServiceEntity entity) {
    return Service(
      id: entity.id,
      name: entity.name,
      durationMin: entity.durationMin,
      priceVnd: entity.priceVnd,
      isActive: entity.isActive,
      description: entity.description,
      imageUrl: entity.imageUrl,
      categoryId: entity.categoryId,
    );
  }
}


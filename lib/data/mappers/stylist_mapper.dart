import '../../domain/entities/stylist_entity.dart';
import '../models/stylist.dart';

class StylistMapper {
  static StylistEntity toEntity(Stylist model) {
    return StylistEntity(
      id: model.id,
      userId: model.userId,
      bio: model.bio,
      ratingAvg: model.ratingAvg,
      ratingCount: model.ratingCount,
      isActive: model.isActive,
      skills: model.skills,
      avatarUrl: model.avatarUrl,
    );
  }

  static Stylist toModel(StylistEntity entity) {
    return Stylist(
      id: entity.id,
      userId: entity.userId,
      bio: entity.bio,
      ratingAvg: entity.ratingAvg,
      ratingCount: entity.ratingCount,
      isActive: entity.isActive,
      skills: entity.skills,
      avatarUrl: entity.avatarUrl,
    );
  }
}


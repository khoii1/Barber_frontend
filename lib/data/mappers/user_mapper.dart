import '../../domain/entities/user_entity.dart';
import '../models/user.dart';

class UserMapper {
  static UserEntity toEntity(User model) {
    return UserEntity(
      id: model.id,
      fullName: model.fullName,
      email: model.email,
      phone: model.phone,
      role: model.role,
      status: model.status,
      tz: model.tz,
    );
  }

  static User toModel(UserEntity entity) {
    return User(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      phone: entity.phone,
      role: entity.role,
      status: entity.status,
      tz: entity.tz,
    );
  }
}


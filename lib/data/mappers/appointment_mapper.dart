import '../../domain/entities/appointment_entity.dart';
import '../models/appointment.dart';

class AppointmentMapper {
  static AppointmentEntity toEntity(Appointment model) {
    return AppointmentEntity(
      id: model.id,
      customerId: model.customerId,
      stylistId: model.stylistId,
      serviceId: model.serviceId,
      startAt: model.startAt,
      endAt: model.endAt,
      status: model.status,
      note: model.note,
      priceVndSnapshot: model.priceVndSnapshot,
      serviceNameSnapshot: model.serviceNameSnapshot,
      stylistNameSnapshot: model.stylistNameSnapshot,
      source: model.source,
      createdBy: model.createdBy,
      canceledAt: model.canceledAt,
      cancelReason: model.cancelReason,
      noShow: model.noShow,
    );
  }

  static Appointment toModel(AppointmentEntity entity) {
    return Appointment(
      id: entity.id,
      customerId: entity.customerId,
      stylistId: entity.stylistId,
      serviceId: entity.serviceId,
      startAt: entity.startAt,
      endAt: entity.endAt,
      status: entity.status,
      note: entity.note,
      priceVndSnapshot: entity.priceVndSnapshot,
      serviceNameSnapshot: entity.serviceNameSnapshot,
      stylistNameSnapshot: entity.stylistNameSnapshot,
      source: entity.source,
      createdBy: entity.createdBy,
      canceledAt: entity.canceledAt,
      cancelReason: entity.cancelReason,
      noShow: entity.noShow,
    );
  }
}


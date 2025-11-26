import '../../domain/entities/payment_entity.dart';
import '../models/payment.dart';

class PaymentMapper {
  static PaymentEntity toEntity(Payment model) {
    return PaymentEntity(
      id: model.id,
      customerId: model.customerId,
      productId: model.productId,
      quantity: model.quantity,
      totalAmount: model.totalAmount,
      status: model.status,
      paymentMethod: model.paymentMethod,
      productNameSnapshot: model.productNameSnapshot,
      productPriceSnapshot: model.productPriceSnapshot,
      note: model.note,
      createdAt: model.createdAt,
      completedAt: model.completedAt,
    );
  }

  static Payment toModel(PaymentEntity entity) {
    return Payment(
      id: entity.id,
      customerId: entity.customerId,
      productId: entity.productId,
      quantity: entity.quantity,
      totalAmount: entity.totalAmount,
      status: entity.status,
      paymentMethod: entity.paymentMethod,
      productNameSnapshot: entity.productNameSnapshot,
      productPriceSnapshot: entity.productPriceSnapshot,
      note: entity.note,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
    );
  }
}


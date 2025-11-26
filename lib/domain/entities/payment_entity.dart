/// Domain entity for Payment
class PaymentEntity {
  final String id;
  final String customerId;
  final String productId;
  final int quantity;
  final int totalAmount;
  final String status; // PENDING, COMPLETED, CANCELLED
  final String paymentMethod; // CASH, BANK_TRANSFER, CREDIT_CARD
  final String productNameSnapshot;
  final int productPriceSnapshot;
  final String? note;
  final DateTime createdAt;
  final DateTime? completedAt;

  PaymentEntity({
    required this.id,
    required this.customerId,
    required this.productId,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.productNameSnapshot,
    required this.productPriceSnapshot,
    this.note,
    required this.createdAt,
    this.completedAt,
  });

  bool get isPending => status == 'PENDING';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
  
  String get formattedPrice {
    final priceString = totalAmount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < priceString.length; i++) {
      if (i > 0 && (priceString.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceString[i]);
    }
    return '${buffer.toString()} ₫';
  }
}


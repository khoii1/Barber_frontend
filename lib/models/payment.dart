class Payment {
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
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? product;
  final Map<String, dynamic>? completedBy;

  Payment({
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
    this.customer,
    this.product,
    this.completedBy,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'] ?? json['id'],
      customerId: json['customerId'] is String
          ? json['customerId']
          : json['customerId']?['_id'] ?? json['customerId']?['id'],
      productId: json['productId'] is String
          ? json['productId']
          : json['productId']?['_id'] ?? json['productId']?['id'],
      quantity: json['quantity'] ?? 1,
      totalAmount: json['totalAmount'] ?? 0,
      status: json['status'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      productNameSnapshot: json['productNameSnapshot'] ?? '',
      productPriceSnapshot: json['productPriceSnapshot'] ?? 0,
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      customer: json['customerId'] is Map ? json['customerId'] : null,
      product: json['productId'] is Map ? json['productId'] : null,
      completedBy: json['completedBy'] is Map ? json['completedBy'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'productId': productId,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'productNameSnapshot': productNameSnapshot,
      'productPriceSnapshot': productPriceSnapshot,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

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

  String get statusText {
    switch (status) {
      case 'PENDING':
        return 'Chờ thanh toán';
      case 'COMPLETED':
        return 'Đã thanh toán';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String get paymentMethodText {
    switch (paymentMethod) {
      case 'CASH':
        return 'Tiền mặt';
      case 'BANK_TRANSFER':
        return 'Chuyển khoản';
      case 'CREDIT_CARD':
        return 'Thẻ tín dụng';
      default:
        return paymentMethod;
    }
  }
}


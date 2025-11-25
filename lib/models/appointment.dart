class Appointment {
  final String id;
  final String customerId;
  final String stylistId;
  final String serviceId;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final String? note;
  final int priceVndSnapshot;
  final String serviceNameSnapshot;
  final String stylistNameSnapshot;
  final String source;
  final String? createdBy;
  final DateTime? canceledAt;
  final String? cancelReason;
  final bool noShow;
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? stylist;
  final Map<String, dynamic>? service;

  Appointment({
    required this.id,
    required this.customerId,
    required this.stylistId,
    required this.serviceId,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.note,
    required this.priceVndSnapshot,
    required this.serviceNameSnapshot,
    required this.stylistNameSnapshot,
    this.source = 'app',
    this.createdBy,
    this.canceledAt,
    this.cancelReason,
    this.noShow = false,
    this.customer,
    this.stylist,
    this.service,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] ?? json['id'],
      customerId: json['customerId'] is String 
          ? json['customerId'] 
          : json['customerId']?['_id'] ?? json['customerId']?['id'],
      stylistId: json['stylistId'] is String 
          ? json['stylistId'] 
          : json['stylistId']?['_id'] ?? json['stylistId']?['id'],
      serviceId: json['serviceId'] is String 
          ? json['serviceId'] 
          : json['serviceId']?['_id'] ?? json['serviceId']?['id'],
      startAt: DateTime.parse(json['startAt']),
      endAt: DateTime.parse(json['endAt']),
      status: json['status'] ?? 'CONFIRMED',
      note: json['note'],
      priceVndSnapshot: json['priceVndSnapshot'] ?? 0,
      serviceNameSnapshot: json['serviceNameSnapshot'] ?? '',
      stylistNameSnapshot: json['stylistNameSnapshot'] ?? '',
      source: json['source'] ?? 'app',
      createdBy: json['createdBy'],
      canceledAt: json['canceledAt'] != null 
          ? DateTime.parse(json['canceledAt']) 
          : null,
      cancelReason: json['cancelReason'],
      noShow: json['noShow'] ?? false,
      customer: json['customerId'] is Map ? json['customerId'] : null,
      stylist: json['stylistId'] is Map ? json['stylistId'] : null,
      service: json['serviceId'] is Map ? json['serviceId'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'stylistId': stylistId,
      'serviceId': serviceId,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'status': status,
      'note': note,
      'priceVndSnapshot': priceVndSnapshot,
      'serviceNameSnapshot': serviceNameSnapshot,
      'stylistNameSnapshot': stylistNameSnapshot,
      'source': source,
      'createdBy': createdBy,
    };
  }

  String get formattedPrice => '${(priceVndSnapshot / 1000).toStringAsFixed(0)}k VNĐ';
  
  String get statusText {
    switch (status) {
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}


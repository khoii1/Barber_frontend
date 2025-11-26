/// Domain entity for Appointment
class AppointmentEntity {
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

  AppointmentEntity({
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
  });

  bool get isPending => status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
  
  String get formattedPrice => '${(priceVndSnapshot / 1000).toStringAsFixed(0)}k VNĐ';
}


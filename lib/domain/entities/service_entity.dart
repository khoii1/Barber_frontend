/// Domain entity for Service
class ServiceEntity {
  final String id;
  final String name;
  final int durationMin;
  final int priceVnd;
  final bool isActive;
  final String? description;
  final String? imageUrl;
  final String? categoryId;

  ServiceEntity({
    required this.id,
    required this.name,
    required this.durationMin,
    required this.priceVnd,
    this.isActive = true,
    this.description,
    this.imageUrl,
    this.categoryId,
  });

  String get formattedPrice {
    final priceString = priceVnd.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < priceString.length; i++) {
      if (i > 0 && (priceString.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceString[i]);
    }
    return '${buffer.toString()} ₫';
  }
  
  String get formattedDuration => '$durationMin phút';
}


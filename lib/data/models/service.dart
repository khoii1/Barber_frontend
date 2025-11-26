class Service {
  final String id;
  final String name;
  final int durationMin;
  final int priceVnd;
  final bool isActive;
  final String? description;
  final String? imageUrl;
  final String? categoryId;
  final Map<String, dynamic>? category;

  Service({
    required this.id,
    required this.name,
    required this.durationMin,
    required this.priceVnd,
    this.isActive = true,
    this.description,
    this.imageUrl,
    this.categoryId,
    this.category,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      durationMin: json['durationMin'] ?? 0,
      priceVnd: json['priceVnd'] ?? 0,
      isActive: json['isActive'] ?? true,
      description: json['description'],
      imageUrl: json['imageUrl'],
      categoryId: json['category'] is String 
          ? json['category'] 
          : json['category']?['_id'] ?? json['category']?['id'],
      category: json['category'] is Map ? json['category'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'durationMin': durationMin,
      'priceVnd': priceVnd,
      'isActive': isActive,
      'description': description,
      'imageUrl': imageUrl,
      'category': categoryId,
    };
  }

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


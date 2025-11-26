/// Domain entity for Product
class ProductEntity {
  final String id;
  final String name;
  final int priceVnd;
  final int stock;
  final bool isActive;
  final String? description;
  final String? imageUrl;
  final String? sku;
  final String? categoryId;

  ProductEntity({
    required this.id,
    required this.name,
    required this.priceVnd,
    required this.stock,
    this.isActive = true,
    this.description,
    this.imageUrl,
    this.sku,
    this.categoryId,
  });

  bool get isInStock => stock > 0;
  
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
}


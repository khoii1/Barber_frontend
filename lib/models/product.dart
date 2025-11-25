class Product {
  final String id;
  final String name;
  final int priceVnd;
  final int stock;
  final bool isActive;
  final String? description;
  final String? imageUrl;
  final String? sku;
  final String? categoryId;
  final Map<String, dynamic>? category;

  Product({
    required this.id,
    required this.name,
    required this.priceVnd,
    required this.stock,
    this.isActive = true,
    this.description,
    this.imageUrl,
    this.sku,
    this.categoryId,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      priceVnd: json['priceVnd'] ?? 0,
      stock: json['stock'] ?? 0,
      isActive: json['isActive'] ?? true,
      description: json['description'],
      imageUrl: json['imageUrl'],
      sku: json['sku'],
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
      'priceVnd': priceVnd,
      'stock': stock,
      'isActive': isActive,
      'description': description,
      'imageUrl': imageUrl,
      'sku': sku,
      'category': categoryId,
    };
  }

  String get formattedPrice {
    // Format với dấu chấm phân cách hàng nghìn
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

  bool get isInStock => stock > 0;
  String get stockStatus => stock > 0 ? 'Còn $stock sản phẩm' : 'Hết hàng';
}

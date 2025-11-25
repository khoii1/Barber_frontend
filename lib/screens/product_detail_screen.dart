import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

// Color scheme matching the design
const Color _darkGreen = Color(0xFF2D5016);
const Color _lightBeige = Color(0xFFF5E6D3);

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  Product? _currentProduct;

  String _formatPrice(int price) {
    // Format với dấu chấm phân cách hàng nghìn
    final priceString = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < priceString.length; i++) {
      if (i > 0 && (priceString.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceString[i]);
    }
    return '${buffer.toString()} ₫';
  }

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    // Load fresh product data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductDetails();
    });
  }

  Future<void> _loadProductDetails() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final updatedProduct = productProvider.getProductById(widget.product.id);
    if (updatedProduct != null) {
      setState(() {
        _currentProduct = updatedProduct;
      });
    } else {
      // If not in cache, reload products
      await productProvider.loadProducts();
      final freshProduct = productProvider.getProductById(widget.product.id);
      if (freshProduct != null) {
        setState(() {
          _currentProduct = freshProduct;
        });
      }
    }
  }

  Future<void> _purchaseProduct() async {
    if (_currentProduct == null) return;

    if (!_currentProduct!.isInStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sản phẩm đã hết hàng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_quantity > _currentProduct!.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Số lượng vượt quá tồn kho. Chỉ còn ${_currentProduct!.stock} sản phẩm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_darkGreen),
        ),
      ),
    );

    final result = await productProvider.purchaseProduct(
      _currentProduct!.id,
      _quantity,
    );

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (context.mounted) {
      if (result['success'] == true) {
        // Reload product details
        await _loadProductDetails();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Đã tạo đơn hàng. Trạng thái: Chờ thanh toán'),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Mua sản phẩm thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _currentProduct ?? widget.product;
    final maxQuantity = product.stock;

    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.white,
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: _darkGreen.withOpacity(0.1),
                          child: const Icon(
                            Icons.shopping_bag,
                            size: 80,
                            color: _darkGreen,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: _darkGreen.withOpacity(0.1),
                      child: const Icon(
                        Icons.shopping_bag,
                        size: 80,
                        color: _darkGreen,
                      ),
                    ),
            ),

            // Product Info Card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _darkGreen,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // SKU
                    if (product.sku != null) ...[
                      Text(
                        'Mã SKU: ${product.sku}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Price
                    Text(
                      product.formattedPrice,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _darkGreen,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Stock Status
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          size: 20,
                          color: product.isInStock ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          product.stockStatus,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: product.isInStock ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Description
            if (product.description != null && product.description!.isNotEmpty) ...[
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mô tả sản phẩm',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _darkGreen,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Quantity Selector
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Số lượng',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _darkGreen,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                              color: _darkGreen,
                            ),
                            Container(
                              width: 60,
                              alignment: Alignment.center,
                              child: Text(
                                '$_quantity',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: _quantity < maxQuantity
                                  ? () => setState(() => _quantity++)
                                  : null,
                              color: _darkGreen,
                            ),
                          ],
                        ),
                        Text(
                          'Tổng: ${_formatPrice(product.priceVnd * _quantity)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _darkGreen,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Purchase Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: product.isInStock && _quantity <= maxQuantity
                    ? _purchaseProduct
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text(
                  product.isInStock ? 'MUA NGAY' : 'HẾT HÀNG',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}


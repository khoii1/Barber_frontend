import 'package:flutter/foundation.dart';
import '../../data/models/product.dart';
import '../../data/datasources/remote/product_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  // Chỉ lọc theo isActive, không lọc theo stock
  // Sản phẩm hết hàng (stock = 0) vẫn hiển thị nếu isActive = true
  List<Product> get availableProducts => _products.where((p) => p.isActive).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts({String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await ProductService.getActiveProducts(category: category);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> purchaseProduct(String productId, int quantity) async {
    try {
      final result = await ProductService.purchaseProduct(productId, quantity);
      if (result['success'] == true) {
        // Reload products to get updated stock
        await loadProducts();
        return result;
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}


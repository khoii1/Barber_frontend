import 'dart:convert';
import '../models/product.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class ProductService {
  static Future<List<Product>> getActiveProducts({String? category}) async {
    try {
      String endpoint = ApiConfig.products;
      Map<String, String> params = {'isActive': 'true'};
      if (category != null) {
        params['category'] = category;
      }
      
      final queryString = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      endpoint += queryString.isNotEmpty ? '?$queryString' : '';
      
      final response = await ApiService.get(endpoint, includeAuth: false);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  static Future<Product?> getProductById(String id) async {
    try {
      final response = await ApiService.get('${ApiConfig.products}/$id', includeAuth: false);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> purchaseProduct(String productId, int quantity) async {
    try {
      final response = await ApiService.post(
        '${ApiConfig.products}/$productId/purchase',
        {'quantity': quantity},
      );
      final result = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'product': Product.fromJson(result)};
      }
      return {'success': false, 'message': result['message'] ?? 'Mua sản phẩm thất bại'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}


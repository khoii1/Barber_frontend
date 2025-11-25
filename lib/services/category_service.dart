import 'dart:convert';
import '../models/category.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class CategoryService {
  static Future<List<Category>> getCategories() async {
    try {
      final response = await ApiService.get(ApiConfig.categories, includeAuth: false);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post(ApiConfig.categories, data);
      final result = json.decode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'category': Category.fromJson(result)};
      }
      return {'success': false, 'message': result['message'] ?? 'Tạo danh mục thất bại'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      final response = await ApiService.patch('${ApiConfig.categories}/$id', data);
      final result = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'category': Category.fromJson(result)};
      }
      return {'success': false, 'message': result['message'] ?? 'Cập nhật danh mục thất bại'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteCategory(String id) async {
    try {
      final response = await ApiService.delete('${ApiConfig.categories}/$id');
      if (response.statusCode == 200) {
        return {'success': true};
      }
      final result = json.decode(response.body);
      return {'success': false, 'message': result['message'] ?? 'Xóa danh mục thất bại'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}


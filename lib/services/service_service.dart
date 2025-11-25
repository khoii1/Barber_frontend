import 'dart:convert';
import '../models/service.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class ServiceService {
  static Future<List<Service>> getActiveServices({String? category}) async {
    try {
      String endpoint = ApiConfig.services;
      if (category != null) {
        endpoint += '?category=$category';
      }
      
      final response = await ApiService.get(endpoint, includeAuth: false);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Service.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching services: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createService(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post(ApiConfig.services, data);
      final result = json.decode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'service': Service.fromJson(result)};
      }
      return {'success': false, 'message': result['message'] ?? 'Tạo dịch vụ thất bại'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateService(String id, Map<String, dynamic> data) async {
    try {
      final response = await ApiService.patch('${ApiConfig.services}/$id', data);
      final result = json.decode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'service': Service.fromJson(result)};
      }
      return {'success': false, 'message': result['message'] ?? 'Cập nhật dịch vụ thất bại'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteService(String id) async {
    try {
      final response = await ApiService.delete('${ApiConfig.services}/$id');
      if (response.statusCode == 200) {
        return {'success': true};
      }
      final result = json.decode(response.body);
      return {'success': false, 'message': result['message'] ?? 'Xóa dịch vụ thất bại'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}

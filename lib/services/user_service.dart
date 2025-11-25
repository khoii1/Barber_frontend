import 'dart:convert';
import '../models/user.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class UserService {
  // Get all users (admin only)
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await ApiService.get(
        ApiConfig.users,
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // Get users by role (admin only)
  static Future<List<User>> getUsersByRole(String role) async {
    try {
      final allUsers = await getAllUsers();
      return allUsers.where((user) => user.role == role).toList();
    } catch (e) {
      print('Error fetching users by role: $e');
      return [];
    }
  }

  // Create user (admin only - via register endpoint)
  static Future<Map<String, dynamic>> createUser({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await ApiService.post(
        '${ApiConfig.auth}/register',
        {
          'fullName': fullName,
          'email': email,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          'password': password,
          'role': role,
        },
        includeAuth: true,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'userId': data['id'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Tạo user thất bại',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }
}


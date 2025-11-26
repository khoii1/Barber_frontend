import 'dart:convert';
import '../../models/stylist.dart';
import 'api_service.dart';
import '../../../shared/config/api_config.dart';

class StylistService {
  // Get all active stylists (public)
  static Future<List<Stylist>> getActiveStylists() async {
    try {
      final response = await ApiService.get(
        ApiConfig.stylists,
        includeAuth: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Stylist.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching stylists: $e');
      return [];
    }
  }

  // Get all stylists (admin only - includes inactive)
  static Future<List<Stylist>> getAllStylists() async {
    try {
      final response = await ApiService.get(
        ApiConfig.stylists,
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Stylist.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching all stylists: $e');
      return [];
    }
  }

  static Future<Stylist?> getStylistById(String stylistId) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.stylists}/$stylistId',
        includeAuth: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Stylist.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching stylist: $e');
      return null;
    }
  }

  // Create stylist (admin only)
  static Future<Map<String, dynamic>> createStylist({
    required String userId,
    String? bio,
    List<String>? skills,
    String? avatarUrl,
  }) async {
    try {
      final response = await ApiService.post(ApiConfig.stylists, {
        'userId': userId,
        if (bio != null) 'bio': bio,
        if (skills != null) 'skills': skills,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      }, includeAuth: true);

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'stylist': Stylist.fromJson(data)};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Tạo thợ cắt tóc thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Get my stylist profile (for current logged in stylist)
  static Future<Stylist?> getMyProfile() async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.stylists}/me',
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Stylist.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching my stylist profile: $e');
      return null;
    }
  }

  // Update stylist (admin only)
  static Future<Map<String, dynamic>> updateStylist(
    String stylistId, {
    String? bio,
    List<String>? skills,
    String? avatarUrl,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (bio != null) body['bio'] = bio;
      if (skills != null) body['skills'] = skills;
      if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
      if (isActive != null) body['isActive'] = isActive;

      final response = await ApiService.patch(
        '${ApiConfig.stylists}/$stylistId',
        body,
        includeAuth: true,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'stylist': Stylist.fromJson(data)};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Cập nhật thợ cắt tóc thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }
}

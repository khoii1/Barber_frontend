import 'dart:convert';
import 'api_service.dart';
import '../../../shared/config/api_config.dart';

class RatingService {
  // Tạo đánh giá cho stylist
  static Future<Map<String, dynamic>> createRating({
    required String appointmentId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await ApiService.post(ApiConfig.ratings, {
        'appointmentId': appointmentId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      }, includeAuth: true);

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'rating': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đánh giá thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Lấy tất cả đánh giá của một stylist
  static Future<List<dynamic>> getRatingsByStylist(String stylistId) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.ratings}/stylist/$stylistId',
        includeAuth: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      }
      return [];
    } catch (e) {
      print('Error fetching ratings: $e');
      return [];
    }
  }

  // Kiểm tra user có thể đánh giá stylist không
  static Future<Map<String, dynamic>> checkEligibility(String stylistId) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.ratings}/check-eligibility/$stylistId',
        includeAuth: true,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return {
        'canRate': false,
        'message': 'Không thể kiểm tra quyền đánh giá',
        'availableAppointments': [],
      };
    } catch (e) {
      print('Error checking eligibility: $e');
      return {
        'canRate': false,
        'message': 'Lỗi kết nối: ${e.toString()}',
        'availableAppointments': [],
      };
    }
  }
}

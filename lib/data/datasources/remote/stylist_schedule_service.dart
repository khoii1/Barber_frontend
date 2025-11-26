import 'dart:convert';
import 'api_service.dart';
import '../../../shared/config/api_config.dart';

class StylistScheduleService {
  // Get current stylist's schedule
  static Future<List<Map<String, dynamic>>> getMySchedule({
    String? startDate,
    String? endDate,
  }) async {
    try {
      String url = '${ApiConfig.stylistSchedules}/my-schedule';
      if (startDate != null || endDate != null) {
        final params = <String>[];
        if (startDate != null) params.add('startDate=$startDate');
        if (endDate != null) params.add('endDate=$endDate');
        url += '?${params.join('&')}';
      }

      final response = await ApiService.get(url, includeAuth: true);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => json as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching my schedule: $e');
      return [];
    }
  }

  // Create or update schedule
  static Future<Map<String, dynamic>> createOrUpdateSchedule({
    required List<String> dates,
    String startTime = '09:00',
    String endTime = '21:00',
  }) async {
    try {
      final response = await ApiService.post(
        ApiConfig.stylistSchedules,
        {
          'dates': dates,
          'startTime': startTime,
          'endTime': endTime,
        },
        includeAuth: true,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'schedules': data['schedules'],
          'created': data['created'],
          'errors': data['errors'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Tạo lịch làm việc thất bại',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }

  // Delete a schedule
  static Future<Map<String, dynamic>> deleteSchedule(String scheduleId) async {
    try {
      final response = await ApiService.delete(
        '${ApiConfig.stylistSchedules}/$scheduleId',
        includeAuth: true,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Xóa lịch làm việc thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Xóa lịch làm việc thất bại',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }

  // Get schedules by date (for checking availability)
  static Future<List<Map<String, dynamic>>> getSchedulesByDate(String date) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.stylistSchedules}/date/$date',
        includeAuth: false,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => json as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching schedules by date: $e');
      return [];
    }
  }
}


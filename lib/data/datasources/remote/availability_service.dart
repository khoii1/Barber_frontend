import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/config/api_config.dart';

class AvailabilityService {
  /// Lấy danh sách các time slot available cho một stylist, service và ngày cụ thể
  /// 
  /// [stylistId] - ID của stylist
  /// [serviceId] - ID của service
  /// [date] - Ngày cần kiểm tra (format: YYYY-MM-DD)
  /// 
  /// Returns: List<String> các time slot dạng "HH:mm" (ví dụ: ["09:00", "10:00", ...])
  static Future<List<String>> getAvailableSlots({
    required String stylistId,
    required String serviceId,
    required DateTime date,
  }) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.availability}?stylistId=$stylistId&serviceId=$serviceId&date=$dateStr');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((slot) => slot.toString()).toList();
      } else {
        print('Error fetching available slots: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching available slots: $e');
      return [];
    }
  }
}


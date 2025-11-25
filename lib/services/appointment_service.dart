import 'dart:convert';
import '../models/appointment.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class AppointmentService {
  static Future<List<Appointment>> getMyAppointments() async {
    try {
      final response = await ApiService.get('${ApiConfig.appointments}/me');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createAppointment({
    required String serviceId,
    String? stylistId,
    required DateTime startAt,
    String? note,
  }) async {
    try {
      final response = await ApiService.post(ApiConfig.appointments, {
        'serviceId': serviceId,
        if (stylistId != null) 'stylistId': stylistId,
        'startAt': startAt.toIso8601String(),
        if (note != null && note.isNotEmpty) 'note': note,
      });

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'appointment': Appointment.fromJson(data)};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Tạo lịch hẹn thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> cancelAppointment(
    String appointmentId, {
    String? reason,
  }) async {
    try {
      final response = await ApiService.patch(
        '${ApiConfig.appointments}/$appointmentId/cancel',
        {if (reason != null) 'cancelReason': reason},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'appointment': Appointment.fromJson(data)};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Hủy lịch hẹn thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> updateStatus(
    String appointmentId,
    String status, {
    String? reason,
  }) async {
    try {
      final response = await ApiService.patch(
        '${ApiConfig.appointments}/$appointmentId/status',
        {
          'status': status,
          if (reason != null) 'reason': reason,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'appointment': Appointment.fromJson(data)};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Cập nhật trạng thái thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }
}

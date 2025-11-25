import 'dart:convert';
import '../models/payment.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class PaymentService {
  // Lấy tất cả payments của user hiện tại
  static Future<List<Payment>> getMyPayments() async {
    try {
      final response = await ApiService.get('${ApiConfig.payments}/me');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Payment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching payments: $e');
      return [];
    }
  }

  // Lấy chi tiết payment
  static Future<Payment?> getPaymentById(String paymentId) async {
    try {
      final response = await ApiService.get('${ApiConfig.payments}/$paymentId');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Payment.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching payment: $e');
      return null;
    }
  }
}


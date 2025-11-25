import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';

class PaymentProvider with ChangeNotifier {
  List<Payment> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Payment> get payments => _payments;
  List<Payment> get pendingPayments => _payments.where((p) => p.status == 'PENDING').toList();
  List<Payment> get completedPayments => _payments.where((p) => p.status == 'COMPLETED').toList();
  List<Payment> get cancelledPayments => _payments.where((p) => p.status == 'CANCELLED').toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMyPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _payments = await PaymentService.getMyPayments();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _payments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Payment? getPaymentById(String id) {
    try {
      return _payments.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}


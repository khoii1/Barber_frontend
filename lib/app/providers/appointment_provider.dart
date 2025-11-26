import 'package:flutter/foundation.dart';
import '../../data/models/appointment.dart';
import '../../data/datasources/remote/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Appointment> get upcomingAppointments {
    final now = DateTime.now();
    return _appointments
        .where((a) => 
            a.status != 'CANCELLED' && 
            a.status != 'COMPLETED' && 
            a.startAt.isAfter(now))
        .toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
  }

  List<Appointment> get pastAppointments {
    final now = DateTime.now();
    return _appointments
        .where((a) => 
            a.status == 'COMPLETED' || 
            a.status == 'CANCELLED' || 
            a.startAt.isBefore(now))
        .toList()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));
  }

  Future<void> loadMyAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _appointments = await AppointmentService.getMyAppointments();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _appointments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAppointment({
    required String serviceId,
    String? stylistId,
    required DateTime startAt,
    String? note,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AppointmentService.createAppointment(
        serviceId: serviceId,
        stylistId: stylistId,
        startAt: startAt,
        note: note,
      );

      _isLoading = false;
      if (result['success'] == true) {
        await loadMyAppointments(); // Reload appointments
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String?;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelAppointment(String appointmentId, {String? reason}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AppointmentService.cancelAppointment(
        appointmentId,
        reason: reason,
      );

      _isLoading = false;
      if (result['success'] == true) {
        await loadMyAppointments(); // Reload appointments
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String?;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}


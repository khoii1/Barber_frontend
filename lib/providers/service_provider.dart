import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../services/service_service.dart';

class ServiceProvider with ChangeNotifier {
  List<Service> _services = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadServices({String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _services = await ServiceService.getActiveServices(category: category);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _services = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Service? getServiceById(String id) {
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}


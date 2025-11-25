import 'package:flutter/foundation.dart';
import '../models/stylist.dart';
import '../services/stylist_service.dart';

class StylistProvider with ChangeNotifier {
  List<Stylist> _stylists = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Stylist> get stylists => _stylists;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Set stylists directly (for admin screen)
  void setStylists(List<Stylist> stylists) {
    _stylists = stylists;
    notifyListeners();
  }

  Future<void> loadStylists() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stylists = await StylistService.getActiveStylists();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _stylists = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stylist? getStylistById(String id) {
    try {
      return _stylists.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}

import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> checkAuth() async {
    // Tránh gọi checkAuth nhiều lần cùng lúc
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await AuthService.getCurrentUser();
      _user = user;
      _errorMessage = null;
    } catch (e) {
      // Khi có lỗi (như 401), đảm bảo clear user và error
      _user = null;
      _errorMessage = null; // Không hiển thị lỗi trong checkAuth
      print('checkAuth error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String emailOrPhone, String password) async {
    // Đảm bảo reset state trước khi bắt đầu
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.login(emailOrPhone, password);
      
      // Đảm bảo luôn set isLoading = false trước khi return
      _isLoading = false;
      
      if (result['success'] == true) {
        // Lưu user từ login response trước
        if (result['user'] != null) {
          _user = result['user'] as User;
        }
        
        // Thử refresh user data từ API (không blocking)
        // Nếu fail thì vẫn dùng user từ login response
        try {
          final refreshedUser = await AuthService.getCurrentUser(forceRefresh: true);
          if (refreshedUser != null) {
            _user = refreshedUser;
            print('AuthProvider login - User role (from API refresh): ${_user?.role}');
          }
        } catch (e) {
          // Nếu refresh fail, vẫn dùng user từ login response (đã set ở trên)
          print('AuthProvider login - Error refreshing user (non-critical): $e');
        }
        
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        // Login thất bại
        _errorMessage = result['message'] as String? ?? 'Đăng nhập thất bại. Vui lòng thử lại.';
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      // Xử lý mọi exception
      print('AuthProvider login error: $e');
      print('Stack trace: $stackTrace');
      
      _isLoading = false;
      _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    String role = 'User',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      
      _isLoading = false;
      if (result['success'] == true) {
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

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}


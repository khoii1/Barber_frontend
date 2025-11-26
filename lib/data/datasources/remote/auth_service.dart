import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import 'api_service.dart';
import '../../../shared/config/api_config.dart';
import 'notification_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
    String emailOrPhone,
    String password,
  ) async {
    try {
      final response = await ApiService.post(ApiConfig.auth + '/login', {
        'emailOrPhone': emailOrPhone,
        'password': password,
      }, includeAuth: false);

      // Xử lý lỗi 401 trước khi parse JSON
      if (response.statusCode == 401) {
        // Thử parse JSON để lấy message từ server
        String errorMessage =
            'Tên đăng nhập hoặc mật khẩu không đúng. Vui lòng kiểm tra lại.';
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            if (errorData is Map && errorData.containsKey('message')) {
              String serverMessage = errorData['message'] as String;
              // Dịch các thông báo lỗi phổ biến sang tiếng Việt
              if (serverMessage.toLowerCase().contains('invalid credentials') ||
                  serverMessage.toLowerCase().contains('invalid') ||
                  serverMessage.toLowerCase().contains('wrong') ||
                  serverMessage.toLowerCase().contains('incorrect')) {
                errorMessage =
                    'Tên đăng nhập hoặc mật khẩu không đúng. Vui lòng kiểm tra lại.';
              } else if (serverMessage.toLowerCase().contains('not found') ||
                  serverMessage.toLowerCase().contains('user not found')) {
                errorMessage =
                    'Tài khoản không tồn tại. Vui lòng kiểm tra lại.';
              } else {
                // Giữ nguyên message nếu đã là tiếng Việt hoặc không phải các trường hợp trên
                errorMessage = serverMessage;
              }
            }
          }
        } catch (e) {
          // Nếu không parse được JSON, dùng message mặc định
          print('Error parsing 401 response: $e');
        }
        return {'success': false, 'message': errorMessage};
      }

      // Parse JSON một cách an toàn
      Map<String, dynamic> data;
      try {
        data = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return {
          'success': false,
          'message': 'Lỗi xử lý dữ liệu từ server. Vui lòng thử lại.',
        };
      }

      if (response.statusCode == 200) {
        // Lưu token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString(
          'user_id',
          data['user']['_id'] ?? data['user']['id'],
        );
        // Lưu đầy đủ user data
        await prefs.setString('user_data', json.encode(data['user']));

        // Parse user object
        final user = User.fromJson(data['user']);

        // Debug: In ra role để kiểm tra
        print('Login - User role: ${user.role}');

        // Đăng ký FCM token để nhận push notification
        try {
          await NotificationService.registerFCMToken();
        } catch (e) {
          print('⚠️ Lỗi đăng ký FCM token: $e');
          // Không throw error, vì đăng ký token không ảnh hưởng đến login
        }

        return {'success': true, 'token': data['token'], 'user': user};
      } else {
        // Xử lý các lỗi khác
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng nhập thất bại. Vui lòng thử lại.',
        };
      }
    } catch (e) {
      // Xử lý lỗi kết nối hoặc lỗi khác
      print('Login error: $e');
      String errorMessage =
          'Lỗi kết nối. Vui lòng kiểm tra kết nối mạng và thử lại.';

      // Kiểm tra nếu là lỗi mạng
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        errorMessage =
            'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      }

      return {'success': false, 'message': errorMessage};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    String? phone,
    required String password,
    String role = 'User',
  }) async {
    try {
      final response = await ApiService.post(ApiConfig.auth + '/register', {
        'fullName': fullName,
        'email': email,
        if (phone != null) 'phone': phone,
        'password': password,
        'role': role,
      }, includeAuth: false);

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Đăng ký thành công'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng ký thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  static Future<User?> getCurrentUser({bool forceRefresh = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Luôn lấy từ API để đảm bảo role được cập nhật đúng
      // (đặc biệt quan trọng khi user có Stylist profile nhưng role chưa được sync)
      final response = await ApiService.get(ApiConfig.auth + '/me');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await prefs.setString('user_data', json.encode(data));
        return User.fromJson(data);
      } else if (response.statusCode == 401) {
        // Token không hợp lệ, xóa token và cache
        await prefs.remove('auth_token');
        await prefs.remove('user_id');
        await prefs.remove('user_data');
        return null;
      }

      // Nếu API fail với status code khác, thử dùng cache (fallback)
      if (!forceRefresh) {
        try {
          final userData = prefs.getString('user_data');
          if (userData != null) {
            return User.fromJson(json.decode(userData));
          }
        } catch (_) {
          // Ignore cache error
        }
      }

      return null;
    } catch (e) {
      // Nếu API fail, thử dùng cache (fallback) - chỉ khi không phải lỗi 401
      if (!forceRefresh) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final userData = prefs.getString('user_data');
          if (userData != null) {
            return User.fromJson(json.decode(userData));
          }
        } catch (_) {
          // Ignore cache error
        }
      }
      return null;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_data');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? email,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['fullName'] = fullName;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;

      final response = await ApiService.patch(
        ApiConfig.auth + '/me',
        body,
        includeAuth: true,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Update cached user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(data));
        return {
          'success': true,
          'user': User.fromJson(data),
          'message': 'Cập nhật thông tin thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Cập nhật thông tin thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.patch(
        ApiConfig.auth + '/change-password',
        {'oldPassword': oldPassword, 'newPassword': newPassword},
        includeAuth: true,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Đổi mật khẩu thành công',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đổi mật khẩu thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }
}

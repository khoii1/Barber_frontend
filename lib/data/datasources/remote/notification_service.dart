import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'api_service.dart';
import '../../../shared/config/api_config.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Khởi tạo local notifications
  static Future<void> initializeLocalNotifications() async {
    // Cấu hình Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Cấu hình iOS (nếu cần)
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Xử lý khi user click notification
        if (kDebugMode) {
          print('📱 User clicked notification: ${response.payload}');
        }
      },
    );
    
    // Tạo notification channel cho Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  // Hiển thị notification
  static Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: data != null ? data.toString() : null,
    );
  }

  // Đăng ký FCM token với backend
  static Future<void> registerFCMToken() async {
    try {
      // Yêu cầu quyền notification
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Lấy FCM token
        String? token = await _messaging.getToken();
        
        if (token != null) {
          print('🔑 FCM Token: $token');
          
          // Lưu token vào SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('fcm_token', token);

          // Đăng ký với backend
          try {
            final response = await ApiService.post(
              '${ApiConfig.notifications}/register-token',
              {
                'fcmToken': token,
                'platform': 'android', // hoặc 'ios' tùy platform
              },
            );

            if (response.statusCode == 200) {
              print('✅ FCM token đã được đăng ký thành công với backend');
            } else {
              final errorData = json.decode(response.body);
              print('❌ Lỗi đăng ký FCM token: ${response.statusCode}');
              print('Error: ${errorData['message'] ?? response.body}');
            }
          } catch (apiError) {
            print('❌ Lỗi khi gọi API đăng ký token: $apiError');
          }
        } else {
          print('❌ Không thể lấy FCM token');
        }
      } else {
        print('❌ User không cho phép notification. Status: ${settings.authorizationStatus}');
      }
    } catch (e) {
      print('❌ Lỗi khi đăng ký FCM token: $e');
    }
  }

  // Lắng nghe notification khi app đang mở (foreground)
  static void setupNotificationHandlers() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Nhận notification khi app đang mở');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
      
      // Hiển thị notification khi app ở foreground
      if (message.notification != null) {
        showNotification(
          title: message.notification!.title ?? 'Thông báo',
          body: message.notification!.body ?? '',
          data: message.data,
        );
      }
    });

    // Xử lý khi user click notification (app đang ở background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 User click notification (app ở background)');
      print('Title: ${message.notification?.title}');
      print('Data: ${message.data}');
      
      // Navigate đến màn hình appointment nếu cần
      // Ví dụ: Navigator.pushNamed(context, '/appointments');
    });

    // Kiểm tra notification khi app được mở từ terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📱 App được mở từ notification (app đang terminated)');
        print('Title: ${message.notification?.title}');
        print('Data: ${message.data}');
      }
    });
  }

  // Xử lý notification khi app ở background
  // PHẢI là top-level function (không phải method)
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('📱 Nhận notification khi app ở background');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
  }

  // Lấy token hiện tại (để debug)
  static Future<String?> getCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      return token;
    } catch (e) {
      print('❌ Lỗi khi lấy token: $e');
      return null;
    }
  }

  // Xóa token (khi logout)
  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      print('✅ Đã xóa FCM token');
    } catch (e) {
      print('❌ Lỗi khi xóa token: $e');
    }
  }
}


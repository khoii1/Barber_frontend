import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'shared/theme/app_theme.dart';
import 'app/providers/auth_provider.dart';
import 'app/providers/service_provider.dart';
import 'app/providers/stylist_provider.dart';
import 'app/providers/appointment_provider.dart';
import 'app/providers/product_provider.dart';
import 'app/providers/payment_provider.dart';
import 'app/pages/login_screen.dart';
import 'app/pages/home_screen.dart';
import 'app/pages/stylist_home_screen.dart';
import 'data/datasources/remote/notification_service.dart';

// Background message handler (PHẢI là top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  NotificationService.handleBackgroundMessage(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');

    // Khởi tạo local notifications
    await NotificationService.initializeLocalNotifications();
    print('Local notifications initialized');

    // Setup background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Setup notification handlers
    NotificationService.setupNotificationHandlers();
  } catch (e) {
    print(' Firebase initialization error: $e');
    print('Push notification sẽ không hoạt động. Kiểm tra cấu hình Firebase.');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => StylistProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: MaterialApp(
        title: 'Barber Shop',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasCheckedAuth = false;

  @override
  void initState() {
    super.initState();
    // Check authentication status when app starts - chỉ gọi 1 lần
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasCheckedAuth) {
        _hasCheckedAuth = true;
        Provider.of<AuthProvider>(context, listen: false).checkAuth();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Chỉ log khi cần thiết để tránh spam
        if (authProvider.isLoading && !_hasCheckedAuth) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.isAuthenticated) {
          // Route based on user role
          final user = authProvider.user;
          if (user != null) {
            // So sánh không phân biệt chữ hoa/thường
            if (user.role.toLowerCase() == 'stylist') {
              return const StylistHomeScreen();
            }
          }
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'providers/stylist_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/product_provider.dart';
import 'providers/payment_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/stylist_home_screen.dart';

void main() {
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
            body: Center(
              child: CircularProgressIndicator(),
            ),
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

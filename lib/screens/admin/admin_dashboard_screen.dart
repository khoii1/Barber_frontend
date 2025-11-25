import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/stylist_provider.dart';
import '../../providers/appointment_provider.dart';
import 'admin_services_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_products_screen.dart';
import 'admin_stylists_screen.dart';
import 'admin_appointments_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).loadServices();
      Provider.of<StylistProvider>(context, listen: false).loadStylists();
      Provider.of<AppointmentProvider>(context, listen: false).loadMyAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Dịch vụ'),
            Tab(text: 'Danh mục'),
            Tab(text: 'Sản phẩm'),
            Tab(text: 'Thợ cắt'),
            Tab(text: 'Lịch hẹn'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminServicesScreen(),
          AdminCategoriesScreen(),
          AdminProductsScreen(),
          AdminStylistsScreen(),
          AdminAppointmentsScreen(),
        ],
      ),
    );
  }
}


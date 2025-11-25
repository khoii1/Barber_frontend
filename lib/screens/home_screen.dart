import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/service_provider.dart';
import '../providers/stylist_provider.dart';
import '../providers/appointment_provider.dart';
import '../providers/product_provider.dart';
import 'services_screen.dart';
import 'appointments_screen.dart';
import 'profile_screen.dart';
import 'stylists_screen.dart';
import 'select_service_screen.dart';
import 'product_detail_screen.dart';

// Color scheme matching the design
const Color _darkGreen = Color(0xFF2D5016);
const Color _lightBeige = Color(0xFFF5E6D3);

class HomeScreen extends StatefulWidget {
  final int? initialTabIndex;

  const HomeScreen({super.key, this.initialTabIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const HomeTabScreen(),
    const ServicesScreen(),
    const StylistsScreen(),
    const AppointmentsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex ?? 0;
    // Load data when home screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).loadServices();
      Provider.of<StylistProvider>(context, listen: false).loadStylists();
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
      // If initialTabIndex is set, refresh data for that tab
      if (widget.initialTabIndex != null) {
        _refreshDataForTab(widget.initialTabIndex!);
      }
    });
  }

  void _refreshDataForTab(int index) {
    // Refresh data when switching tabs
    if (index == 1) {
      // Services tab
      Provider.of<ServiceProvider>(context, listen: false).loadServices();
    } else if (index == 2) {
      // Stylists tab
      Provider.of<StylistProvider>(context, listen: false).loadStylists();
    } else if (index == 3) {
      // Appointments tab
      Provider.of<AppointmentProvider>(
        context,
        listen: false,
      ).loadMyAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _currentIndex,
        indicatorColor: _darkGreen.withOpacity(0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          _refreshDataForTab(index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.room_service_outlined),
            selectedIcon: Icon(Icons.room_service),
            label: 'Dịch vụ',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Thợ cắt',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Lịch hẹn',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

// Home Tab Screen - First tab
class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: const Text('Barber Shop'),
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Lưu reference đến các Provider trước khi await để tránh lỗi deactivated widget
          final serviceProvider = Provider.of<ServiceProvider>(
            context,
            listen: false,
          );
          final stylistProvider = Provider.of<StylistProvider>(
            context,
            listen: false,
          );
          final productProvider = Provider.of<ProductProvider>(
            context,
            listen: false,
          );

          // Load data song song để tăng tốc độ
          await Future.wait([
            serviceProvider.loadServices(),
            stylistProvider.loadStylists(),
            productProvider.loadProducts(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _darkGreen,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chào mừng đến với',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Barber Shop',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SelectServiceScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _darkGreen,
                        ),
                        child: const Text('Đặt lịch ngay'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Services section
              Text(
                'Dịch vụ phổ biến',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Consumer<ServiceProvider>(
                builder: (context, serviceProvider, _) {
                  if (serviceProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final services = serviceProvider.services.take(3).toList();
                  if (services.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Chưa có dịch vụ nào'),
                      ),
                    );
                  }

                  return Column(
                    children: services.map((service) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Circular image with border
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: _darkGreen.withOpacity(0.1),
                                  child: service.imageUrl != null
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: service.imageUrl!,
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                            fadeInDuration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            fadeOutDuration: const Duration(
                                              milliseconds: 100,
                                            ),
                                            placeholder: (context, url) =>
                                                const Center(
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(_darkGreen),
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                                      Icons.content_cut,
                                                      color: _darkGreen,
                                                      size: 32,
                                                    ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.content_cut,
                                          color: _darkGreen,
                                          size: 32,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Service name and price
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      service.formattedPrice,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Duration
                              Text(
                                service.formattedDuration,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Products section
              Text(
                'Sản phẩm nổi bật',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Consumer<ProductProvider>(
                builder: (context, productProvider, _) {
                  if (productProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = productProvider.availableProducts
                      .take(6)
                      .toList();
                  if (products.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Chưa có sản phẩm nào'),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: product.imageUrl != null
                                      ? Image.network(
                                          product.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  color: _darkGreen.withOpacity(
                                                    0.1,
                                                  ),
                                                  child: const Icon(
                                                    Icons.shopping_bag,
                                                    size: 40,
                                                    color: _darkGreen,
                                                  ),
                                                );
                                              },
                                        )
                                      : Container(
                                          color: _darkGreen.withOpacity(0.1),
                                          child: const Icon(
                                            Icons.shopping_bag,
                                            size: 40,
                                            color: _darkGreen,
                                          ),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.formattedPrice,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: _darkGreen,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.inventory_2,
                                          size: 14,
                                          color: product.isInStock
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          product.stockStatus,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: product.isInStock
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Stylists section
              Text(
                'Thợ cắt tóc của chúng tôi',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Consumer<StylistProvider>(
                builder: (context, stylistProvider, _) {
                  if (stylistProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final stylists = stylistProvider.stylists.take(3).toList();
                  if (stylists.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Chưa có thợ cắt tóc nào'),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: stylists.length,
                      itemBuilder: (context, index) {
                        final stylist = stylists[index];
                        return Card(
                          margin: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: _darkGreen.withOpacity(0.1),
                                  child: stylist.avatarUrl != null
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: stylist.avatarUrl!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(_darkGreen),
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                                      Icons.person,
                                                      size: 40,
                                                      color: _darkGreen,
                                                    ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: _darkGreen,
                                        ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  stylist.fullName,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  stylist.displayRating,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/service_provider.dart';
import '../providers/auth_provider.dart';
import '../models/service.dart';
import 'book_appointment_screen.dart';

// Color scheme matching the design
const Color _darkGreen = Color(0xFF2D5016);
const Color _lightPink = Color(0xFFF5E6E6); // Light muted pink background

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    // Load services when screen is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).loadServices();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'GOOD MORNING';
    } else if (hour < 17) {
      return 'GOOD AFTERNOON';
    } else {
      return 'GOOD EVENING';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightPink,
      body: SafeArea(
        child: Consumer2<ServiceProvider, AuthProvider>(
          builder: (context, serviceProvider, authProvider, _) {
            final user = authProvider.user;
            final userName = user?.fullName.toUpperCase() ?? 'GUEST';
            if (serviceProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_darkGreen),
                ),
              );
            }

            if (serviceProvider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lỗi: ${serviceProvider.errorMessage}',
                      style: const TextStyle(color: _darkGreen),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        serviceProvider.loadServices();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _darkGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            final services = serviceProvider.services;
            if (services.isEmpty) {
              return Center(
                child: Text(
                  'Chưa có dịch vụ nào',
                  style: TextStyle(
                    color: _darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => serviceProvider.loadServices(),
              color: _darkGreen,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _HeaderSection(
                      greeting: _getGreeting(),
                      userName: userName,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Text(
                        'SERVICES',
                        style: TextStyle(
                          color: _darkGreen,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontFamily: 'sans-serif',
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final isLast = index == services.length - 1;
                        return Column(
                          children: [
                            _ServiceCard(service: services[index]),
                            if (!isLast) const SizedBox(height: 0),
                          ],
                        );
                      }, childCount: services.length),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final String greeting;
  final String userName;

  const _HeaderSection({required this.greeting, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      decoration: const BoxDecoration(color: _darkGreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            width: double.infinity,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          const Text(
            'Fresh fades, clean cuts.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your style, just one tap away.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;

  const _ServiceCard({required this.service});

  IconData _getServiceIcon(String serviceName) {
    final name = serviceName.toLowerCase();
    if (name.contains('hair') && name.contains('cut')) {
      return Icons.content_cut;
    } else if (name.contains('shav')) {
      return Icons.face;
    } else if (name.contains('cream') || name.contains('bath')) {
      return Icons.spa;
    } else if (name.contains('color')) {
      return Icons.palette;
    } else {
      return Icons.content_cut;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BookAppointmentScreen(service: service),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon square with dark green background
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _darkGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: service.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: service.imageUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 300),
                            fadeOutDuration: const Duration(milliseconds: 100),
                            placeholder: (context, url) => Center(
                              child: Icon(
                                _getServiceIcon(service.name),
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              _getServiceIcon(service.name),
                              color: Colors.white,
                              size: 40,
                            ),
                          )
                        : Icon(
                            _getServiceIcon(service.name),
                            color: Colors.white,
                            size: 40,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Service info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name.toUpperCase(),
                        style: const TextStyle(
                          color: _darkGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          fontFamily: 'sans-serif',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        service.description ??
                            'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          height: 1.4,
                          fontFamily: 'sans-serif',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Divider line
          Container(
            height: 1,
            color: _darkGreen,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/service_provider.dart';
import '../models/service.dart';
import 'book_appointment_screen.dart';

// Color scheme matching the design
const Color _darkGreen = Color(0xFF2D5016);
const Color _lightBeige = Color(0xFFF5E6D3);

class SelectServiceScreen extends StatefulWidget {
  const SelectServiceScreen({super.key});

  @override
  State<SelectServiceScreen> createState() => _SelectServiceScreenState();
}

class _SelectServiceScreenState extends State<SelectServiceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: const Text('Chọn dịch vụ'),
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ServiceProvider>(
        builder: (context, serviceProvider, _) {
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.content_cut, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có dịch vụ nào',
                    style: TextStyle(color: _darkGreen, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => serviceProvider.loadServices(),
            color: _darkGreen,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                return _ServiceCard(service: services[index]);
              },
            ),
          );
        },
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookAppointmentScreen(service: service),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _darkGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: service.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: service.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeOutDuration: const Duration(milliseconds: 100),
                          placeholder: (context, url) => Center(
                            child: Icon(
                              _getServiceIcon(service.name),
                              color: _darkGreen.withOpacity(0.5),
                              size: 30,
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            _getServiceIcon(service.name),
                            color: _darkGreen,
                            size: 30,
                          ),
                        )
                      : Icon(
                          _getServiceIcon(service.name),
                          color: _darkGreen,
                          size: 30,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _darkGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (service.description != null) ...[
                      Text(
                        service.description!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.formattedDuration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          service.formattedPrice,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../models/service.dart';
import '../../services/service_service.dart';
import 'admin_service_form_screen.dart';

// Color scheme matching the design
const Color _darkGreen = Color(0xFF2D5016);
const Color _lightBeige = Color(0xFFF5E6D3);

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
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
                  Text('Lỗi: ${serviceProvider.errorMessage}'),
                  ElevatedButton(
                    onPressed: () => serviceProvider.loadServices(),
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
                  const Icon(Icons.room_service, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Chưa có dịch vụ nào'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showServiceForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm dịch vụ'),
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
                return _ServiceCard(
                  service: services[index],
                  onEdit: () => _showServiceForm(context, services[index]),
                  onDelete: () => _deleteService(context, services[index]),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceForm(context),
        backgroundColor: _darkGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showServiceForm(BuildContext context, [Service? service]) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => AdminServiceFormScreen(service: service),
          ),
        )
        .then((_) {
          Provider.of<ServiceProvider>(context, listen: false).loadServices();
        });
  }

  Future<void> _deleteService(BuildContext context, Service service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa dịch vụ'),
        content: Text('Bạn có chắc chắn muốn xóa dịch vụ "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final result = await ServiceService.deleteService(service.id);
      if (context.mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa dịch vụ'),
              backgroundColor: Colors.green,
            ),
          );
          Provider.of<ServiceProvider>(context, listen: false).loadServices();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Xóa dịch vụ thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _darkGreen.withOpacity(0.1),
          child: const Icon(Icons.content_cut, color: _darkGreen),
        ),
        title: Text(service.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${service.durationMin} phút - ${service.formattedPrice}'),
            if (service.description != null)
              Text(
                service.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Chip(
              label: Text(
                service.isActive ? 'Hoạt động' : 'Tạm dừng',
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: service.isActive
                  ? Colors.green.shade100
                  : Colors.red.shade100,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

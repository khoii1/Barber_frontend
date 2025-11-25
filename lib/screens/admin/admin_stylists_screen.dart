import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/stylist_provider.dart';
import '../../models/stylist.dart';
import '../../services/stylist_service.dart';
import 'admin_stylist_form_screen.dart';

// Color scheme matching the design
const Color _darkGreen = Color(0xFF2D5016);
const Color _lightBeige = Color(0xFFF5E6D3);

class AdminStylistsScreen extends StatefulWidget {
  const AdminStylistsScreen({super.key});

  @override
  State<AdminStylistsScreen> createState() => _AdminStylistsScreenState();
}

class _AdminStylistsScreenState extends State<AdminStylistsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStylists();
    });
  }

  Future<void> _loadStylists() async {
    // Load all stylists (including inactive) for admin
    final stylists = await StylistService.getAllStylists();
    if (mounted) {
      Provider.of<StylistProvider>(
        context,
        listen: false,
      ).setStylists(stylists);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      body: Consumer<StylistProvider>(
        builder: (context, stylistProvider, _) {
          final stylists = stylistProvider.stylists;

          if (stylists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Chưa có thợ cắt tóc nào'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showStylistForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm thợ cắt tóc'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadStylists,
            color: _darkGreen,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stylists.length,
              itemBuilder: (context, index) {
                return _StylistCard(
                  stylist: stylists[index],
                  onEdit: () => _showStylistForm(context, stylists[index]),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStylistForm(context),
        backgroundColor: _darkGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showStylistForm(BuildContext context, [Stylist? stylist]) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => AdminStylistFormScreen(stylist: stylist),
          ),
        )
        .then((_) {
          _loadStylists();
          // Also refresh for mobile app
          Provider.of<StylistProvider>(context, listen: false).loadStylists();
        });
  }
}

class _StylistCard extends StatelessWidget {
  final Stylist stylist;
  final VoidCallback onEdit;

  const _StylistCard({required this.stylist, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final user = stylist.user;
    final fullName = user?['fullName'] ?? 'N/A';
    final email = user?['email'] ?? '';
    final phone = user?['phone'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: _darkGreen.withOpacity(0.1),
          backgroundImage: stylist.avatarUrl != null
              ? CachedNetworkImageProvider(stylist.avatarUrl!)
              : null,
          child: stylist.avatarUrl == null
              ? Text(
                  fullName.isNotEmpty ? fullName[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: _darkGreen,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (email.isNotEmpty) Text('Email: $email'),
            if (phone.isNotEmpty) Text('SĐT: $phone'),
            if (stylist.bio != null && stylist.bio!.isNotEmpty)
              Text(stylist.bio!, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${stylist.ratingAvg.toStringAsFixed(1)} (${stylist.ratingCount})',
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text(
                    stylist.isActive ? 'Hoạt động' : 'Tạm dừng',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: stylist.isActive
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                ),
              ],
            ),
            if (stylist.skills.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: stylist.skills.take(3).map((skill) {
                  return Chip(
                    label: Text(skill, style: const TextStyle(fontSize: 10)),
                    padding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
          color: _darkGreen,
        ),
        isThreeLine: true,
      ),
    );
  }
}

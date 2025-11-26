import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stylist_provider.dart';
import '../../data/models/stylist.dart';
import 'stylist_detail_screen.dart';

// Color scheme matching the design
const Color _darkGreen = Color(0xFF2D5016);
const Color _lightBeige = Color(0xFFF5E6D3);

class StylistsScreen extends StatefulWidget {
  const StylistsScreen({super.key});

  @override
  State<StylistsScreen> createState() => _StylistsScreenState();
}

class _StylistsScreenState extends State<StylistsScreen> {
  @override
  void initState() {
    super.initState();
    // Load stylists when screen is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StylistProvider>(context, listen: false).loadStylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: const Text('Thợ cắt tóc'),
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
      ),
      body: Consumer<StylistProvider>(
        builder: (context, stylistProvider, _) {
          if (stylistProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_darkGreen),
              ),
            );
          }

          if (stylistProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${stylistProvider.errorMessage}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      stylistProvider.loadStylists();
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

          final stylists = stylistProvider.stylists;
          if (stylists.isEmpty) {
            return const Center(child: Text('Chưa có thợ cắt tóc nào'));
          }

          return RefreshIndicator(
            onRefresh: () => stylistProvider.loadStylists(),
            color: _darkGreen,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: stylists.length,
              itemBuilder: (context, index) {
                return _StylistCard(stylist: stylists[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _StylistCard extends StatelessWidget {
  final Stylist stylist;

  const _StylistCard({required this.stylist});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StylistDetailScreen(stylist: stylist),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _darkGreen.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: stylist.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          stylist.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person, size: 60),
                        ),
                      )
                    : const Icon(Icons.person, size: 60),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stylist.fullName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (stylist.bio != null && stylist.bio!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        stylist.bio!,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          stylist.ratingAvg.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (stylist.skills.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: stylist.skills.take(2).map((skill) {
                          return Chip(
                            label: Text(
                              skill,
                              style: const TextStyle(fontSize: 10),
                            ),
                            padding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

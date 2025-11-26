import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/stylist.dart';
import '../../data/datasources/remote/stylist_service.dart';
import '../../data/datasources/remote/rating_service.dart';
import '../providers/stylist_provider.dart';
import '../providers/auth_provider.dart';
import 'rating_dialog.dart';

// Color scheme matching the design
const Color _darkGreen = Color(0xFF2D5016);
const Color _lightBeige = Color(0xFFF5E6D3);

class StylistDetailScreen extends StatefulWidget {
  final Stylist stylist;

  const StylistDetailScreen({super.key, required this.stylist});

  @override
  State<StylistDetailScreen> createState() => _StylistDetailScreenState();
}

class _StylistDetailScreenState extends State<StylistDetailScreen> {
  Stylist? _stylist;
  List<dynamic> _ratings = [];
  bool _isLoading = true;
  bool _isLoadingRatings = false;
  Map<String, dynamic>? _eligibility;

  @override
  void initState() {
    super.initState();
    _stylist = widget.stylist;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load updated stylist info
      final updatedStylist = await StylistService.getStylistById(_stylist!.id);
      if (updatedStylist != null) {
        setState(() {
          _stylist = updatedStylist;
        });
      }

      // Load ratings
      await _loadRatings();

      // Check eligibility (only if user is logged in)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && authProvider.user?.role == 'User') {
        await _checkEligibility();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRatings() async {
    setState(() {
      _isLoadingRatings = true;
    });

    try {
      final ratings = await RatingService.getRatingsByStylist(_stylist!.id);
      setState(() {
        _ratings = ratings;
      });
    } catch (e) {
      print('Error loading ratings: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRatings = false;
        });
      }
    }
  }

  Future<void> _checkEligibility() async {
    try {
      final eligibility = await RatingService.checkEligibility(_stylist!.id);
      setState(() {
        _eligibility = eligibility;
      });
    } catch (e) {
      print('Error checking eligibility: $e');
    }
  }

  Future<void> _showRatingDialog() async {
    if (_eligibility == null || !_eligibility!['canRate']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _eligibility?['message'] ??
                'Bạn không thể đánh giá thợ cắt tóc này',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final availableAppointments =
        _eligibility!['availableAppointments'] as List;
    if (availableAppointments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có lịch hẹn nào để đánh giá'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show rating dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => RatingDialog(
        stylist: _stylist!,
        availableAppointments: availableAppointments,
      ),
    );

    if (result != null && result['success'] == true) {
      // Refresh data
      await _loadData();

      // Refresh stylist list
      Provider.of<StylistProvider>(context, listen: false).loadStylists();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _stylist == null) {
      return Scaffold(
        backgroundColor: _lightBeige,
        appBar: AppBar(
          title: const Text('Chi tiết thợ cắt tóc'),
          backgroundColor: _darkGreen,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_darkGreen),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: const Text('Chi tiết thợ cắt tóc'),
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: _darkGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _darkGreen,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: _stylist!.avatarUrl != null
                            ? Image.network(
                                _stylist!.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: _darkGreen,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 60,
                                color: _darkGreen,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      _stylist!.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          _stylist!.ratingAvg.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${_stylist!.ratingCount} đánh giá)',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bio
                    if (_stylist!.bio != null && _stylist!.bio!.isNotEmpty) ...[
                      _SectionCard(
                        title: 'Giới thiệu',
                        child: Text(
                          _stylist!.bio!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Skills
                    if (_stylist!.skills.isNotEmpty) ...[
                      _SectionCard(
                        title: 'Kỹ năng',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _stylist!.skills.map((skill) {
                            return Chip(
                              label: Text(skill),
                              backgroundColor: _darkGreen.withOpacity(0.1),
                              labelStyle: const TextStyle(color: _darkGreen),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Rating Section
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        // Chỉ hiển thị section này cho user đã đăng nhập
                        if (!authProvider.isAuthenticated || authProvider.user?.role != 'User') {
                          return const SizedBox.shrink();
                        }

                        // Nếu đã check eligibility
                        if (_eligibility != null) {
                          if (_eligibility!['canRate'] == true) {
                            // Có quyền đánh giá - hiển thị nút
                            return Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _showRatingDialog,
                                    icon: const Icon(Icons.star),
                                    label: const Text('Đánh giá thợ cắt tóc'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _darkGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          } else {
                            // Không có quyền đánh giá - kiểm tra lý do
                            final message = _eligibility!['message'] ?? '';
                            final availableAppointments = _eligibility!['availableAppointments'] as List;
                            
                            // Nếu là do chưa có lịch hẹn hoàn thành (availableAppointments rỗng và message chứa "chưa có")
                            if (availableAppointments.isEmpty && 
                                (message.contains('chưa có lịch hẹn') || 
                                 message.contains('chưa có'))) {
                              return Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: _lightBeige,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: _darkGreen.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          color: _darkGreen,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Hãy đặt lịch ${_stylist!.fullName} để được đánh giá',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: _darkGreen,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }
                            // Nếu là message khác (ví dụ: đã đánh giá hết), không hiển thị gì
                            return const SizedBox.shrink();
                          }
                        }
                        // Chưa check eligibility - không hiển thị gì
                        return const SizedBox.shrink();
                      },
                    ),

                    // Ratings List
                    _SectionCard(
                      title: 'Đánh giá (${_ratings.length})',
                      child: _isLoadingRatings
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _darkGreen,
                                  ),
                                ),
                              ),
                            )
                          : _ratings.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  'Chưa có đánh giá nào',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _ratings.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final rating = _ratings[index];
                                final customerName =
                                    rating['customerId']?['fullName'] ??
                                    'Khách hàng';
                                final ratingValue = rating['rating'] ?? 0;
                                final comment = rating['comment'] ?? '';
                                final createdAt = rating['createdAt'] != null
                                    ? DateTime.parse(rating['createdAt'])
                                    : null;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              customerName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: List.generate(5, (i) {
                                              return Icon(
                                                i < ratingValue
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                                size: 20,
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                      if (comment.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          comment,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                      if (createdAt != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatDate(createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else {
      return '${(difference.inDays / 365).floor()} năm trước';
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _darkGreen,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

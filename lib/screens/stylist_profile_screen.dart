import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../models/stylist.dart';
import '../services/stylist_service.dart';

// Color scheme matching the design
const Color _darkGreen = Color(0xFF2D5016);
const Color _lightBeige = Color(0xFFF5E6D3);

class StylistProfileScreen extends StatefulWidget {
  const StylistProfileScreen({super.key});

  @override
  State<StylistProfileScreen> createState() => _StylistProfileScreenState();
}

class _StylistProfileScreenState extends State<StylistProfileScreen> {
  Stylist? _stylist;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stylist = await StylistService.getMyProfile();
      setState(() {
        _stylist = stylist;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải thông tin: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_darkGreen),
              ),
            )
          : Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final user = authProvider.user;
                if (user == null || _stylist == null) {
                  return const Center(
                    child: Text('Không tìm thấy thông tin'),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Profile picture
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _darkGreen, width: 2),
                          color: _lightBeige,
                        ),
                        child: ClipOval(
                          child: _stylist!.avatarUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: _stylist!.avatarUrl!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: _lightBeige,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(_darkGreen),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: _lightBeige,
                                    child: Center(
                                      child: Text(
                                        _stylist!.fullName.isNotEmpty
                                            ? _stylist!.fullName[0].toUpperCase()
                                            : 'S',
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: _darkGreen,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  color: _lightBeige,
                                  child: Center(
                                    child: Text(
                                      _stylist!.fullName.isNotEmpty
                                          ? _stylist!.fullName[0].toUpperCase()
                                          : 'S',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: _darkGreen,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _darkGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Họ và tên',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _stylist!.fullName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // Email
                            if (user.email != null && user.email!.isNotEmpty)
                              _InfoCard(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: user.email!,
                              ),

                            // Phone
                            if (user.phone != null && user.phone!.isNotEmpty)
                              _InfoCard(
                                icon: Icons.phone_outlined,
                                label: 'Số điện thoại',
                                value: user.phone!,
                              ),

                            // Rating
                            _InfoCard(
                              icon: Icons.star_outline,
                              label: 'Đánh giá',
                              value: _stylist!.displayRating,
                            ),

                            // Status
                            _InfoCard(
                              icon: Icons.check_circle_outline,
                              label: 'Trạng thái',
                              value: _stylist!.isActive ? 'Hoạt động' : 'Tạm dừng',
                              valueColor: _stylist!.isActive ? Colors.green : Colors.orange,
                            ),

                            // Bio
                            if (_stylist!.bio != null && _stylist!.bio!.isNotEmpty)
                              _InfoCard(
                                icon: Icons.description_outlined,
                                label: 'Tiểu sử',
                                value: _stylist!.bio!,
                                isMultiline: true,
                              ),

                            // Skills
                            if (_stylist!.skills.isNotEmpty)
                              _InfoCard(
                                icon: Icons.work_outline,
                                label: 'Kỹ năng',
                                value: _stylist!.skills.join(', '),
                                isMultiline: true,
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Menu items
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _ProfileMenuItem(
                              icon: Icons.lock_outline,
                              title: 'Đổi mật khẩu',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tính năng đang phát triển'),
                                  ),
                                );
                              },
                            ),
                            _ProfileMenuItem(
                              icon: Icons.notifications_outlined,
                              title: 'Thông báo',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tính năng đang phát triển'),
                                  ),
                                );
                              },
                            ),
                            _ProfileMenuItem(
                              icon: Icons.info_outline,
                              title: 'Về ứng dụng',
                              onTap: () {
                                showAboutDialog(
                                  context: context,
                                  applicationName: 'Barber Shop',
                                  applicationVersion: '1.0.0',
                                  applicationIcon: const Icon(
                                    Icons.content_cut,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            _ProfileMenuItem(
                              icon: Icons.logout,
                              title: 'Đăng xuất',
                              onTap: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Đăng xuất'),
                                    content: const Text(
                                      'Bạn có chắc chắn muốn đăng xuất?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Đăng xuất'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true && context.mounted) {
                                  await authProvider.logout();
                                  // Không cần navigate thủ công, AuthWrapper sẽ tự động xử lý
                                  // Chỉ cần pop tất cả routes về root để AuthWrapper rebuild
                                  if (context.mounted) {
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                  }
                                }
                              },
                              isDestructive: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isMultiline;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _darkGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: _darkGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? _darkGreen,
                  ),
                  maxLines: isMultiline ? null : 1,
                  overflow: isMultiline ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isDestructive ? Colors.red : _darkGreen)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? Colors.red : _darkGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : _darkGreen,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDestructive ? Colors.red : _darkGreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../../../data/models/stylist.dart';
import '../../../data/datasources/remote/stylist_service.dart';
import '../../../data/datasources/remote/user_service.dart';
import '../../widgets/image_upload_widget.dart';

class AdminStylistFormScreen extends StatefulWidget {
  final Stylist? stylist;

  const AdminStylistFormScreen({super.key, this.stylist});

  @override
  State<AdminStylistFormScreen> createState() => _AdminStylistFormScreenState();
}

class _AdminStylistFormScreenState extends State<AdminStylistFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  String? _avatarUrl;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isCreatingUser = false;

  @override
  void initState() {
    super.initState();
    if (widget.stylist != null) {
      final user = widget.stylist!.user;
      if (user != null) {
        _fullNameController.text = user['fullName'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['phone'] ?? '';
      }
      _bioController.text = widget.stylist!.bio ?? '';
      _skillsController.text = widget.stylist!.skills.join(', ');
      _avatarUrl = widget.stylist!.avatarUrl;
      _isActive = widget.stylist!.isActive;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _saveStylist() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String userId;

      if (widget.stylist == null) {
        // Create new user first
        setState(() => _isCreatingUser = true);
        final userResult = await UserService.createUser(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          password: _passwordController.text,
          role: 'Stylist',
        );

        if (!userResult['success']) {
          throw Exception(userResult['message']);
        }

        userId = userResult['userId'];
        setState(() => _isCreatingUser = false);

        // Then create stylist profile
        final skills = _skillsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        final stylistResult = await StylistService.createStylist(
          userId: userId,
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          skills: skills.isEmpty ? null : skills,
          avatarUrl: _avatarUrl,
        );

        if (!stylistResult['success']) {
          throw Exception(stylistResult['message']);
        }
      } else {
        // Update existing stylist
        final skills = _skillsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        final stylistResult = await StylistService.updateStylist(
          widget.stylist!.id,
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          skills: skills.isEmpty ? null : skills,
          avatarUrl: _avatarUrl,
          isActive: _isActive,
        );

        if (!stylistResult['success']) {
          throw Exception(stylistResult['message']);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.stylist != null
                  ? 'Đã cập nhật thợ cắt tóc'
                  : 'Đã tạo thợ cắt tóc',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isCreatingUser = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stylist != null ? 'Sửa thợ cắt tóc' : 'Thêm thợ cắt tóc'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User information section
              Text(
                'Thông tin tài khoản',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên *',
                  border: OutlineInputBorder(),
                ),
                enabled: widget.stylist == null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: widget.stylist == null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!value.contains('@')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                enabled: widget.stylist == null,
              ),
              if (widget.stylist == null) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu *',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              // Stylist information section
              Text(
                'Thông tin thợ cắt tóc',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // Avatar upload
              ImageUploadWidget(
                initialImageUrl: _avatarUrl,
                folder: 'stylists',
                label: 'Ảnh đại diện',
                onImageUploaded: (imageUrl) {
                  setState(() {
                    _avatarUrl = imageUrl;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Tiểu sử',
                  border: OutlineInputBorder(),
                  helperText: 'Mô tả ngắn về thợ cắt tóc',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Kỹ năng',
                  border: OutlineInputBorder(),
                  helperText: 'Nhập các kỹ năng, phân cách bằng dấu phẩy',
                ),
              ),
              if (widget.stylist != null) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Hoạt động'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (_isLoading || _isCreatingUser) ? null : _saveStylist,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.stylist != null ? 'Cập nhật' : 'Tạo mới'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


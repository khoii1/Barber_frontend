import 'package:flutter/material.dart';
import '../../models/service.dart';
import '../../services/service_service.dart';
import '../../widgets/image_upload_widget.dart';

class AdminServiceFormScreen extends StatefulWidget {
  final Service? service;

  const AdminServiceFormScreen({super.key, this.service});

  @override
  State<AdminServiceFormScreen> createState() => _AdminServiceFormScreenState();
}

class _AdminServiceFormScreenState extends State<AdminServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imageUrl;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _durationController.text = widget.service!.durationMin.toString();
      _priceController.text = widget.service!.priceVnd.toString();
      _descriptionController.text = widget.service!.description ?? '';
      _imageUrl = widget.service!.imageUrl;
      _isActive = widget.service!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      'durationMin': int.parse(_durationController.text),
      'priceVnd': int.parse(_priceController.text),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'imageUrl': _imageUrl?.trim().isEmpty == true ? null : _imageUrl?.trim(),
      'isActive': _isActive,
    };

    try {
      if (widget.service != null) {
        final result = await ServiceService.updateService(
          widget.service!.id,
          data,
        );
        if (!result['success']) {
          throw Exception(result['message']);
        }
      } else {
        final result = await ServiceService.createService(data);
        if (!result['success']) {
          throw Exception(result['message']);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.service != null ? 'Đã cập nhật dịch vụ' : 'Đã tạo dịch vụ',
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service != null ? 'Sửa dịch vụ' : 'Thêm dịch vụ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên dịch vụ *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên dịch vụ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Thời gian (phút) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập thời gian';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Thời gian phải là số dương';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Giá (VNĐ) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập giá';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) < 0) {
                          return 'Giá phải là số không âm';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Image upload widget
              ImageUploadWidget(
                initialImageUrl: _imageUrl,
                folder: 'services',
                onImageUploaded: (imageUrl) {
                  setState(() {
                    _imageUrl = imageUrl;
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Hoạt động'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveService,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.service != null ? 'Cập nhật' : 'Tạo mới'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

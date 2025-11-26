import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/datasources/remote/upload_service.dart';

class ImageUploadWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String) onImageUploaded;
  final String? folder;
  final String label;

  const ImageUploadWidget({
    super.key,
    this.initialImageUrl,
    required this.onImageUploaded,
    this.folder,
    this.label = 'Hình ảnh',
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  XFile? _selectedImage;
  bool _isUploading = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.initialImageUrl;
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final imageUrl = await UploadService.uploadImage(
        _selectedImage!,
        folder: widget.folder,
      );

      if (imageUrl != null && mounted) {
        setState(() {
          _currentImageUrl = imageUrl;
        });
        widget.onImageUploaded(imageUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload ảnh thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload ảnh thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi upload: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        // Display current or selected image
        if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty || _selectedImage != null)
          Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _selectedImage != null
                  ? Image.file(
                      File(_selectedImage!.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : CachedNetworkImage(
                      imageUrl: _currentImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        size: 50,
                      ),
                    ),
            ),
          ),
        // Image picker buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploading
                    ? null
                    : () async {
                        final image = await UploadService.pickImageFromGallery();
                        if (image != null) {
                          setState(() {
                            _selectedImage = image;
                          });
                          await _uploadImage();
                        }
                      },
                icon: const Icon(Icons.photo_library),
                label: const Text('Chọn từ thư viện'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isUploading
                    ? null
                    : () async {
                        final image = await UploadService.pickImageFromCamera();
                        if (image != null) {
                          setState(() {
                            _selectedImage = image;
                          });
                          await _uploadImage();
                        }
                      },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Chụp ảnh'),
              ),
            ),
          ],
        ),
        if (_isUploading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }
}


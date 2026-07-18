import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/destination.dart';
import '../../../services/pocketbase_client.dart';
import '../../shared/app_header.dart';
import '../destinations_manager.dart';

class EditDestinationScreen extends StatefulWidget {
  final Destination? destination;
  const EditDestinationScreen({super.key, this.destination});

  @override
  State<EditDestinationScreen> createState() => _EditDestinationScreenState();
}

class _EditDestinationScreenState extends State<EditDestinationScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _region;
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> _regions = ['Miền Bắc', 'Miền Trung', 'Miền Nam', 'Miền Tây'];

  @override
  void initState() {
    super.initState();
    _title = widget.destination?.title ?? '';
    _region = widget.destination?.region ?? 'Miền Bắc';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final manager = context.read<DestinationsManager>();
      if (widget.destination == null) {
        final newDest = Destination(
          id: '',
          title: _title,
          region: _region,
          imageFile: '',
        );
        await manager.addDestination(newDest, imageFile: _selectedImage);
      } else {
        final updated = widget.destination!.copyWith(
          title: _title,
          region: _region,
        );
        await manager.updateDestination(updated, imageFile: _selectedImage);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: Text(widget.destination == null ? 'Thêm Địa điểm' : 'Sửa Địa điểm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Tên địa điểm'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Vui lòng nhập tên' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _region,
                decoration: const InputDecoration(labelText: 'Miền'),
                items: _regions.map((r) {
                  return DropdownMenuItem(value: r, child: Text(r));
                }).toList(),
                onChanged: (value) {
                  setState(() => _region = value!);
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : widget.destination != null &&
                                widget.destination!.imageFile.isNotEmpty
                            ? Image.network(
                                widget.destination!.getDisplayImageUrl(baseUrl),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                    child: Text('Lỗi ảnh')),
                              )
                            : const Center(child: Text('Chưa có ảnh')),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Chọn ảnh từ máy'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Lưu lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/promotion.dart';
import '../../services/pocketbase_client.dart';
import '../shared/app_header.dart';
import 'promotions_manager.dart';

class EditPromotionScreen extends StatefulWidget {
  const EditPromotionScreen({super.key, this.promotion});
  final Promotion? promotion;

  @override
  State<EditPromotionScreen> createState() => _EditPromotionScreenState();
}

class _EditPromotionScreenState extends State<EditPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _imageUrlController;
  DateTime? _selectedDate;
  
  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final promo = widget.promotion;
    _titleController = TextEditingController(text: promo?.title ?? '');
    _imageUrlController = TextEditingController(text: promo?.imageFile ?? '');
    _selectedDate = promo?.endDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
        // Xóa link ảnh nếu đã chọn file để ưu tiên file
        _imageUrlController.clear();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    final promo = Promotion(
      id: widget.promotion?.id ?? '',
      title: _titleController.text.trim(),
      imageFile: _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : (widget.promotion?.imageFile ?? ''),
      endDate: _selectedDate ?? DateTime.now(),
    );

    final manager = context.read<PromotionsManager>();
    try {
      if (widget.promotion == null) {
        await manager.addPromotion(promo, imageFile: _pickedImage);
      } else {
        await manager.updatePromotion(promo, imageFile: _pickedImage);
      }
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra khi lưu.')),
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
        title: Text(widget.promotion == null ? 'Thêm khuyến mãi' : 'Sửa khuyến mãi'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _save,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề khuyến mãi'),
              validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ngày hết hạn'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate!)),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate!,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Hình ảnh khuyến mãi', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Chọn ảnh từ máy'),
                  ),
                ),
                if (_pickedImage != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _pickedImage = null),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Hoặc nhập link ảnh (URL)',
                hintText: 'https://...',
              ),
              onChanged: (val) {
                if (val.isNotEmpty && _pickedImage != null) {
                  setState(() => _pickedImage = null);
                }
              },
            ),
            const SizedBox(height: 16),
            // Preview image
            if (_pickedImage != null)
              Image.file(_pickedImage!, height: 200, fit: BoxFit.cover)
            else if (_imageUrlController.text.isNotEmpty)
              Image.network(_imageUrlController.text, height: 200, fit: BoxFit.cover)
            else if (widget.promotion != null && widget.promotion!.getDisplayImageUrl(baseUrl).isNotEmpty)
              Image.network(widget.promotion!.getDisplayImageUrl(baseUrl), height: 200, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/tour.dart';
import '../shared/app_header.dart';
import 'tours_manager.dart';

class EditTourScreen extends StatefulWidget {
  const EditTourScreen({super.key, this.tour});
  final Tour? tour;

  @override
  State<EditTourScreen> createState() => _EditTourScreenState();
}

class _EditTourScreenState extends State<EditTourScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final TextEditingController _highlightsController;

  @override
  void initState() {
    super.initState();
    final tour = widget.tour;
    _titleController = TextEditingController(text: tour?.title ?? '');
    _locationController = TextEditingController(text: tour?.location ?? '');
    _descriptionController = TextEditingController(text: tour?.description ?? '');
    _imageController = TextEditingController(text: tour?.imageUrl ?? '');
    _priceController = TextEditingController(text: tour?.price.toStringAsFixed(0) ?? '');
    _durationController = TextEditingController(text: tour?.durationDays.toString() ?? '3');
    _highlightsController = TextEditingController(
      text: tour?.highlights.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _highlightsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final tour = Tour(
      id: widget.tour?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageController.text.trim(),
      price: double.parse(_priceController.text),
      durationDays: int.parse(_durationController.text),
      rating: widget.tour?.rating ?? 4.5,
      isFavorite: widget.tour?.isFavorite ?? false,
      highlights: _highlightsController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
    );
    final manager = context.read<ToursManager>();
    if (widget.tour == null) {
      await manager.addTour(tour);
    } else {
      await manager.updateTour(tour);
    }
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: Text(widget.tour == null ? 'Thêm tour mới' : 'Sửa thông tin tour')),
      body: Form(         key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_titleController, 'Tên tour'),
            _field(_locationController, 'Điểm đến'),
            _field(_descriptionController, 'Mô tả chi tiết', maxLines: 4),
            _field(_imageController, 'URL hình ảnh'),
            _field(
              _priceController,
              'Giá (VNĐ / Khách)',
              keyboardType: TextInputType.number,
            ),
            _field(
              _durationController,
              'Số ngày',
              keyboardType: TextInputType.number,
            ),
            _field(_highlightsController, 'Điểm nổi bật (cách nhau bằng dấu phẩy)'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Lưu tour'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Không được để trống $label';
          }
          if (keyboardType == TextInputType.number &&
              num.tryParse(value.trim()) == null) {
            return 'Vui lòng nhập số hợp lệ';
          }
          return null;
        },
      ),
    );
  }
}
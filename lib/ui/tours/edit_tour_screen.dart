import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/tour.dart';
import '../../services/pocketbase_client.dart';
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
  late final TextEditingController _imageUrlController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final TextEditingController _highlightsController;
  late final TextEditingController _maxGuestsController;
  DateTime? _selectedDate;
  
  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final tour = widget.tour;
    _titleController = TextEditingController(text: tour?.title ?? '');
    _locationController = TextEditingController(text: tour?.location ?? '');
    _descriptionController = TextEditingController(
      text: tour?.description ?? '',
    );
    _imageUrlController = TextEditingController(text: tour?.imageFile ?? '');
    _priceController = TextEditingController(
      text: tour?.price.toStringAsFixed(0) ?? '',
    );
    _durationController = TextEditingController(
      text: tour?.durationDays.toString() ?? '3',
    );
    _highlightsController = TextEditingController(
      text: tour?.highlights.join(', ') ?? '',
    );
    _maxGuestsController = TextEditingController(
      text: tour?.maxGuests.toString() ?? '20',
    );
    _selectedDate =
        tour?.departureDate ?? DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _highlightsController.dispose();
    _maxGuestsController.dispose();
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
      imageFile: widget.tour?.imageFile ?? '',
      price: double.parse(_priceController.text),
      durationDays: int.parse(_durationController.text),
      rating: widget.tour?.rating ?? 4.5,
      highlights: _highlightsController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      departureDate: _selectedDate,
      maxGuests: int.tryParse(_maxGuestsController.text) ?? 20,
      bookedGuests: widget.tour?.bookedGuests ?? 0,
    );
    final manager = context.read<ToursManager>();
    
    setState(() => _isLoading = true);
    try {
      if (widget.tour == null) {
        await manager.addTour(tour, imageFile: _pickedImage);
      } else {
        await manager.updateTour(tour, imageFile: _pickedImage);
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

  // ĐÃ SỬA LỖI ĐÓNG NGOẶC HÀM NÀY
  Future<void> _pickDepartureDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  } 

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
        _imageUrlController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: Text(
          widget.tour == null ? 'Thêm tour mới' : 'Sửa thông tin tour',
        ),
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
            _field(_titleController, 'Tên tour'),
            _field(_locationController, 'Điểm đến'),
            _field(_descriptionController, 'Mô tả chi tiết', maxLines: 4),
            
            const Text('Hình ảnh tour', style: TextStyle(fontWeight: FontWeight.bold)),
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
            // Preview image
            if (_pickedImage != null)
              Image.file(_pickedImage!, height: 200, fit: BoxFit.cover)
            else if (widget.tour != null && widget.tour!.getDisplayImageUrl(baseUrl).isNotEmpty)
              Image.network(widget.tour!.getDisplayImageUrl(baseUrl), height: 200, fit: BoxFit.cover),
            const SizedBox(height: 16),
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
            
            // --- ĐÃ BỔ SUNG UI CHỌN NGÀY KHỞI HÀNH ---
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListTile(
                title: const Text(
                  'Ngày khởi hành',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                subtitle: Text(
                  _selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                      : 'Chưa chọn ngày',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: OutlinedButton.icon(
                  onPressed: _pickDepartureDate,
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: const Text('Chọn ngày'),
                ),
              ),
            ),

            // --- ĐÃ BỔ SUNG UI NHẬP SỐ CHỖ TỐI ĐA ---
            _field(
              _maxGuestsController,
              'Số chỗ tối đa (Khách)',
              keyboardType: TextInputType.number,
            ),

            _field(
              _highlightsController,
              'Điểm nổi bật (cách nhau bằng dấu phẩy)',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Lưu tour'),
            ),
            const SizedBox(height: 16),
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
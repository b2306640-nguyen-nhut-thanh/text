import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking_item.dart';
import '../../models/tour.dart';
import '../auth/auth_manager.dart';
import '../booking/bookings_manager.dart';
import 'tours_manager.dart';
import '../../services/local_notification_service.dart';


class BookingFormScreen extends StatefulWidget {
  final Tour tour;
  final int guests;

  const BookingFormScreen({
    super.key,
    required this.tour,
    required this.guests,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _GuestData {
  String name = '';
  String phone = '';
  String gender = 'Nam';
  DateTime? dob;
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late String _email;
  String _note = '';
  bool _isLoading = false;

  late List<_GuestData> _guestsData;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthManager>().user;
    _email = user?.email ?? '';
    
    _guestsData = List.generate(widget.guests, (index) => _GuestData());
    if (widget.guests > 0) {
      _guestsData[0].name = user?.name ?? '';
    }
  }

  Future<void> _pickDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _guestsData[index].dob ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _guestsData[index].dob) {
      setState(() {
        _guestsData[index].dob = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, String>> participants = [];
      for (int i = 0; i < widget.guests; i++) {
        participants.add({
          'name': _guestsData[i].name,
          'phone': _guestsData[i].phone,
          'gender': _guestsData[i].gender,
          'dob': _guestsData[i].dob != null ? DateFormat('yyyy-MM-dd').format(_guestsData[i].dob!) : '',
        });
      }

      // 1. Tạo BookingItem
      final item = BookingItem(
        tourId: widget.tour.id,
        title: widget.tour.title,
        location: widget.tour.location,
        imageFile: widget.tour.imageFile,
        price: widget.tour.price,
        startDate: widget.tour.departureDate ?? DateTime.now(),
        guests: widget.guests,
        userEmail: _email,
        userName: _guestsData[0].name,
        phone: _guestsData[0].phone,
        note: _note,
        participants: participants,
      );

      // Đọc provider trước khi await
      final bookingsManager = context.read<BookingsManager>();
      final toursManager = context.read<ToursManager>();

      // 2. Lưu booking
      await bookingsManager.addBookings([item]);

      // 3. Cập nhật số lượng khách lên PocketBase
      final updatedTour = widget.tour.copyWith(
        bookedGuests: widget.tour.bookedGuests + widget.guests,
      );
      await toursManager.updateTour(updatedTour);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt tour "${widget.tour.title}" thành công!'),
        ),
      );
      
      // Kích hoạt thông báo cục bộ
      await LocalNotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: 'Đã đặt tour thành công!',
        body: 'Tour "${widget.tour.title}" đã được ghi nhận. Vui lòng chờ Admin xác nhận nhé!',
      );
      
      // Điều hướng về trang danh sách booking
      context.go('/bookings');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: $e')),
      );
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
    final double totalAmount = widget.tour.price * widget.guests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin đặt tour'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tóm tắt thông tin tour
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tour.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.group, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text('${widget.guests} khách'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  widget.tour.departureDate != null 
                                    ? DateFormat('dd/MM/yyyy').format(widget.tour.departureDate!)
                                    : 'Chưa cập nhật ngày đi',
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tổng cộng:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  '${NumberFormat.decimalPattern('vi_VN').format(totalAmount)} VNĐ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    ...List.generate(widget.guests, (index) {
                      final isPrimary = index == 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPrimary ? 'Thông tin người đặt (Khách 1)' : 'Thông tin khách ${index + 1}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              
                              TextFormField(
                                initialValue: _guestsData[index].name,
                                decoration: const InputDecoration(
                                  labelText: 'Họ và tên',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập họ tên';
                                  }
                                  return null;
                                },
                                onSaved: (value) => _guestsData[index].name = value!,
                              ),
                              const SizedBox(height: 16),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _pickDate(context, index),
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'Ngày sinh',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.cake),
                                        ),
                                        child: Text(
                                          _guestsData[index].dob != null
                                              ? DateFormat('dd/MM/yyyy').format(_guestsData[index].dob!)
                                              : 'Chọn ngày',
                                          style: TextStyle(
                                            color: _guestsData[index].dob != null
                                                ? Theme.of(context).textTheme.bodyLarge?.color
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _guestsData[index].gender,
                                      decoration: const InputDecoration(
                                        labelText: 'Giới tính',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.people),
                                      ),
                                      items: ['Nam', 'Nữ', 'Khác'].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          _guestsData[index].gender = newValue!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              if (isPrimary) ...[
                                TextFormField(
                                  initialValue: _email,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty || !value.contains('@')) {
                                      return 'Vui lòng nhập email hợp lệ';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) => _email = value!,
                                ),
                                const SizedBox(height: 16),
                              ],
                              
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Số điện thoại',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.phone),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập số điện thoại';
                                  }
                                  return null;
                                },
                                onSaved: (value) => _guestsData[index].phone = value ?? '',
                              ),
                              
                              if (isPrimary) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Ghi chú (Tùy chọn)',
                                    border: OutlineInputBorder(),
                                    alignLabelWithHint: true,
                                  ),
                                  maxLines: 3,
                                  onSaved: (value) => _note = value ?? '',
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _submitBooking,
                        child: const Text('Xác nhận đặt tour', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

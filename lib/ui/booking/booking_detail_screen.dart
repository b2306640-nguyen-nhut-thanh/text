import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../auth/auth_manager.dart';
import 'bookings_manager.dart';
import '../../services/pocketbase_client.dart';


class BookingDetailScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    // Watch from provider to get latest status updates
    final manager = context.watch<BookingsManager>();
    final isAdmin = context.watch<AuthManager>().isAdmin;

    final booking = manager.bookings.cast<Booking?>().firstWhere(
          (b) => b?.id == bookingId,
          orElse: () => null,
        );

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết Booking')),
        body: const Center(child: Text('Không tìm thấy booking')),
      );
    }

    final item = booking.item;
    final statusColor = booking.status == BookingStatus.confirmed
        ? Colors.green
        : booking.status == BookingStatus.cancelled
            ? Colors.red
            : booking.status == BookingStatus.cancel_request
                ? Colors.orange
                : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Booking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tour Info Card
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    item.getDisplayImageUrl(baseUrl),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(item.location),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(DateFormat('dd/MM/yyyy').format(item.startDate)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.group, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('${item.guests} khách'),
                          ],
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng tiền:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              '${NumberFormat.decimalPattern('vi_VN').format(booking.amount)} VNĐ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Status Card
            Card(
              color: statusColor.withOpacity(0.1),
              elevation: 0,
              child: ListTile(
                leading: Icon(
                  booking.status == BookingStatus.confirmed
                      ? Icons.check_circle
                      : booking.status == BookingStatus.cancelled
                          ? Icons.cancel
                          : Icons.pending,
                  color: statusColor,
                  size: 32,
                ),
                title: const Text('Trạng thái đơn hàng', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  booking.status == BookingStatus.confirmed
                      ? 'Đã xác nhận'
                      : booking.status == BookingStatus.cancelled
                          ? 'Đã hủy'
                          : booking.status == BookingStatus.cancel_request
                              ? 'Đang yêu cầu hủy'
                              : 'Chờ xử lý',
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Contact Info
            Text(
              'Người liên hệ chính',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Họ tên: ${item.userName ?? "Không rõ"}'),
                    const SizedBox(height: 4),
                    Text('Email: ${item.userEmail ?? "Không có"}'),
                    const SizedBox(height: 4),
                    Text('SĐT: ${item.phone ?? "Không có"}'),
                    const SizedBox(height: 4),
                    Text('Ghi chú: ${item.note?.isNotEmpty == true ? item.note : "Không có"}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Participants List
            if (item.participants != null && item.participants!.isNotEmpty) ...[
              Text(
                'Danh sách hành khách (${item.participants!.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...item.participants!.asMap().entries.map((entry) {
                final index = entry.key;
                final p = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(p['name'] ?? 'Chưa rõ'),
                    subtitle: Text(
                      'SĐT: ${p['phone']?.isEmpty ?? true ? 'Không có' : p['phone']}\n'
                      'Giới tính: ${p['gender'] ?? 'Không rõ'} - NS: ${p['dob']?.isEmpty ?? true ? 'Không rõ' : p['dob']}',
                    ),
                    isThreeLine: true,
                  ),
                );
              }),
            ],
            const SizedBox(height: 32),
            
            // Actions
            if (isAdmin) ...[
              if (booking.status == BookingStatus.pending)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.read<BookingsManager>().cancelBooking(booking.id),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => context.read<BookingsManager>().confirmBooking(booking.id),
                        child: const Text('Xác nhận'),
                      ),
                    ),
                  ],
                ),
              if (booking.status == BookingStatus.cancel_request)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Lý do xin hủy: ${booking.cancelReason ?? "Không có"}',
                        style: TextStyle(color: Colors.orange.shade900),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.read<BookingsManager>().rejectCancelBooking(booking.id),
                            child: const Text('Từ chối hủy'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => context.read<BookingsManager>().cancelBooking(booking.id),
                            style: FilledButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Chấp nhận hủy'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ] else if (booking.status == BookingStatus.pending || booking.status == BookingStatus.confirmed)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final reasonCtrl = TextEditingController();
                    final bool? confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Yêu cầu hủy Booking'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Vui lòng nhập lý do hủy đơn. Yêu cầu của bạn sẽ được gửi cho Quản trị viên xem xét.'),
                            const SizedBox(height: 16),
                            TextField(
                              controller: reasonCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Lý do hủy',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Bỏ qua'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Gửi yêu cầu'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && reasonCtrl.text.trim().isNotEmpty) {
                      if (context.mounted) {
                        context.read<BookingsManager>().requestCancelBooking(booking.id, reasonCtrl.text.trim());
                      }
                    }
                  },
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text('Yêu cầu hủy đơn', style: TextStyle(color: Colors.red)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

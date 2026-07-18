import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../shared/app_header.dart';
import 'bookings_manager.dart';
import 'package:go_router/go_router.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  late Future<void> _fetchAllBookings;

  @override
  void initState() {
    super.initState();
    _fetchAllBookings = context.read<BookingsManager>().fetchAllBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: Text('Quản lý Booking')),
      body: FutureBuilder(
        future: _fetchAllBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = context.watch<BookingsManager>().bookings;
          if (bookings.isEmpty) {
            return const Center(child: Text('Chưa có đơn đặt tour nào trong hệ thống'));
          }
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final isCancelled = booking.status == BookingStatus.cancelled;
              final isConfirmed = booking.status == BookingStatus.confirmed;
              
              return Card(
                child: InkWell(
                  onTap: () {
                    context.push('/bookings/${booking.id}');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(booking.item.imageUrl),
                            onBackgroundImageError: (e, s) {},
                          ),
                          title: Text(booking.item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            'Khách: ${booking.item.userName ?? 'Ẩn danh'}\n'
                            'Ngày đi: ${DateFormat('dd/MM/yyyy').format(booking.item.startDate)} - ${booking.item.guests} khách\n'
                            'Trạng thái: ${booking.status.name.toUpperCase()}',
                          ),
                          isThreeLine: true,
                        ),
                        if (booking.status == BookingStatus.pending)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => context.read<BookingsManager>().cancelBooking(booking.id),
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Hủy'),
                                ),
                                const SizedBox(width: 16),
                                FilledButton(
                                  onPressed: () => context.read<BookingsManager>().confirmBooking(booking.id),
                                  child: const Text('Xác nhận'),
                                ),
                              ],
                            ),
                          ),
                        if (booking.status == BookingStatus.cancel_request)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
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
                                    OutlinedButton(
                                      onPressed: () => context.read<BookingsManager>().rejectCancelBooking(booking.id),
                                      child: const Text('Từ chối hủy'),
                                    ),
                                    const SizedBox(width: 16),
                                    FilledButton(
                                      onPressed: () => context.read<BookingsManager>().cancelBooking(booking.id),
                                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('Chấp nhận hủy'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

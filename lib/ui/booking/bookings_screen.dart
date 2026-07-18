import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../shared/app_header.dart';
import 'bookings_manager.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late Future<void> _fetchBookings;

  @override
  void initState() {
    super.initState();
    _fetchBookings = context.read<BookingsManager>().fetchBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: Text('Booking của tôi')),
      body: FutureBuilder(
        future: _fetchBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = context.watch<BookingsManager>().bookings;
          if (bookings.isEmpty) {
            return const Center(child: Text('Bạn chưa đặt tour nào'));
          }
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              Color statusColor;
              String statusText;
              switch (booking.status) {
                case BookingStatus.confirmed:
                  statusColor = Colors.green;
                  statusText = 'Đã xác nhận';
                  break;
                case BookingStatus.cancelled:
                  statusColor = Colors.red;
                  statusText = 'Đã hủy';
                  break;
                case BookingStatus.cancel_request:
                  statusColor = Colors.orange;
                  statusText = 'Chờ duyệt hủy';
                  break;
                case BookingStatus.pending:
                  statusColor = Colors.blue;
                  statusText = 'Chờ xử lý';
                  break;
              }

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(booking.item.imageUrl),
                  ),
                  title: Text(booking.item.title),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy').format(booking.item.startDate)} - ${booking.item.guests} khách',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    context.push('/bookings/${booking.id}');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

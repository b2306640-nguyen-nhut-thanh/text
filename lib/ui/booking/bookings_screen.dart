import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/booking.dart';
import '../shared/app_navigation_bar.dart';
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
      bottomNavigationBar: const AppNavigationBar(),
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
              final isCancelled = booking.status == BookingStatus.cancelled;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(booking.item.imageUrl),
                  ),
                  title: Text(booking.item.title),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy').format(booking.item.startDate)} - ${booking.item.guests} khách\n${booking.status.name}',
                  ),
                  isThreeLine: true,
                  trailing: isCancelled
                      ? const Icon(Icons.block)
                      : TextButton(
                          onPressed: () => context
                              .read<BookingsManager>()
                              .cancelBooking(booking.id),
                          child: const Text('Hủy'),
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

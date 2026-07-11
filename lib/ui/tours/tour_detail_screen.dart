import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking_item.dart';
import '../../models/tour.dart';
import '../booking/bookings_manager.dart';
import '../shared/app_header.dart';
import 'tours_manager.dart';

class TourDetailScreen extends StatefulWidget {
  const TourDetailScreen({super.key, required this.tour});
  final Tour tour;

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  late DateTime _startDate;
  int _guests = 1;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().add(const Duration(days: 7));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _startDate,
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _bookTour(Tour tour) async {
    final item = BookingItem(
      tourId: tour.id,
      title: tour.title,
      location: tour.location,
      imageUrl: tour.imageUrl,
      price: tour.price,
      startDate: _startDate,
      guests: _guests,
    );
    await context.read<BookingsManager>().addBookings([item]);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Đặt "${tour.title}" thành công!'),
          action: SnackBarAction(
            label: 'Xem booking',
            onPressed: () => context.go('/bookings'),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final tour = context.watch<ToursManager>().findById(widget.tour.id) ?? widget.tour;

    return Scaffold(
      appBar: AppHeader(
        title: Text(tour.location),
        actions: [
          IconButton(
            tooltip: 'Yêu thích',
            onPressed: () => context.read<ToursManager>().toggleFavorite(tour.id),
            icon: Icon(
              tour.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () => _bookTour(tour),
            icon: const Icon(Icons.confirmation_number),
            label: const Text('Đặt tour ngay'),
          ),
        ),
      ),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(tour.imageUrl, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tour.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place),
                    const SizedBox(width: 6),
                    Text(tour.location),
                    const Spacer(),
                    const Icon(Icons.star, color: Colors.amber),
                    Text(tour.rating.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${NumberFormat.decimalPattern('vi_VN').format(tour.price)} VNĐ / khách',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(tour.description),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tour.highlights
                      .map(
                        (item) => Chip(
                          avatar: const Icon(Icons.check_circle, size: 18),
                          label: Text(item),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.calendar_month),
                          title: const Text('Ngày khởi hành'),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy').format(_startDate),
                          ),
                          trailing: TextButton(
                            onPressed: _pickDate,
                            child: const Text('Đổi ngày'),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.group),
                          title: const Text('Số lượng khách'),
                          trailing: SizedBox(
                            width: 132,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: _guests <= 1
                                      ? null
                                      : () => setState(() => _guests--),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text('$_guests'),
                                IconButton(
                                  onPressed: () => setState(() => _guests++),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking_item.dart';
import '../../models/tour.dart';
import '../booking/bookings_manager.dart';
import '../shared/app_header.dart';
import 'tours_manager.dart';
import '../auth/auth_manager.dart';

class TourDetailScreen extends StatefulWidget {
  const TourDetailScreen({super.key, required this.tour});
  final Tour tour;

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen> {
  int _guests = 1;

  Future<void> _bookTour(Tour tour) async {
    // 1. Lấy thông tin user 
    final authManager = context.read<AuthManager>();
    final currentUser = authManager.user;

    // Kiểm tra nếu chưa đăng nhập
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đặt tour!')),
      );
      return;
    }

    // 2. Kiểm tra an toàn số lượng chỗ trống
    if (tour.isSoldOut || _guests > tour.remainingSeats) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số lượng chỗ trống không đủ!')),
      );
      return;
    }

    // 3. Tạo BookingItem có kèm thông tin người đặt
    final item = BookingItem(
      tourId: tour.id,
      title: tour.title,
      location: tour.location,
      imageUrl: tour.imageUrl,
      price: tour.price,
      startDate: tour.departureDate ?? DateTime.now(),
      guests: _guests,
      userEmail: currentUser.email,
      userName: currentUser.name,
    );

    // 4. Lưu booking
    await context.read<BookingsManager>().addBookings([item]);

    // 5. Cập nhật số lượng khách lên PocketBase
    final updatedTour = tour.copyWith(
      bookedGuests: tour.bookedGuests + _guests,
    );
    await context.read<ToursManager>().updateTour(updatedTour);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Đặt "$_guests chỗ" tour "${tour.title}" thành công!'),
          action: SnackBarAction(
            label: 'Xem booking',
            onPressed: () => context.go('/bookings'),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe dữ liệu tour mới nhất từ Provider
    final tour =
        context.watch<ToursManager>().findById(widget.tour.id) ?? widget.tour;
    final remaining = tour.remainingSeats;
    final isSoldOut = tour.isSoldOut;

    return Scaffold(
      appBar: AppHeader(
        title: Text(tour.location),
        actions: [
          IconButton(
            tooltip: 'Yêu thích',
            onPressed: () =>
                context.read<ToursManager>().toggleFavorite(tour.id),
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
            // Khóa nút Đặt tour nếu đã hết chỗ
            onPressed: isSoldOut ? null : () => _bookTour(tour),
            icon: Icon(
              isSoldOut ? Icons.event_busy : Icons.confirmation_number,
            ),
            label: Text(
              isSoldOut ? 'TOUR ĐÃ HẾT CHỖ' : 'Đặt tour ngay ($_guests khách)',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: isSoldOut
                  ? Colors.grey
                  : Theme.of(context).colorScheme.primary,
            ),
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

                // --- THẺ THÔNG TIN ĐẶT CHỖ (ĐÃ NÂNG CẤP) ---
                Card(
                  color: isSoldOut ? Colors.red.withOpacity(0.05) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Hiển thị ngày khởi hành cố định
                        ListTile(
                          leading: const Icon(
                            Icons.calendar_month,
                            color: Colors.blue,
                          ),
                          title: const Text('Ngày khởi hành'),
                          subtitle: Text(
                            tour.departureDate != null
                                ? DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(tour.departureDate!)
                                : 'Đang cập nhật lịch',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSoldOut ? Colors.red : Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isSoldOut ? 'Hết chỗ' : 'Còn $remaining chỗ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        // Bộ chọn số lượng khách (giới hạn theo remainingSeats)
                        ListTile(
                          leading: const Icon(
                            Icons.group,
                            color: Colors.orange,
                          ),
                          title: const Text('Số khách đăng ký'),
                          trailing: SizedBox(
                            width: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: (_guests <= 1 || isSoldOut)
                                      ? null
                                      : () => setState(() => _guests--),
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text(
                                  '$_guests',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  // Khóa nút (+) khi đạt tối đa số chỗ còn trống
                                  onPressed: (_guests >= remaining || isSoldOut)
                                      ? null
                                      : () => setState(() => _guests++),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

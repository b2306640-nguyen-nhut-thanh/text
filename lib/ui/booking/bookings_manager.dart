import 'package:flutter/foundation.dart';

import '../../models/booking.dart';
import '../../models/booking_item.dart';
import '../../services/bookings_service.dart';

class BookingsManager with ChangeNotifier {
  final BookingsService _bookingsService = BookingsService();
  List<Booking> _bookings = [];

  List<Booking> get bookings => [..._bookings];
  int get bookingCount => _bookings.length;

  Future<void> fetchBookings() async {
    _bookings = await _bookingsService.fetchBookings();
    notifyListeners();
  }

  Future<void> addBookings(List<BookingItem> items) async {
    final newBookings = items.map((item) {
      return Booking(
        id: DateTime.now().microsecondsSinceEpoch.toString() + item.tourId,
        item: item,
        bookedAt: DateTime.now(),
      );
    }).toList();

    _bookings.insertAll(0, newBookings);
    await _bookingsService.saveBookings(_bookings);
    notifyListeners();
  }

  Future<void> cancelBooking(String id) async {
    final index = _bookings.indexWhere((booking) => booking.id == id);
    if (index < 0) {
      return;
    }
    _bookings[index] = _bookings[index].copyWith(
      status: BookingStatus.cancelled,
    );
    await _bookingsService.saveBookings(_bookings);
    notifyListeners();
  }
}

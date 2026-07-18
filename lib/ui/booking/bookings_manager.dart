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

  Future<void> fetchAllBookings() async {
    _bookings = await _bookingsService.fetchAllBookings();
    notifyListeners();
  }

  Future<void> addBookings(List<BookingItem> items) async {
    for (final item in items) {
      final newBooking = Booking(
        id: DateTime.now().microsecondsSinceEpoch.toString() + item.tourId,
        item: item,
        bookedAt: DateTime.now(),
      );

      // ---> GỌI SERVICE ĐỂ ĐẨY LÊN POCKETBASE <---
      final createdBooking = await _bookingsService.addBooking(newBooking);

      if (createdBooking != null) {
        // Đẩy lên server thành công thì dùng data từ server trả về
        _bookings.insert(0, createdBooking);
      } else {
        // Nếu lỗi mạng thì tạm thời dùng data local
        _bookings.insert(0, newBooking);
      }
    }

    // Vẫn lưu backup vào bộ nhớ máy
    await _bookingsService.saveBookings(_bookings);
    notifyListeners();
  }

  Future<void> requestCancelBooking(String id, String reason) async {
    final index = _bookings.indexWhere((booking) => booking.id == id);
    if (index < 0) return;

    final success = await _bookingsService.updateBookingStatus(
      id, 
      BookingStatus.cancel_request,
      cancelReason: reason,
    );
    if (success) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.cancel_request,
        cancelReason: reason,
      );
      await _bookingsService.saveBookings(_bookings);
      notifyListeners();
    }
  }

  Future<void> rejectCancelBooking(String id) async {
    final index = _bookings.indexWhere((booking) => booking.id == id);
    if (index < 0) return;

    // Rejecting means going back to confirmed (assuming it was pending or confirmed before)
    // Actually we'll just set it to confirmed for simplicity.
    final success = await _bookingsService.updateBookingStatus(id, BookingStatus.confirmed);
    if (success) {
      _bookings[index] = _bookings[index].copyWith(status: BookingStatus.confirmed);
      await _bookingsService.saveBookings(_bookings);
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String id) async {
    final index = _bookings.indexWhere((booking) => booking.id == id);
    if (index < 0) return;

    final success = await _bookingsService.updateBookingStatus(id, BookingStatus.cancelled);
    if (success) {
      _bookings[index] = _bookings[index].copyWith(status: BookingStatus.cancelled);
      await _bookingsService.saveBookings(_bookings);
      notifyListeners();
    }
  }

  Future<void> confirmBooking(String id) async {
    final index = _bookings.indexWhere((booking) => booking.id == id);
    if (index < 0) return;

    final success = await _bookingsService.updateBookingStatus(id, BookingStatus.confirmed);
    if (success) {
      _bookings[index] = _bookings[index].copyWith(status: BookingStatus.confirmed);
      await _bookingsService.saveBookings(_bookings);
      notifyListeners();
    }
  }
}

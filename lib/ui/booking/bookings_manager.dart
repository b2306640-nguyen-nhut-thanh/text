import 'package:flutter/foundation.dart';

import '../../models/booking.dart';
import '../../models/booking_item.dart';
import '../../models/notification.dart';
import '../../services/bookings_service.dart';
import '../../services/notifications_service.dart';

class BookingsManager with ChangeNotifier {
  final BookingsService _bookingsService = BookingsService();
  final NotificationsService _notifService = NotificationsService();
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
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final newBooking = Booking(
        id: DateTime.now().microsecondsSinceEpoch.toString() + item.tourId,
        item: item,
        bookedAt: DateTime.now(),
      );

      // Cập nhật UI ngay lập tức
      _bookings.insert(0, newBooking);
      notifyListeners();

      // Đẩy lên PB ở background
      _bookingsService.addBooking(newBooking).then((createdBooking) async {
        if (createdBooking != null) {
          final index = _bookings.indexWhere((b) => b.id == newBooking.id);
          if (index >= 0) {
            _bookings[index] = createdBooking;
            notifyListeners();
          }
        }
        await _bookingsService.saveBookings(_bookings);

        // Notify Admin
        await _notifService.createNotification(AppNotification(
          id: '',
          userId: '',
          forAdmin: true,
          title: 'Có booking mới',
          message: 'Khách hàng ${item.userName ?? 'Ẩn danh'} vừa đặt tour ${item.title}',
          isRead: false,
          type: 'booking_created',
          relatedId: '',
          created: DateTime.now(),
        ));

        // Notify User
        final bookingUserId = createdBooking?.userId ?? newBooking.userId;
        if (bookingUserId != null && bookingUserId.isNotEmpty) {
          await _notifService.createNotification(AppNotification(
            id: '',
            userId: bookingUserId,
            forAdmin: false,
            title: 'Đặt tour thành công',
            message: 'Bạn vừa đặt tour ${item.title} thành công. Vui lòng chờ admin xác nhận.',
            isRead: false,
            type: 'booking_pending',
            relatedId: createdBooking?.id ?? newBooking.id,
            created: DateTime.now(),
          ));
        }
      });
    }
  }

  Future<void> requestCancelBooking(String id, String reason) async {
    final index = _bookings.indexWhere((booking) => booking.id == id);
    if (index < 0) return;

    final oldBooking = _bookings[index];
    _bookings[index] = _bookings[index].copyWith(
      status: BookingStatus.cancel_request,
      cancelReason: reason,
    );
    notifyListeners();

    _bookingsService.updateBookingStatus(
      id, 
      BookingStatus.cancel_request,
      cancelReason: reason,
    ).then((success) async {
      if (success) {
        await _bookingsService.saveBookings(_bookings);
        // Notify Admin
        await _notifService.createNotification(AppNotification(
          id: '',
          userId: '',
          forAdmin: true,
          title: 'Yêu cầu hủy tour',
          message: 'Khách hàng yêu cầu hủy tour ${_bookings[index].item.title} với lý do: $reason',
          isRead: false,
          type: 'cancel_request',
          relatedId: id,
          created: DateTime.now(),
        ));
      } else {
        final currentIndex = _bookings.indexWhere((booking) => booking.id == id);
        if (currentIndex >= 0) {
          _bookings[currentIndex] = oldBooking;
          notifyListeners();
        }
      }
    });
  }

  Future<void> rejectCancelBooking(String id) async {
    final index = _bookings.indexWhere((booking) => booking.id == id);
    if (index < 0) return;

    final oldBooking = _bookings[index];
    _bookings[index] = _bookings[index].copyWith(status: BookingStatus.confirmed);
    notifyListeners();

    _bookingsService.updateBookingStatus(id, BookingStatus.confirmed).then((success) async {
      if (success) {
        await _bookingsService.saveBookings(_bookings);
        if (_bookings[index].userId != null && _bookings[index].userId!.isNotEmpty) {
          await _notifService.createNotification(AppNotification(
            id: '',
            userId: _bookings[index].userId!,
            forAdmin: false,
            title: 'Yêu cầu hủy bị từ chối',
            message: 'Admin đã từ chối yêu cầu hủy tour ${_bookings[index].item.title}.',
            isRead: false,
            type: 'cancel_rejected',
            relatedId: id,
            created: DateTime.now(),
          ));
        }
      } else {
        final currentIndex = _bookings.indexWhere((booking) => booking.id == id);
        if (currentIndex >= 0) {
          _bookings[currentIndex] = oldBooking;
          notifyListeners();
        }
      }
    });
  }

  Future<void> cancelBooking(String id) async {
    final index = _bookings.indexWhere((booking) => booking.id == id);
    if (index < 0) return;

    final oldBooking = _bookings[index];
    _bookings[index] = _bookings[index].copyWith(status: BookingStatus.cancelled);
    notifyListeners();

    _bookingsService.updateBookingStatus(id, BookingStatus.cancelled).then((success) async {
      if (success) {
        await _bookingsService.saveBookings(_bookings);
        if (_bookings[index].userId != null && _bookings[index].userId!.isNotEmpty) {
          await _notifService.createNotification(AppNotification(
            id: '',
            userId: _bookings[index].userId!,
            forAdmin: false,
            title: 'Hủy tour thành công',
            message: 'Tour ${_bookings[index].item.title} của bạn đã được hủy thành công.',
            isRead: false,
            type: 'booking_cancelled',
            relatedId: id,
            created: DateTime.now(),
          ));
        }
      } else {
        final currentIndex = _bookings.indexWhere((booking) => booking.id == id);
        if (currentIndex >= 0) {
          _bookings[currentIndex] = oldBooking;
          notifyListeners();
        }
      }
    });
  }

  Future<void> confirmBooking(String id) async {
    final index = _bookings.indexWhere((booking) => booking.id == id);
    if (index < 0) return;

    final oldBooking = _bookings[index];
    _bookings[index] = _bookings[index].copyWith(status: BookingStatus.confirmed);
    notifyListeners();

    _bookingsService.updateBookingStatus(id, BookingStatus.confirmed).then((success) async {
      if (success) {
        await _bookingsService.saveBookings(_bookings);
        if (_bookings[index].userId != null && _bookings[index].userId!.isNotEmpty) {
          await _notifService.createNotification(AppNotification(
            id: '',
            userId: _bookings[index].userId!,
            forAdmin: false,
            title: 'Xác nhận đặt tour',
            message: 'Tour ${_bookings[index].item.title} của bạn đã được admin xác nhận.',
            isRead: false,
            type: 'booking_confirmed',
            relatedId: id,
            created: DateTime.now(),
          ));
        }
      } else {
        final currentIndex = _bookings.indexWhere((booking) => booking.id == id);
        if (currentIndex >= 0) {
          _bookings[currentIndex] = oldBooking;
          notifyListeners();
        }
      }
    });
  }
}

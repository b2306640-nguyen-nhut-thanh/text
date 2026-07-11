import '../models/booking.dart';
import 'travel_storage_service.dart';

class BookingsService {
  static const _storageKey = 'travel_bookings';
  final TravelStorageService _storage = TravelStorageService();

  Future<List<Booking>> fetchBookings() async {
    final storedBookings = await _storage.readList(_storageKey);
    return storedBookings.map(Booking.fromJson).toList()
      ..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
  }

  Future<void> saveBookings(List<Booking> bookings) async {
    await _storage.writeList(
      _storageKey,
      bookings.map((booking) => booking.toJson()).toList(),
    );
  }
}

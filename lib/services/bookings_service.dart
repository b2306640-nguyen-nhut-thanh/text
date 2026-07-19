import 'package:pocketbase/pocketbase.dart';
import '../models/booking.dart';
import 'pocketbase_client.dart';
import 'travel_storage_service.dart';

class BookingsService {
  static const _storageKey = 'travel_bookings';
  final TravelStorageService _storage = TravelStorageService();

  Future<List<Booking>> fetchAllBookings() async {
    try {
      final pb = await getPocketbaseInstance();
      final records = await pb.collection('bookings').getFullList(
        sort: '-created',
      );
      return records.map((record) {
        return Booking.fromJson({
          ...record.toJson(),
          'id': record.id,
          'bookedAt': record.created,
        });
      }).toList();
    } catch (e) {
      print('Lỗi lấy toàn bộ bookings từ PocketBase: $e');
      return [];
    }
  }
  Future<List<Booking>> fetchBookings() async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record?.id;
      
      final records = await pb.collection('bookings').getFullList(
        sort: '-created',
        filter: userId != null ? 'userId = "$userId"' : '',
      );
      return records.map((record) {
        return Booking.fromJson({
          ...record.toJson(),
          'id': record.id,
          'bookedAt': record.created,
        });
      }).toList();
    } catch (e) {
      print('Lỗi lấy bookings từ PocketBase: $e');
      final storedBookings = await _storage.readList(_storageKey);
      return storedBookings.map(Booking.fromJson).toList()
        ..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
    }
  }

  Future<Booking?> addBooking(Booking booking) async {
    try {
      final pb = await getPocketbaseInstance();
      final body = booking.toJson();
      
      body.remove('id');
      if (pb.authStore.record != null) {
        body['userId'] = pb.authStore.record!.id;
      }
      
      if (body['userId'] == '') {
        body.remove('userId');
      }

      final record = await pb.collection('bookings').create(body: body);
      
      return Booking.fromJson({
        ...record.toJson(),
        'id': record.id,
        'bookedAt': record.created,
      });
    } catch (e) {
      print('Lỗi tạo booking trên PocketBase: $e');
      return null;
    }
  }

  Future<bool> updateBookingStatus(String id, BookingStatus status, {String? cancelReason}) async {
    try {
      final pb = await getPocketbaseInstance();
      final body = <String, dynamic>{
        'status': status.name,
      };
      if (cancelReason != null) {
        body['cancelReason'] = cancelReason;
      }
      
      await pb.collection('bookings').update(id, body: body);
      return true;
    } catch (e) {
      print('Lỗi cập nhật trạng thái booking: $e');
      return false;
    }
  }

  Future<void> saveBookings(List<Booking> bookings) async {
    await _storage.writeList(
      _storageKey,
      bookings.map((booking) => booking.toJson()).toList(),
    );
  }
}
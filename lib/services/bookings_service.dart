import 'package:pocketbase/pocketbase.dart';
import '../models/booking.dart';
import 'pocketbase_client.dart';
import 'travel_storage_service.dart';

class BookingsService {
  static const _storageKey = 'travel_bookings';
  final TravelStorageService _storage = TravelStorageService();

  // 1. Lấy danh sách booking từ PocketBase về
  Future<List<Booking>> fetchBookings() async {
    try {
      final pb = await getPocketbaseInstance();
      final records = await pb.collection('bookings').getFullList(
        sort: '-created',
      );
      return records.map((record) {
        return Booking.fromJson({
          ...record.toJson(),
          'id': record.id,
          'bookedAt': record.created, // Dùng thời gian tạo từ server
        });
      }).toList();
    } catch (e) {
      print('Lỗi lấy bookings từ PocketBase: $e');
      // Nếu lỗi mạng thì lấy tạm từ bộ nhớ điện thoại
      final storedBookings = await _storage.readList(_storageKey);
      return storedBookings.map(Booking.fromJson).toList()
        ..sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
    }
  }

  // 2. THÊM HÀM NÀY: Gửi booking mới lên PocketBase
  Future<Booking?> addBooking(Booking booking) async {
    try {
      final pb = await getPocketbaseInstance();
      final body = booking.toJson();
      
      body.remove('id'); // Xóa id tạm để PocketBase tự tạo ID chuẩn 15 ký tự
      
      // Tự động lấy ID người dùng đang đăng nhập điền vào cột userId trên bảng
      if (pb.authStore.record != null) {
        body['userId'] = pb.authStore.record!.id;
      }

      // Gọi API tạo record trên bảng bookings
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

  // Lưu backup cục bộ
  Future<void> saveBookings(List<Booking> bookings) async {
    await _storage.writeList(
      _storageKey,
      bookings.map((booking) => booking.toJson()).toList(),
    );
  }
}
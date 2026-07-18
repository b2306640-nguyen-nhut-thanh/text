import 'booking_item.dart';

enum BookingStatus { pending, confirmed, cancel_request, cancelled }

class Booking {
  final String id;
  final BookingItem item;
  final DateTime bookedAt;
  final BookingStatus status;
  final String? cancelReason;

  const Booking({
    required this.id,
    required this.item,
    required this.bookedAt,
    this.status = BookingStatus.pending,
    this.cancelReason,
  });

  double get amount => item.total;

  Booking copyWith({
    String? id,
    BookingItem? item,
    DateTime? bookedAt,
    BookingStatus? status,
    String? cancelReason,
  }) {
    return Booking(
      id: id ?? this.id,
      item: item ?? this.item,
      bookedAt: bookedAt ?? this.bookedAt,
      status: status ?? this.status,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item.toJson(),
      'status': status.name,
      'userEmail': item.userEmail ?? '',
      'userName': item.userName ?? '',
      'cancelReason': cancelReason ?? '',
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      item: BookingItem.fromJson(json['item']),
      bookedAt: DateTime.parse(json['bookedAt']),
      status: BookingStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      cancelReason: json['cancelReason'] as String?,
    );
  }
}

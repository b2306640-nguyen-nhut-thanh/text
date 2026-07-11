import 'booking_item.dart';

enum BookingStatus { pending, confirmed, cancelled }

class Booking {
  final String id;
  final BookingItem item;
  final DateTime bookedAt;
  final BookingStatus status;

  const Booking({
    required this.id,
    required this.item,
    required this.bookedAt,
    this.status = BookingStatus.confirmed,
  });

  double get amount => item.total;

  Booking copyWith({
    String? id,
    BookingItem? item,
    DateTime? bookedAt,
    BookingStatus? status,
  }) {
    return Booking(
      id: id ?? this.id,
      item: item ?? this.item,
      bookedAt: bookedAt ?? this.bookedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item': item.toJson(),
      'bookedAt': bookedAt.toIso8601String(),
      'status': status.name,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      item: BookingItem.fromJson(json['item']),
      bookedAt: DateTime.parse(json['bookedAt']),
      status: BookingStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => BookingStatus.confirmed,
      ),
    );
  }
}

class BookingItem {
  final String tourId;
  final String title;
  final String location;
  final String imageUrl;
  final double price;
  final DateTime startDate;
  final int guests;

  const BookingItem({
    required this.tourId,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.startDate,
    required this.guests,
  });

  double get total => price * guests;

  BookingItem copyWith({
    String? tourId,
    String? title,
    String? location,
    String? imageUrl,
    double? price,
    DateTime? startDate,
    int? guests,
  }) {
    return BookingItem(
      tourId: tourId ?? this.tourId,
      title: title ?? this.title,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
      guests: guests ?? this.guests,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tourId': tourId,
      'title': title,
      'location': location,
      'imageUrl': imageUrl,
      'price': price,
      'startDate': startDate.toIso8601String(),
      'guests': guests,
    };
  }

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      tourId: json['tourId'],
      title: json['title'],
      location: json['location'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      guests: json['guests'],
    );
  }
}

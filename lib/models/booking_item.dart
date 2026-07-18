class BookingItem {
  final String tourId;
  final String title;
  final String location;
  final String imageUrl;
  final double price;
  final DateTime startDate;
  final int guests;
  final String? userEmail;
  final String? userName;
  final String? phone;
  final String? note;
  final List<Map<String, String>>? participants;

  const BookingItem({
    required this.tourId,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.startDate,
    required this.guests,
    this.userEmail,
    this.userName,
    this.phone,
    this.note,
    this.participants,
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
    String? userEmail,
    String? userName,
    String? phone,
    String? note,
    List<Map<String, String>>? participants,
  }) {
    return BookingItem(
      tourId: tourId ?? this.tourId,
      title: title ?? this.title,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
      guests: guests ?? this.guests,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      phone: phone ?? this.phone,
      note: note ?? this.note,
      participants: participants ?? this.participants,
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
      'userEmail': userEmail ?? '',
      'userName': userName ?? '',
      'phone': phone ?? '',
      'note': note ?? '',
      'participants': participants ?? [],
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
      userEmail: json['userEmail'],
      userName: json['userName'],
      phone: json['phone'],
      note: json['note'],
      participants: json['participants'] != null 
          ? List<Map<String, dynamic>>.from(json['participants'])
              .map((e) => e.map((k, v) => MapEntry(k.toString(), v.toString())))
              .toList()
          : null,
    );
  }
}
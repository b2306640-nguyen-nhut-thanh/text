class BookingItem {
  final String tourId;
  final String title;
  final String location;
  final String imageFile;
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
    required this.imageFile,
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

  String getDisplayImageUrl(String pocketBaseUrl) {
    if (imageFile.isNotEmpty) {
      if (imageFile.startsWith('http')) return imageFile;
      if (pocketBaseUrl.isNotEmpty) {
        return '$pocketBaseUrl/api/files/tours/$tourId/$imageFile';
      }
    }
    return 'https://placehold.co/600x400/e0e0e0/808080.png?text=No+Image';
  }

  BookingItem copyWith({
    String? tourId,
    String? title,
    String? location,
    String? imageFile,
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
      imageFile: imageFile ?? this.imageFile,
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
      'imageFile': imageFile,
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
      imageFile: json['imageFile'] ?? json['imageUrl'] ?? '',
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
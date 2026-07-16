class Tour {
  final String id;
  final String title;
  final String location;
  final String description;
  final String imageUrl;
  final double price;
  final int durationDays;
  final double rating;
  final bool isFavorite;
  final List<String> highlights;
  
  // --- BỔ SUNG CÁC TRƯỜNG MỚI ---
  final DateTime? departureDate; 
  final int maxGuests;
  final int bookedGuests;

  const Tour({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.durationDays,
    required this.rating,
    this.isFavorite = false,
    this.highlights = const [],
    // --- THÊM VÀO CONSTRUCTOR ---
    this.departureDate,
    this.maxGuests = 20, // Mặc định 20 chỗ
    this.bookedGuests = 0,
  });

  // Tính số chỗ còn trống
  int get remainingSeats => maxGuests - bookedGuests;
  bool get isSoldOut => remainingSeats <= 0;

  Tour copyWith({
    String? id,
    String? title,
    String? location,
    String? description,
    String? imageUrl,
    double? price,
    int? durationDays,
    double? rating,
    bool? isFavorite,
    List<String>? highlights,
    DateTime? departureDate,
    int? maxGuests,
    int? bookedGuests,
  }) {
    return Tour(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      highlights: highlights ?? this.highlights,
      departureDate: departureDate ?? this.departureDate,
      maxGuests: maxGuests ?? this.maxGuests,
      bookedGuests: bookedGuests ?? this.bookedGuests,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'durationDays': durationDays,
      'rating': rating,
      'isFavorite': isFavorite,
      'highlights': highlights,
      'departureDate': departureDate?.toUtc().toIso8601String(),
      'maxGuests': maxGuests,
      'bookedGuests': bookedGuests,
    };
  }

  factory Tour.fromJson(Map<String, dynamic> json) {
    List<String> parsedHighlights = [];
    if (json['highlights'] is List) {
      parsedHighlights = (json['highlights'] as List)
          .map((item) => item.toString())
          .toList();
    }
    return Tour(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Chưa có tên',
      location: json['location']?.toString() ?? 'Chưa có địa điểm',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 1,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isFavorite: json['isFavorite'] ?? false,
      highlights: parsedHighlights,
      departureDate: json['departureDate'] != null && json['departureDate'] != ""
          ? DateTime.tryParse(json['departureDate'].toString())?.toLocal()
          : null,
      maxGuests: (json['maxGuests'] as num?)?.toInt() ?? 20,
      bookedGuests: (json['bookedGuests'] as num?)?.toInt() ?? 0,
    );
  }
}
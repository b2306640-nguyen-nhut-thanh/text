import 'dart:io';

class Tour {
  final String id;
  final String title;
  final String location;
  final String description;
  final String imageFile;
  final double price;
  final int durationDays;
  final double rating;
  final List<String> highlights;
  final DateTime? departureDate;
  final int maxGuests;
  final int bookedGuests;

  const Tour({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.imageFile,
    required this.price,
    required this.durationDays,
    required this.rating,
    this.highlights = const [],
    this.departureDate,
    this.maxGuests = 20,
    this.bookedGuests = 0,
  });

  int get remainingSeats => maxGuests - bookedGuests;
  bool get isSoldOut => remainingSeats <= 0;

  String getDisplayImageUrl(String pocketBaseUrl) {
    if (imageFile.isNotEmpty) {
      if (imageFile.startsWith('http')) return imageFile;
      if (pocketBaseUrl.isNotEmpty) {
        return '$pocketBaseUrl/api/files/tours/$id/$imageFile';
      }
    }
    return 'https://placehold.co/600x400/e0e0e0/808080.png?text=No+Image';
  }

  Tour copyWith({
    String? id,
    String? title,
    String? location,
    String? description,
    String? imageFile,
    double? price,
    int? durationDays,
    double? rating,
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
      imageFile: imageFile ?? this.imageFile,
      price: price ?? this.price,
      durationDays: durationDays ?? this.durationDays,
      rating: rating ?? this.rating,
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
      'imageFile': imageFile,
      'price': price,
      'durationDays': durationDays,
      'rating': rating,
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
      imageFile: json['image']?.toString() ?? json['imageUrl']?.toString() ?? json['imageFile']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 1,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      highlights: parsedHighlights,
      departureDate: json['departureDate'] != null && json['departureDate'] != ""
          ? DateTime.tryParse(json['departureDate'].toString())?.toLocal()
          : null,
      maxGuests: (json['maxGuests'] as num?)?.toInt() ?? 20,
      bookedGuests: (json['bookedGuests'] as num?)?.toInt() ?? 0,
    );
  }
}
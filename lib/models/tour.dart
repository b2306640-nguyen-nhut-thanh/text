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
  });

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
      title: json['title']?.toString() ?? 'Chưa đặt tên',
      location: json['location']?.toString() ?? 'Chưa rõ địa điểm',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 1,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isFavorite: json['isFavorite'] ?? false,
      highlights: parsedHighlights,
    );
  }
}

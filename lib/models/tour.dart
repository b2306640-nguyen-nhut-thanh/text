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
    return Tour(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: (json['price'] as num).toDouble(),
      durationDays: json['durationDays'],
      rating: (json['rating'] as num).toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      highlights: List<String>.from(json['highlights'] ?? const []),
    );
  }
}

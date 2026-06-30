import 'dart:io';

class Product {
  final String? id;
  final String title;
  final String description;
  final double price;
  final File? featuredImage;
  final String imageUrl;
  final bool isFavorite;

  Product({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    this.featuredImage,
    this.imageUrl = '',
    this.isFavorite = false,
  });

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    File? featuredImage,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      featuredImage: featuredImage ?? this.featuredImage,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  bool hasFeaturedImage() {
    return featuredImage != null || imageUrl.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'isFavorite': isFavorite,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      isFavorite: json['isFavorite'] ?? false,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

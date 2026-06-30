class CartItem {
  final String id;
  final String title;
  final String imageUrl;
  final int quantity;
  final double price;
  final String? color;
  final String? size;

  CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    this.color,
    this.size,
  });

  CartItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    int? quantity,
    double? price,
    String? color,
    String? size,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      color: color ?? this.color,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'price': price,
      'color': color,
      'size': size,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      color: json['color'],
      size: json['size'],
    );
  }
}
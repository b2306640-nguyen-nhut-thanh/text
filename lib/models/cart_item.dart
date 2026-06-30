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
}
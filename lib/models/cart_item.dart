class CartItem {
  final String id;
  final String title;
  final String imageUrl;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.quantity,
    required this.price,
  });

  CartItem copyWith({
    String? id,
    String? title,
    String? imageUrl,
    int? quantity,
    double? price,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}
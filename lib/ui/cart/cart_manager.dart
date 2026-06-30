import 'package:flutter/foundation.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../services/db_helper.dart';
import '../../services/pocketbase_client.dart';

class CartManager with ChangeNotifier {
  Map<String, CartItem> _items = {};

  int get productCount => _items.length;
  List<CartItem> get products => _items.values.toList();
  Iterable<MapEntry<String, CartItem>> get productEntries => {..._items}.entries;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<String?> get _userId async {
    final pb = await getPocketbaseInstance();
    return pb.authStore.record?.id;
  }

  String _buildItemKey(Product product, {String? color, String? size}) {
    return '${product.id}_${color ?? 'default'}_${size ?? 'default'}';
  }

  Future<void> fetchAndSetCart() async {
    final uid = await _userId;
    if (uid == null) return;
    
    final dataList = await DBHelper.getData('cart_items', uid);
    _items = {};
    for (var item in dataList) {
      _items[item['productId']] = CartItem(
        id: item['id'],
        title: item['title'],
        imageUrl: item['imageUrl'],
        price: item['price'],
        quantity: item['quantity'],
        color: item['color'] != 'null' ? item['color'] : null,
        size: item['size'] != 'null' ? item['size'] : null,
      );
    }
    notifyListeners();
  }

  Future<void> addItem(Product product, {int quantity = 1, String? color, String? size}) async {
    final uid = await _userId;
    if (uid == null) return;

    final itemKey = _buildItemKey(product, color: color, size: size);

    if (_items.containsKey(itemKey)) {
      final newQuantity = _items[itemKey]!.quantity + quantity;
      _items.update(itemKey, (existing) => existing.copyWith(quantity: newQuantity));
      await DBHelper.updateQuantity('cart_items', itemKey, uid, newQuantity);
    } else {
      final newItem = CartItem(
        id: DateTime.now().toIso8601String(),
        title: product.title,
        imageUrl: product.imageUrl,
        price: product.price,
        quantity: quantity,
        color: color,
        size: size,
      );
      _items.putIfAbsent(itemKey, () => newItem);
      await DBHelper.insert('cart_items', {
        'productId': itemKey,
        'id': newItem.id,
        'userId': uid,
        'title': newItem.title,
        'imageUrl': newItem.imageUrl,
        'price': newItem.price,
        'quantity': newItem.quantity,
        'color': newItem.color ?? 'null',
        'size': newItem.size ?? 'null',
      });
    }
    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    final uid = await _userId;
    if (uid == null || !_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      final newQuantity = _items[productId]!.quantity - 1;
      _items.update(productId, (existing) => existing.copyWith(quantity: newQuantity));
      await DBHelper.updateQuantity('cart_items', productId, uid, newQuantity);
    } else {
      _items.remove(productId);
      await DBHelper.delete('cart_items', productId, uid);
    }
    notifyListeners();
  }

  Future<void> clearItem(String productId) async {
    final uid = await _userId;
    if (uid == null) return;
    _items.remove(productId);
    await DBHelper.delete('cart_items', productId, uid);
    notifyListeners();
  }

  Future<void> clearAllItems() async {
    final uid = await _userId;
    if (uid == null) return;
    _items.clear();
    await DBHelper.clear('cart_items', uid);
    notifyListeners();
  }
}
import 'package:flutter/foundation.dart';
import '../../models/cart_item.dart';
import '../../models/order_item.dart';
import '../../services/orders_service.dart';

class OrdersManager with ChangeNotifier {
  List<OrderItem> _orders = [];
  final OrdersService _ordersService = OrdersService();

  int get orderCount {
    return _orders.length;
  }

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    _orders = await _ordersService.fetchOrders();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final newOrder = OrderItem(
      amount: total,
      products: cartProducts,
      dateTime: DateTime.now(),
    );

    final savedOrder = await _ordersService.addOrder(newOrder);
    
    if (savedOrder != null) {
      _orders.insert(0, savedOrder);
      notifyListeners();
    }
  }
}
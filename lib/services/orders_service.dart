import 'pocketbase_client.dart';
import '../models/order_item.dart';

class OrdersService {
  Future<List<OrderItem>> fetchOrders() async {
    final List<OrderItem> orders = [];
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record?.id;
      
      if (userId == null) return orders;

      // Lấy danh sách đơn hàng của user hiện tại, sắp xếp mới nhất lên đầu
      final records = await pb.collection('orders').getFullList(
        filter: "userId='$userId'",
        sort: '-dateTime', 
      );

      for (var record in records) {
        orders.add(OrderItem.fromJson({
          ...record.toJson(),
          'id': record.id, 
        }));
      }
      return orders;
    } catch (error) {
      print('Error fetching orders: $error');
      return orders;
    }
  }

  Future<OrderItem?> addOrder(OrderItem order) async {
    try {
      final pb = await getPocketbaseInstance();
      final userId = pb.authStore.record?.id;

      if (userId == null) throw Exception('User not logged in');

      final record = await pb.collection('orders').create(
        body: {
          ...order.toJson(),
          'userId': userId,
        },
      );

      return order.copyWith(id: record.id);
    } catch (error) {
      print('Error adding order: $error');
      return null;
    }
  }
}
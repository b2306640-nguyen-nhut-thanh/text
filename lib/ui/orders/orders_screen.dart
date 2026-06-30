import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/app_drawer.dart';
import 'orders_manager.dart';
import 'order_item_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<void> _fetchOrdersFuture;

  @override
  void initState() {
    super.initState();
    _fetchOrdersFuture = context.read<OrdersManager>().fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _fetchOrdersFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('An error occurred!'));
          } else {
            return Consumer<OrdersManager>(
              builder: (ctx, ordersManager, child) {
                return ListView.builder(
                  itemCount: ordersManager.orderCount,
                  itemBuilder: (ctx, i) =>
                      OrderItemCard(ordersManager.orders[i]),
                );
              },
            );
          }
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:myshop/ui/shared/app_drawer.dart';
import 'package:provider/provider.dart';

import 'orders_manager.dart';
import 'order_item_card.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: Consumer<OrdersManager> (
        builder: (_, ordersManager, _) {
          return ListView.builder(
            itemCount: ordersManager.orderCount,
            itemBuilder: (_, i) => 
              OrderItemCard(ordersManager.orders[i]),
          );
        }
      ),
    );
  }
}


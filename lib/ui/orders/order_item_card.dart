import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_item.dart';

class OrderItemCard extends StatefulWidget {
  final OrderItem order;

  const OrderItemCard(this.order, {super.key});

  @override
  State<OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<OrderItemCard> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          OrderSummary(
            order: widget.order,
            expanded: _expanded,
            onExpandPressed: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
          if (_expanded) OrderItemList(widget.order),
        ],
      ),
    );
  }
}

class OrderItemList extends StatelessWidget {
  const OrderItemList(
    this.order, {
    super.key,
  });

  final OrderItem order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      height: min(order.productCount * 20.0 + 10, 100),
      child: ListView(
        children: order.products
            .map(
              (prod) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    prod.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${prod.quantity}x \$${prod.price}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class OrderSummary extends StatelessWidget {
  const OrderSummary({
    super.key,
    required this.order,
    required this.expanded,
    this.onExpandPressed,
  });

  final bool expanded;
  final OrderItem order;
  final void Function()? onExpandPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      titleTextStyle: Theme.of(context).textTheme.titleLarge,
      title: Text('\$${order.amount.toStringAsFixed(2)}'),
      subtitle: Text(
        DateFormat('dd/MM/yyyy hh:mm').format(order.dateTime),
      ),
      trailing: IconButton(
        icon: Icon(
          expanded ? Icons.expand_less : Icons.expand_more,
        ),
        onPressed: onExpandPressed,
      ),
    );
  }
}
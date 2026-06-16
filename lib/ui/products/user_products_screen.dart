import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/app_drawer.dart';
import 'user_product_list_tile.dart';
import 'products_manager.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          AddUserProductButton(
            onPressed: () {
              print('Go to edit product screen');
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const UserProductList(),
    );
  }
}

class UserProductList extends StatelessWidget {
  const UserProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsManager>(
      builder: (_, productsManager, _) {
        return ListView.builder(
          itemCount: productsManager.itemCount,
          itemBuilder: (_, i) => Column(
          children: [
            UserProductListTile(
              productsManager.items[i],
            ),
          const Divider(),
          ],
        ),
        );
      },
    );
  }
}

class AddUserProductButton extends StatelessWidget {
  const AddUserProductButton({
    super.key,
    this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: onPressed,
    );
  }
}
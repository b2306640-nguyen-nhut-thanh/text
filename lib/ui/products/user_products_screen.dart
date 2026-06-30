import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../shared/app_drawer.dart';
import 'user_product_list_tile.dart';
import 'products_manager.dart';

class UserProductsScreen extends StatefulWidget {
  const UserProductsScreen({super.key});

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  late Future<void> _fetchUserProducts;

  @override
  void initState() {
    super.initState();
    _fetchUserProducts = context.read<ProductsManager>().fetchUserProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          AddUserProductButton(
            onPressed: () {
              context.push('/my-products/new');
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: _fetchUserProducts,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                context.read<ProductsManager>().fetchUserProducts(),
            child: const UserProductList(),
          );
        },
      ),
    );
  }
}

class UserProductList extends StatelessWidget {
  const UserProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsManager>(
      builder: (_, productsManager, __) {
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

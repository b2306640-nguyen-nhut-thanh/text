import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../cart/cart_manager.dart';
import '../cart/cart_screen.dart';
import 'products_overview_screen.dart';
import 'products_manager.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen(
    this.product, {
    super.key,
  });

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String _selectedColor = 'Red';
  String _selectedSize = 'M';

  final List<String> _colors = ['Red', 'Blue', 'Black', 'White'];
  final List<String> _sizes = ['S', 'M', 'L', 'XL'];

  @override
  void initState() {
    super.initState();
  }

  void _increaseQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const ProductsOverviewScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  void _goCart() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const CartScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      ),
    );
  }

  void _toggleFavorite() {
    final productsManager = context.read<ProductsManager>();
    final currentProduct = _currentProduct;
    productsManager.updateProduct(
      currentProduct.copyWith(
        isFavorite: !currentProduct.isFavorite,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            currentProduct.isFavorite
                ? 'Removed from favorite list'
                : 'Added to favorite list',
            textAlign: TextAlign.center,
          ),
        ),
      );
  }

  Product get _currentProduct {
    final productId = widget.product.id;
    if (productId == null) {
      return widget.product;
    }

    return context.read<ProductsManager>().findById(productId) ?? widget.product;
  }

  void _addToCart() {
    final product = _currentProduct;
    context.read<CartManager>().addItem(
      product,
      quantity: _quantity,
      color: _selectedColor,
      size: _selectedSize,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Added $_quantity item(s) - $_selectedColor - $_selectedSize to cart',
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductsManager>().findById(
          widget.product.id ?? '',
        ) ??
        widget.product;
    final cart = context.watch<CartManager>();

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _goHome,
          ),
          IconButton(
            icon: Badge.count(
              count: cart.productCount,
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: _goCart,
          ),
          IconButton(
            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            color: Theme.of(context).colorScheme.secondary,
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton.icon(
          onPressed: _addToCart,
          icon: const Icon(Icons.shopping_cart),
          label: const Text('Add to cart'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Color',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _colors.map((color) {
                      return ChoiceChip(
                        label: Text(color),
                        selected: _selectedColor == color,
                        onSelected: (_) {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Size',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _sizes.map((size) {
                      return ChoiceChip(
                        label: Text(size),
                        selected: _selectedSize == size,
                        onSelected: (_) {
                          setState(() {
                            _selectedSize = size;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _decreaseQuantity,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      IconButton(
                        onPressed: _increaseQuantity,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

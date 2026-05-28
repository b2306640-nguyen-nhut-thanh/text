import 'package:flutter/material.dart';
import 'product_detail_screen.dart';
import '../../models/product.dart';

class ProductGridTile extends StatelessWidget {
  const ProductGridTile(
    this.product, {
    super.key,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: ProductGridFooter(
          product: product,
          onFavoritePressed: () {
            print('Toggle a favorite product');
          },
          onAddToCartPressed: () {
            print('Add item to cart');
          },
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => ProductDetailScreen(product),
                ),
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class ProductGridFooter extends StatelessWidget {
  const ProductGridFooter({
    super.key,
    required this.product,
    this.onFavoritePressed,
    this.onAddToCartPressed,
  });

  final Product product;
  final void Function()? onFavoritePressed;
  final void Function()? onAddToCartPressed;

  @override
  Widget build(BuildContext context) {
    return GridTileBar(
      backgroundColor: Colors.black87,
      leading: IconButton(
        icon: Icon(
          product.isFavorite ? Icons.favorite : Icons.favorite_border,
        ),
        color: Theme.of(context).colorScheme.secondary,
        onPressed: onFavoritePressed,
      ),
      title: Text(
        product.title,
        textAlign: TextAlign.center,
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.shopping_cart,
        ),
        onPressed: onAddToCartPressed,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}

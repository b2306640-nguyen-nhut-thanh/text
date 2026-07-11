import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PromotionPreview extends StatelessWidget {
  const PromotionPreview({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/promotions'),
      ),
    );
  }
}
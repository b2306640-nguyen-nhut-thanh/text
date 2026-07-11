import 'package:flutter/material.dart';

import '../shared/app_navigation_bar.dart';
import '../shared/app_header.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  static const _promotions = [
    _Promotion(
      title: 'Giảm 25% tour hè',
      subtitle: 'Áp dụng cho nhóm từ 4 khách khi đặt trước 14 ngày.',
      code: 'SUMMER25',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1000&q=80',
    ),
    _Promotion(
      title: 'Combo gia đình',
      subtitle: 'Miễn phí 1 trẻ em dưới 6 tuổi cho tour nghỉ dưỡng.',
      code: 'FAMILY',
      imageUrl:
          'https://images.unsplash.com/photo-1522199710521-72d69614c702?auto=format&fit=crop&w=1000&q=80',
    ),
    _Promotion(
      title: 'Tặng voucher khách sạn',
      subtitle: 'Nhận voucher 500.000 đ cho booking từ 8.000.000 đ.',
      code: 'HOTEL500',
      imageUrl:
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=1000&q=80',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: Text('Khuyến mãi')),
      bottomNavigationBar: const AppNavigationBar(),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _promotions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final promotion = _promotions[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 7,
                  child: Image.network(promotion.imageUrl, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promotion.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(promotion.subtitle),
                      const SizedBox(height: 12),
                      Chip(
                        avatar: const Icon(Icons.confirmation_number),
                        label: Text('Mã: ${promotion.code}'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Promotion {
  const _Promotion({
    required this.title,
    required this.subtitle,
    required this.code,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String code;
  final String imageUrl;
}

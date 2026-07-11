import 'package:flutter/material.dart';
import 'feature_item.dart';

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});

  static const List<Widget> _features = [
    FeatureItem(
      icon: Icons.auto_awesome,
      iconBgColor: Color(0xFFE8F0FE),
      iconColor: Color(0xFF1A73E8),
      title: 'Tour được chọn lọc',
      subtitle: 'Lịch trình rõ ràng, minh bạch.',
    ),
    FeatureItem(
      icon: Icons.tune,
      iconBgColor: Color(0xFFF3E8FD),
      iconColor: Color(0xFF9333EA),
      title: 'Tư vấn thông minh',
      subtitle: 'Gợi ý hành trình theo ngân sách.',
    ),
    FeatureItem(
      icon: Icons.shield_outlined,
      iconBgColor: Color(0xFFFFEAEB),
      iconColor: Color(0xFFE53935),
      title: 'Hỗ trợ tận tâm',
      subtitle: 'Đồng hành cùng bạn 24/7.',
    ),
    FeatureItem(
      icon: Icons.language,
      iconBgColor: Color(0xFFFEF3C7),
      iconColor: Color(0xFFD97706),
      title: 'Trải nghiệm đa dạng',
      subtitle: 'Từ nghỉ dưỡng đến khám phá.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: _features,
    );
  }
}
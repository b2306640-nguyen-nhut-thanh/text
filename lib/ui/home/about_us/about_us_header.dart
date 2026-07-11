import 'package:flutter/material.dart';

class AboutUsHeader extends StatelessWidget {
  const AboutUsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEAEB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'VỀ CHÚNG TÔI',
            style: TextStyle(
              color: Color(0xFFE53935),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 16),

        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1D26),
                  height: 1.3,
                ),
            children: const [
              TextSpan(text: 'Kiến tạo những hành trình\n'),
              TextSpan(
                text: 'diệu kỳ ',
                style: TextStyle(color: Color(0xFFE53935)),
              ),
              TextSpan(text: 'cho riêng bạn'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Chúng tôi không chỉ bán tour, chúng tôi đem đến những trải nghiệm sống đáng nhớ. '
          'Với hệ thống đặt tour thông minh và đội ngũ hỗ trợ tận tâm, Travol cam kết mang lại '
          'sự an tâm tuyệt đối cho mọi chuyến đi của bạn.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.6,
              ),
        ),
      ],
    );
  }
}
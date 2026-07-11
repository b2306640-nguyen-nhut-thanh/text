import 'package:flutter/material.dart';
import 'why_choose_us_header.dart';
import 'why_choose_us_item.dart';
import 'dashed_wave_painter.dart';

class WhyChooseUsSection extends StatelessWidget {
  const WhyChooseUsSection({super.key});

  static const List<Map<String, dynamic>> _items = [
    {
      'icon': Icons.headset_mic_outlined,
      'bgColor': Color(0xFFF1F5F9),
      'color': Color(0xFF1E293B),
      'title': 'An Toàn Tuyệt Đối',
      'subtitle':
          'Chúng tôi cam kết tiêu chuẩn an toàn cao nhất, đảm bảo mọi hành trình của bạn luôn được bảo vệ và hỗ trợ kịp thời.',
    },
    {
      'icon': Icons.camera_alt_outlined,
      'bgColor': Color(0xFFE0F2FE),
      'color': Color(0xFF0284C7),
      'title': 'Dịch Vụ Đẳng Cấp',
      'subtitle':
          'Tận hưởng những dịch vụ cao cấp được thiết kế riêng biệt, mang lại sự thoải mái và hài lòng tối đa cho du khách.',
    },
    {
      'icon': Icons.savings_outlined,
      'bgColor': Color(0xFFFEF3C7),
      'color': Color(0xFFD97706),
      'title': 'Tiết Kiệm Chi Phí',
      'subtitle':
          'Cung cấp mức giá cạnh tranh nhất cùng nhiều ưu đãi hấp dẫn giúp bạn có chuyến đi trong mơ với chi phí hợp lý.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WhyChooseUsHeader(),
              const SizedBox(height: 24),
              
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 768;

                  if (isDesktop) {
                    return Stack(
                      children: [
                        const Positioned(
                          top: 0,
                          left: 90,
                          right: 90,
                          height: 56,
                          child: CustomPaint(painter: DashedWavePainter()),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _items
                              .map(
                                (item) => Expanded(
                                  child: WhyChooseUsItem(
                                    icon: item['icon'],
                                    iconBgColor: item['bgColor'],
                                    iconColor: item['color'],
                                    title: item['title'],
                                    subtitle: item['subtitle'],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: _items
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: WhyChooseUsItem(
                                icon: item['icon'],
                                iconBgColor: item['bgColor'],
                                iconColor: item['color'],
                                title: item['title'],
                                subtitle: item['subtitle'],
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}